/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCInstance
import org.franca.compmodel.dsl.fcomp.FcompFactory
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import java.util.Collections
import org.eclipse.xtext.nodemodel.INode
import javax.inject.Inject
import org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider

class FCompUtils {

	public def static getComponentForObject(EObject obj) {
		var EObject o = obj
		while (o.eContainer !== null) {
			if (o.eContainer instanceof FCComponent)
				return o.eContainer as FCComponent
			o = o.eContainer 
		}
		return null
	} 
	
	public def static inSameComponent(EObject o1, EObject o2) {
		val c1 = getComponentForObject(o1)
		if (c1 === null)
			return false
		else 
			return c1 === getComponentForObject(o2)
	}
	
	/** Collection of all ports of a component depending on the type of the port.
	 * Inherited Ports are included.
	 */	
	public def static void collectInheritedPorts(FCComponent comp, FCPortKind pt, List<FCPort> ports) {
		if (pt == FCPortKind.PROVIDED)
			ports += comp.providedPorts
		else 
			ports += comp.requiredPorts
			
		if (comp.superType !== null)
			collectInheritedPorts(comp.superType, pt, ports)	
	}
	
	public def static FCModel getFCModel(EObject o) {
		var EObject obj = o
		while(obj !== null) {
			if (!(obj instanceof FCModel)) {
				return obj as FCModel
			} else {
				obj = o.eContainer
			}
		}
		return null
	}
	
	/**
	 * Handle creation of FCInstance entities, linked from FCDevice or FDService.
	 * node: contains the name for the instance
	 * context: where to look for existing instances
	 * domain: dismangle the resouce uri for different callers
	 */
	public def static List<EObject> linkInstance(INode node, EObject context, String domain) {
        val String referencedServiceFQN  = node.getText().trim
//        println("*************************************")
//        println(referencedServiceFQN)
		var FCComponent component = getReferencedService(context, referencedServiceFQN)
		
		if (component !== null) {
			// create a dummy URI with the DSL's file extension
			var ResourceSet resourceSet = context.eResource.getResourceSet
			val URI uri = URI.createURI(referencedServiceFQN + domain)
			var Resource resource = resourceSet.getResource(uri, false)
//			println('uri "' + uri.toString + '"')
			var FCInstance instance = null
			if (resource == null) {
				instance = FcompFactory.eINSTANCE.createFCInstance()
				instance.component = component
				instance.name = referencedServiceFQN
				resource = resourceSet.createResource(uri)
				val List<EObject> contents = resource.getContents
				contents.add(instance)
				return Collections.singletonList(instance as EObject)
			} 
			else if (!resource.getContents.empty) {
				instance = resource.getContents.get(0) as FCInstance
				return Collections.singletonList(instance as EObject)		
			}
		}
//		println('cannot ACCESSS instance for ' + referencedServiceFQN)
		Collections.emptyList()
	}
	
	@Inject
	static FCompDeclarativeNameProvider nameProvider = new FCompDeclarativeNameProvider
	
	private def static FCComponent getReferencedService(EObject context, String fqn) {
//		println('search for ' + fqn)
		
		val components = context.eResource.resourceSet.allContents.filter(FCComponent).toList	
//		if (components.isNullOrEmpty) 
//			println("====================AUUTSCH=======================")
		
		var component = components.findFirst[
			fqn.startsWith(nameProvider.getFullyQualifiedName(it).toString)
		]
		
		if (component !== null) {
			val endOfPrefix = nameProvider.getFullyQualifiedName(component).toString.length + 1
			val stripped = fqn.substring(endOfPrefix)
			val segments = stripped.split('\\.')
			
			for (prototypeName: segments) {
				var prototype = component?.prototypes.findFirst[name == prototypeName]
				if (prototype === null) {
//					println('no match')
					return null
				}
				component = prototype.component
			}
			if (component.service) {
//				println('found service ' + component.name)
				return component	
			}
		}
//		println('no match')
		return null
	}
}
