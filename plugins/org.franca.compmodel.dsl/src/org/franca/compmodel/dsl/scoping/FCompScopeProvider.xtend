/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.scoping

import com.google.common.base.Predicate
import java.util.List
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCInjectedPrototype
import org.franca.compmodel.dsl.fcomp.FCInstance
import org.franca.compmodel.dsl.fcomp.FCLabelKind
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection
import org.franca.compmodel.dsl.fcomp.FCPrototypeInstance

import static extension org.eclipse.xtext.scoping.Scopes.*
import java.util.ArrayList
import org.franca.compmodel.dsl.fcomp.FCInjectionModifier

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 * 
 */
class FCompScopeProvider extends AbstractDeclarativeScopeProvider {

	/** Scope "contains" for possible component types */
	def scope_FCAbstractPrototype_component(FCComponent component, EReference ref) {
		val IScope delegateScope = delegateGetScope(component, ref)
		// Remove self component from scope, to avoid recursion in modeling
		new FilteringScope(delegateScope, [getEObjectOrProxy != component])
	}

	/** Scope "delegate from" for possible ports inclusive inherited ports */
	def scope_FCOuter_port(FCDelegateConnector dc, EReference ref) {
		val comp = FCompUtils::getComponentForObject(dc)
		var List<FCPort> ports = newArrayList()
		FCompUtils::collectInheritedPorts(comp, dc.kind, ports)
		ports.scopeFor
	}

	/** Scope "delegate to" for possible contained components, depending on the "from" interface type */
	def scope_FCInner_componentRef(FCDelegateConnector dc, EReference ref) {
		val comp = FCompUtils::getComponentForObject(dc)
		val interfaceType = dc.outer.port.interface
		var compRefs = comp.prototypes.filter [
			var List<FCPort> ports = newArrayList()
			FCompUtils::collectInheritedPorts(component, dc.kind, ports)
			ports.exists[interface == interfaceType]
		]
		compRefs.scopeFor
	}

	/** Scope "delegate to" for possible port, depending on selected target component and the "from" interface type */
	def scope_FCInner_port(FCDelegateConnector dc, EReference ref) {
		val cref = dc.inner.prototype
		val interfaceType = dc.outer.port.interface
		if (cref !== null) {
			var List<FCPort> ports = newArrayList()
			FCompUtils::collectInheritedPorts(cref.component, dc.kind, ports)
			ports.filter[interface == interfaceType].scopeFor
		} else
			IScope.NULLSCOPE
	}

	// Scope assembly ports
	/** Scope for prototypes with unconnected required ports  */
	def scope_FCFrom_prototype(FCAssemblyConnector ac, EReference ref) {
		val IScope delegateScope = delegateGetScope(ac, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof FCPrototype) {
					var List<FCPort> ports = newArrayList()
					FCompUtils::collectInheritedPorts(obj.component, FCPortKind.REQUIRED, ports)
					val allPortsConnectedForCompRef = ports.empty
					! allPortsConnectedForCompRef
				} else
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}

	def scope_FCFrom_port(FCAssemblyConnector ac, EReference ref) {
		// val comp = FCompUtils::getComponentForObject(ac)
		val cref = ac.from.prototype
		if (cref !== null) {
			var List<FCPort> ports = newArrayList()
			FCompUtils::collectInheritedPorts(cref.component, FCPortKind.REQUIRED, ports)
			ports.scopeFor
		} else
			IScope.NULLSCOPE
	}

	def scope_FCTo_prototype(FCAssemblyConnector ac, EReference ref) {
		val comp = FCompUtils::getComponentForObject(ac)
		val interfaceType = ac.from.port.interface
		val compRefs = comp.prototypes.filter [
			var List<FCPort> ports = newArrayList()
			FCompUtils::collectInheritedPorts(component, FCPortKind.PROVIDED, ports)
			ports.exists[interface == interfaceType]
		]
		compRefs.scopeFor
	}

	def scope_FCTo_port(FCAssemblyConnector ac, EReference ref) {
		val cref = ac.to.prototype
		val interfaceType = ac.from.port.interface
		if (cref !== null) {
			var List<FCPort> ports = newArrayList()
			FCompUtils::collectInheritedPorts(cref.component, FCPortKind.PROVIDED, ports)
			ports.filter[interface == interfaceType].scopeFor
		} else
			IScope.NULLSCOPE
	}

	// scope inject-able prototypes
	def scope_FCInjectedPrototype_ref(FCInjectedPrototype ip, EReference ref) {
		val IScope delegateScope = delegateGetScope(ip, ref)
		val FCComponent wantedSuperType = ip.component.superType
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy

				if (obj instanceof FCPrototype) {
					if (obj == ip || obj == ip.eContainer || obj == ip.component)
						return false
					if (obj.component == wantedSuperType)
						return true
					if (obj.component.inheritsFrom(wantedSuperType))
				    	return true
				}
				return false
			}
		}
		new FilteringScope(delegateScope, filter)
	}

	// injection from within a derived component type
	def scope_FCPrototypeInjection_ref(FCComponent component, EReference ref) {
		val prototypes = new ArrayList()
		var c = component
		// find all prototypes in component hierarchy
		while (c.superType !== null) {
			c = c.superType
			for (p : c.prototypes) {
				prototypes.add(p)
			}
		}
		// remove all prototypes that are already injected with modifier "finally"
		c = component
		while (c.superType !== null) {
			c = c.superType
			for(i : c.injections) {
				val FCPrototypeInjection pi = i as FCPrototypeInjection
				if(pi.modifier === FCInjectionModifier.FINALLY) {
					prototypes.remove(pi.ref)
				}
			}
		}
		prototypes.scopeFor
	}
	
	def scope_FCGenericPrototype_component(FCPrototypeInjection pi, EReference ref) {
		val IScope delegateScope = delegateGetScope(pi, ref)
		val FCComponent wantedSuperType = pi.ref.component
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof FCComponent) {
					if (obj.superType === null)
						return false
				    if (obj.inheritsFrom(wantedSuperType))
				    	return true
				}
				return false
			}
		}
		new FilteringScope(delegateScope, filter)
	 }	

	/**
	 * Scope to the prototypes available in the parent's component type. 
	 * Handle injected components.
	 * Remove "abstract" components from the scope. 
	 */
	def IScope scope_FCPrototypeInstance_prototype(FCPrototypeInstance pi, EReference ref) {
		val parent = pi.parent
		if (parent === null)
			return IScope.NULLSCOPE
		val List<FCGenericPrototype> candidates = newArrayList()
		// Because of rewrite in the Xtext-grammer the parent is either PrototypeInstance or Instance.
		if (parent instanceof FCPrototypeInstance)
			candidates += parent.prototype.component.prototypes
		else if (parent instanceof FCInstance)
			candidates += parent.component.prototypes
			
		// look for injected components and add them if  the override a proto (two variants with no name :-()
		val ips = EcoreUtil2.getResourceSet(pi).allContents.filter(FCInjectedPrototype)
			.filter[candidates.contains(it.ref)].toList
		candidates += ips	
		
		val pis = EcoreUtil2.getResourceSet(pi).allContents.filter(FCPrototypeInjection)
			.filter[candidates.contains(it.ref)].toList
		candidates += pis
		
		candidates.filter[
			component.labels.map[kind].contains(FCLabelKind.ABSTRACT) == false
		].scopeFor
	}

	/**
	 * Remove "abstract" components from the scope for component type of an instance. 
	 */
	def IScope scope_FCInstance_component(FCInstance instance, EReference ref) {
		val IScope delegateScope = delegateGetScope(instance, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof FCComponent)
					obj.labels.map[kind].contains(FCLabelKind.ABSTRACT) == false
				else
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	private def boolean inheritsFrom(FCComponent component, FCComponent superType) {
		var c = component?.superType
		while (c !== null) {
			if (c == superType)
				return true
			c = c.superType
		}
		return false
	}

	// *****************************************************************************
	def private dump(IScope s, String tag) {
		println("    " + tag)
		for (e : s.allElements) {
			println("        " + e.name + " = " + e.EObjectOrProxy)
		}
	}
}
