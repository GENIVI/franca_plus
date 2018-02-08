/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 2017-07-28: Bernhard Hennlich, BMW AG: extension for component model
 *******************************************************************************/
package org.franca.compdeploymodel.dsl.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.franca.compdeploymodel.core.FDModelUtils
import org.franca.compdeploymodel.core.PropertyMappings
import org.franca.compdeploymodel.dsl.fDeploy.FDArgument
import org.franca.compdeploymodel.dsl.fDeploy.FDArgumentList
import org.franca.compdeploymodel.dsl.fDeploy.FDArray
import org.franca.compdeploymodel.dsl.fDeploy.FDAttribute
import org.franca.compdeploymodel.dsl.fDeploy.FDBroadcast
import org.franca.compdeploymodel.dsl.fDeploy.FDComAdapter
import org.franca.compdeploymodel.dsl.fDeploy.FDComponent
import org.franca.compdeploymodel.dsl.fDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.fDeploy.FDCompoundOverwrites
import org.franca.compdeploymodel.dsl.fDeploy.FDDevice
import org.franca.compdeploymodel.dsl.fDeploy.FDElement
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumType
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumValue
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumeration
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumerationOverwrites
import org.franca.compdeploymodel.dsl.fDeploy.FDField
import org.franca.compdeploymodel.dsl.fDeploy.FDInterface
import org.franca.compdeploymodel.dsl.fDeploy.FDInterfaceInstance
import org.franca.compdeploymodel.dsl.fDeploy.FDMethod
import org.franca.compdeploymodel.dsl.fDeploy.FDModel
import org.franca.compdeploymodel.dsl.fDeploy.FDOverwriteElement
import org.franca.compdeploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.compdeploymodel.dsl.fDeploy.FDProperty
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyFlag
import org.franca.compdeploymodel.dsl.fDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.fDeploy.FDProvider
import org.franca.compdeploymodel.dsl.fDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.fDeploy.FDRootElement
import org.franca.compdeploymodel.dsl.fDeploy.FDService
import org.franca.compdeploymodel.dsl.fDeploy.FDStruct
import org.franca.compdeploymodel.dsl.fDeploy.FDTypeOverwrites
import org.franca.compdeploymodel.dsl.fDeploy.FDTypedef
import org.franca.compdeploymodel.dsl.fDeploy.FDTypes
import org.franca.compdeploymodel.dsl.fDeploy.FDUnion
import org.franca.compdeploymodel.dsl.fDeploy.FDVariant
import org.franca.compdeploymodel.dsl.fDeploy.FDeployPackage
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType

import static extension org.eclipse.xtext.scoping.Scopes.*
import static extension org.franca.compdeploymodel.core.FDModelUtils.*
import static extension org.franca.core.FrancaModelExtensions.*

class FDeployScopeProvider extends AbstractDeclarativeScopeProvider {

	@Inject
	private IQualifiedNameProvider qualifiedNameProvider

	@Inject
	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider
	
	@Inject DeploySpecProvider deploySpecProvider;
	@Inject IQualifiedNameConverter qnConverter;
	
	def scope_FDRootElement_spec(EObject ctxt, EReference ref){
		return delegateGetScope(ctxt,ref).joinImportedDeploySpecs(ctxt);
	}	
		
	def scope_FDSpecification_base(EObject ctxt, EReference ref){
		return delegateGetScope(ctxt,ref).joinImportedDeploySpecs(ctxt);
	}
	
	/** Evaluates the importedAliases of the FDModel containing the <i>ctxt</i> 
	 * and adds the belonging <i>FDSpecification</i>s to the given scope. */
	def joinImportedDeploySpecs(IScope scope, EObject ctxt){
		val model = EcoreUtil2::getContainerOfType(ctxt, typeof(FDModel))
		val importedAliases = model.imports.filter[importedSpec!==null].map[importedSpec]
		val List<IEObjectDescription> fdSpecsScopeImports = <IEObjectDescription>newArrayList;
		try { 
			for(a:importedAliases){
				val entry = deploySpecProvider.getEntry(a)
				if(entry?.FDSpecification !== null){
					fdSpecsScopeImports.add(new EObjectDescription(qnConverter.toQualifiedName(a),entry.FDSpecification,null));
				}
			}
		} catch(Exception e) { e.printStackTrace}
		return new SimpleScope(scope,fdSpecsScopeImports,false)
	}

	def scope_FDTypes_target(FDTypes ctxt, EReference ref) {	
		return new FTypeCollectionScope(IScope::NULLSCOPE, false, importUriGlobalScopeProvider, ctxt.eResource, qualifiedNameProvider);
	} 

	def scope_FDArray_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}

	def scope_FDStruct_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}

	def scope_FDEnumeration_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def scope_FDTypedef_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FTypeDef))
	}

	def private getScopes(FDTypes ctxt, Class<? extends EObject> clazz) {
		ctxt.getTarget().getTypes().filter(clazz).scopeFor
	}

	// *****************************************************************************
	def scope_FDAttribute_target(FDInterface ctxt, EReference ref) {
		ctxt.target.interfaceInheritationSet.map[attributes].flatten.scopeFor
	}

	def scope_FDMethod_target(FDInterface ctxt, EReference ref) {
		ctxt.target.interfaceInheritationSet.map[methods].flatten.scopeFor(
			[ QualifiedName.create(getUniqueName) ],
			IScope.NULLSCOPE
		)
	}

	def scope_FDBroadcast_target(FDInterface ctxt, EReference ref) {
		ctxt.target.interfaceInheritationSet.map[broadcasts].flatten.scopeFor(
			[ QualifiedName.create(getUniqueName) ],
			IScope.NULLSCOPE
		)
	}

	def scope_FDArray_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}

	def scope_FDStruct_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}

	def scope_FDEnumeration_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def scope_FDTypedef_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FTypeDef))
	}

	def private getScopes(FDInterface ctxt, Class<? extends EObject> clazz) {
		//ctxt.getTarget().getTypes().filter(clazz).scopeFor
		ctxt.target.interfaceInheritationSet.map[types].flatten.filter(clazz).scopeFor
	}

	// *****************************************************************************
	def scope_FDArgument_target(FDArgumentList ctxt, EReference ref) {
		val owner = ctxt.eContainer
		switch (owner) {
			FDMethod: {
				if (ctxt == owner.inArguments)
					owner.target.inArgs.scopeFor
				else
					owner.target.outArgs.scopeFor
			}
			FDBroadcast: {
				owner.target.outArgs.scopeFor
			}
		}
	}
	
	def scope_FDArgument_target(FDBroadcast ctxt, EReference ref) {
		ctxt.getTarget().getOutArgs.scopeFor
	}
		
	def scope_FDField_target(FDStruct ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	def scope_FDField_target(FDUnion ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	/**
	 * Compute the target elements (of type FField) for a given FDField,
	 * if the FDField is a child of a FDCompoundOverwrites section.</p>
	 * 
	 * I.e., ctxt will be either a struct overwrite section or a union
	 * overwrite section. The actual available fields depend on the 
	 * Franca type of the target element of the overwrite section's parent.
	 */
	def scope_FDField_target(FDCompoundOverwrites ctxt, EReference ref) {
		val parent = ctxt.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			if (type instanceof FCompoundType) {
				return type.elements.scopeFor
			}
		}
		IScope.NULLSCOPE
	}

	def scope_FDEnumValue_target(FDEnumeration ctxt, EReference ref) {
		ctxt.getTarget().getEnumerators.scopeFor
	}

	/**
	 * Compute the target elements (of type FEnumValue) for a given FDEnumValue,
	 * if the FDEnumValue is a child of a FDEnumerationOverwrites section.</p>
	 * 
	 * The actual available enumerators depend on the Franca type of the
	 * target element of the overwrite section's parent.
	 */
	def scope_FDEnumValue_target(FDEnumerationOverwrites ctxt, EReference ref) {
		val parent = ctxt.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			if (type instanceof FEnumerationType) {
				return type.enumerators.scopeFor
			}
		}
		IScope.NULLSCOPE
	}

	// *****************************************************************************
	def scope_FDProperty_decl(FDProvider owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDInterfaceInstance owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDService owner, EReference ref) {
		owner.getPropertyDecls
	}
		
	def scope_FDProperty_decl(FDDevice owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDComAdapter owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDVariant owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDRequiredPort owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDProvidedPort owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDInterface owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDTypes owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDAttribute owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDMethod owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDBroadcast owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDArgument owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDArray owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDStruct owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDUnion owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDField owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDEnumeration owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDEnumValue owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDTypedef owner, EReference ref) {
		owner.getPropertyDecls
	}

	/**
	 * The properties of an overwrite section are determined by the
	 * Franca type of the parent element (i.e., container element in
	 * the deployment definition model hierarchy).</p>
	 * 
	 * Example: In a  section, the parent element
	 * might be for example a FDAttribute. Validation will ensure that
	 * the Franca type of the FDAttribute target (which is an FAttribute)
	 * is an FStructType. Thus, the properties we are looking for here
	 * are all struct-related properties from the deployment specification.</p>    
	 */
	def scope_FDProperty_decl(FDTypeOverwrites owner, EReference ref) {
		val parent = owner.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			parent.getPropertyDecls(type)
		} else {
			IScope::NULLSCOPE
		}
	}

	def private IScope getPropertyDecls(FDElement elem) {
		var root = FDModelUtils::getRootElement(elem)
		if (root.spec === null)
			root = FDModelUtils::getRootElement(root.eContainer as FDElement)
		PropertyMappings::getAllPropertyDecls(root.getSpec, elem).scopeFor
	}

	def private IScope getPropertyDecls(FDElement some, FType elem) {
		var root = FDModelUtils::getRootElement(some)
		if (root.spec === null)
			root = FDModelUtils::getRootElement(root.eContainer as FDElement)
		PropertyMappings::getAllPropertyDecls(root.getSpec, elem).scopeFor
	}

	// *****************************************************************************
	// Fidl ref to constant
	
	def scope_FDConstantDefRef_value(FDProperty prop, EReference ref) {
		val host = prop.eContainer.eContainer
		val FDModel fdmodel = FDModelUtils.getModel(host)
		if (propertyIsTyped(prop )) {
			if (host instanceof FDAttribute) {
	 			if (host.target !== null && host.target.type.derived !== null) 
					return scopehelper_FDConstantDefRef(fdmodel, host.target.type.derived)
			}
			if (host instanceof FDField) {
	 			if (host.target !== null && host.target.type.derived !== null) 
					return scopehelper_FDConstantDefRef(fdmodel, host.target.type.derived)
			}
			if (host instanceof FDArray) {
				if (host.target !== null && host.target.elementType !== null) 
					return scopehelper_FDConstantDefRef(fdmodel, host.target)
			}
		}
		return delegateGetScope(prop, ref)
	}
	
	private def propertyIsTyped(FDProperty prop) {
		prop.decl.flags.exists[typed !== null] 
	}

	def scopehelper_FDConstantDefRef(FDModel fdmodel, FType derivedType) {
		// look in all resources stored with the resourceSet containing this model
		val resources = fdmodel.eResource.resourceSet.resources
		val usedResources = resources.filter[ contents.get(0) instanceof FModel ]				
		val HashSet<FConstantDef> consts = newHashSet(null)
		usedResources.forEach[ consts += allContents.filter(FConstantDef).toList ]
		val derivedConsts = consts.filter[type.derived == derivedType]
		return derivedConsts.scopeFor(qualifiedNameProvider, IScope.NULLSCOPE)
	}
	
	// *****************************************************************************
	// scope for enumerator, if property host type is enum	
	def scope_FDEnumeratorRef_value(FDEnumerationOverwrites elem, EReference ref) {
		val parent = elem.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			if (type instanceof FEnumerationType) {
				val scope = type.enumerators.scopeFor(qualifiedNameProvider, IScope.NULLSCOPE)
				return scope
			}
		}
		IScope::NULLSCOPE
	}
	
	def scope_FDEnumeratorRef_value(FDField field, EReference ref) {
		val type = field.target.type.derived
		if (type!==null) {
			if (type instanceof FEnumerationType) {
				val scope = type.enumerators.scopeFor(qualifiedNameProvider, IScope.NULLSCOPE)
				return scope
			}
		}
		IScope::NULLSCOPE
	}
	
	// *****************************************************************************
	// ports in scope of a component
	
	def scope_FDRequiredPort_target(FDComponent comp, EReference ref) {
		val List<FCPort> ports = newArrayList
		FCompUtils::collectInheritedPorts(comp.target, FCPortKind.REQUIRED, ports)
		ports.scopeFor
	}
	
	def scope_FDProvidedPort_target(FDComponent comp, EReference ref) {
		val List<FCPort> ports = newArrayList
		FCompUtils::collectInheritedPorts(comp.target, FCPortKind.PROVIDED, ports)
		ports.scopeFor
	}
	
	// *****************************************************************************
	// ports in scope of a service
	
	def scope_FDRequiredPort_target(FDService service, EReference ref) {
		val List<FCPort> ports = newArrayList
		var FCComponent component = null
		val FDComponentInstance instance = service.target
		if (instance.target !== null)
			component = instance.target
		else
			component = instance.prototype.component
		FCompUtils::collectInheritedPorts(component, FCPortKind.REQUIRED, ports)
		ports.scopeFor
	}
	
	def scope_FDProvidedPort_target(FDService service, EReference ref) {
		val List<FCPort> ports = newArrayList
		var FCComponent component = null
		val FDComponentInstance instance = service.target
		if (instance.target !== null)
			component = instance.target
		else
			component = instance.prototype.component
		FCompUtils::collectInheritedPorts(component, FCPortKind.PROVIDED, ports)
		ports.scopeFor
	}

	// *****************************************************************************
	// simple type system

	def scope_FDGeneric_value(FDPropertyFlag elem, EReference ref) {
		val decl = elem.eContainer as FDPropertyDecl
		decl.getPropertyDeclGenericScopes(decl, ref)
	}

	def scope_FDGeneric_value(FDProperty elem, EReference ref) {
		elem.getDecl.getPropertyDeclGenericScopes(elem, ref)
	}

	def private IScope getPropertyDeclGenericScopes(
		FDPropertyDecl decl,
		EObject ctxt,
		EReference ref
	) {
		val typeRef = decl.getType
		if (typeRef.getComplex !== null) {
			val type = typeRef.getComplex
			if (type instanceof FDEnumType) {
				return type.getEnumerators.scopeFor
			}
		} else {
			if (typeRef.predefined==FDPredefinedTypeId::INSTANCE) {
				return new SimpleScope(Scopes::selectCompatible(
					delegateGetScope(ctxt, ref).allElements,
					FDeployPackage::eINSTANCE.FDInterfaceInstance
				))
			}
		}
		IScope::NULLSCOPE
	}
	
	// *******************************************************************************************
	
	/**
	 * Component Instance starting point scoping: limit to root components
	 */
	def IScope scope_FDComponentInstance_target(FDService service, EReference ref) {
		
		val List<IEObjectDescription> rootComponents = <IEObjectDescription>newArrayList
		for (od: delegateGetScope(service, ref).allElements) {
			val comp = od.EObjectOrProxy
			if (comp instanceof FCComponent) {
				if (comp.root)
					rootComponents.add(new EObjectDescription(qnConverter.toQualifiedName(comp.name), comp, null))
			}
		}
		val scope = new SimpleScope(rootComponents)
		// dump(scope, "scope_FDComponentInstance_target")
		scope
	}

	/**
	 * Component Instance segments scoping
	 * Path contains only non-abstract components
	 */
    def IScope scope_FDComponentInstance_prototype(FDComponentInstance compInst, EReference ref) {
		val parent = compInst.parent
		if(parent === null)
			return IScope.NULLSCOPE
			
		var ArrayList<FCGenericPrototype> candidates = newArrayList()
		if (parent.prototype === null && parent.target !== null) {
			FCompUtils.collectInheritedPrototypes(parent.target, candidates)
		} 
		else {
			FCompUtils.collectInheritedPrototypes(parent.prototype.component, candidates)
		} 
		val scope = candidates.filter[component.abstract == false].scopeFor	
		// dump(scope, "scope_FDComponentInstance_prototype")
		scope
	}
	
	/**
	 * Limit scope to service for use on a device
	 */
	def IScope scope_FDRootElement_use(FDDevice device, EReference ref) {

		val IScope delegateScope = delegateGetScope(device, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDService
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	/**
	 * Limit scope to adapter defined for the given device 
	 */
	def IScope scope_FDComAdapter_target(FDDevice device, EReference ref) {
		if (device.adapters !== null) {
			val scope = device.target.adapters.scopeFor
			return scope
		}
		IScope::NULLSCOPE
	}
	
	/**
	 * Limit scope to devices with services matching the given root in the context of a variant
	 */
	def IScope scope_FDRootElement_use(FDVariant variant, EReference ref) {

		val IScope delegateScope = delegateGetScope(variant, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				od.EObjectOrProxy instanceof FDDevice 
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	/**
	 * Scope roots in the context of a variant
	 */
	def IScope scope_FDVariant_root(FDVariant variant, EReference ref) {

		val List<IEObjectDescription> rootComponents = <IEObjectDescription>newArrayList
		for (od: delegateGetScope(variant, ref).allElements) {
			val comp = od.EObjectOrProxy
			if (comp instanceof FCComponent) {
				if (comp.root)
					rootComponents.add(new EObjectDescription(qnConverter.toQualifiedName(comp.name), comp, null))
			}
		}
		val scope = new SimpleScope(rootComponents)
		// dump(scope, "scope_FDComponentInstance_target")
		scope
	}
	
	
	/**
	 * Limit scope to provided ports defined for used services the context of an adapter of a device
	 */
	def IScope scope_FDRootElement_use(FDComAdapter adapter, EReference ref) {
		if (adapter.eContainer instanceof FDDevice) {
			val pPorts = (adapter.eContainer as FDDevice).use.filter(FDService).map[providedPorts].flatten
			val rPorts = (adapter.eContainer as FDDevice).use.filter(FDService).map[requiredPorts].flatten
			val IScope delegateScope = delegateGetScope(adapter, ref)
			val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
				override boolean apply(IEObjectDescription od) {
					val port = od.EObjectOrProxy
					if (port instanceof FDProvidedPort)
						pPorts.exists[it == port && haveCompatibleSpecs(adapter, port)]
					else if (port instanceof FDRequiredPort)
						rPorts.exists[it == port && haveCompatibleSpecs(adapter, port)]
					else 
						false
				}
			}
			new FilteringScope(delegateScope, filter)
		}
		else
			IScope::NULLSCOPE
	}
	
	/**
	 * Limit scope to deployed type collections in an interface deployment context
	 */
	def IScope scope_FDRootElement_use(FDInterface fdif, EReference ref) {
		val IScope delegateScope = delegateGetScope(fdif, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDTypes
			}
		}
		new FilteringScope(delegateScope, filter)
	}	
	
	
	/**
	 * Limit scope for component to compatible components deployments in a service context
	 */
	def IScope scope_FDRootElement_use(FDService service, EReference ref) {
		val componentType = service.target.prototype?.component ?: service.target.target
		val IScope delegateScope = delegateGetScope(service, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof FDComponent)
					obj.target == componentType
				else 
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}	
	
	/**
	 * Limit scope to components deployments in a component context
	 */
	def IScope scope_FDRootElement_use(FDComponent component, EReference ref) {
		val IScope delegateScope = delegateGetScope(component, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDComponent
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	/**
	 * Limit scope to types deployments in a typeCollection context
	 */
	def IScope scope_FDRootElement_use(FDTypes types, EReference ref) {
		val IScope delegateScope = delegateGetScope(types, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				od.EObjectOrProxy instanceof FDTypes
			}
		}
		new FilteringScope(delegateScope, filter)
	}	
	
	
	/**
	 * Scope available interface deployments in required port deployment to fitting interfaces
	 */
	def IScope scope_FDRootElement_use(FDRequiredPort port, EReference ref) {
		val FInterface interfaceType = port.target.interface
		val IScope delegateScope = delegateGetScope(port, ref)
		filterInterfaceForPort(port, delegateScope, interfaceType)	
	}
	
	/**
	 * Scope available interface deployments in provided port deployment to fitting interfaces
	 */
	def IScope scope_FDRootElement_use(FDProvidedPort port, EReference ref) {
		val FInterface interfaceType = port.target.interface
		val IScope delegateScope = delegateGetScope(port, ref)
		filterInterfaceForPort(port, delegateScope, interfaceType)
	}
	
	private def IScope filterInterfaceForPort(FDRootElement port, IScope delegateScope, FInterface interfaceType) {
		val inheritedInterfaces = interfaceType.interfaceInheritationSet
		
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val object = od.EObjectOrProxy
				if (object instanceof FDInterface)
					inheritedInterfaces.contains(object.target) 
					&& haveCompatibleSpecs(port, object) 
				else 
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	/*
	 * Compatible means either a childs spec parent and child reference the same spec 
	 * or child spec is derived from parent spec.
	 */
	def private haveCompatibleSpecs (FDRootElement parent, FDRootElement child) {
		var parentSpec = parent.spec
		if (parentSpec === null)
			parentSpec = getRootElement(parent.eContainer as FDElement)?.spec
		
		var check = child.spec
		if (check === null)
			check = getRootElement(child.eContainer as FDElement)?.spec
		
		while (check !== null) {
			if (parentSpec == check)
				return true
			check = check.base
		} 
		return false
	}
	
//	def private dump(IScope s, String tag) {
//		println("    " + tag)
//		for (e : s.allElements) {
//			println("        " + e.name + " = " + e.EObjectOrProxy)
//		}
//	}
}
