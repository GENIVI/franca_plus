/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.validation

import java.util.HashSet
import java.util.Set
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCRequiredPort
import org.franca.compmodel.dsl.validation.internal.ValidatorRegistry

import static org.franca.compmodel.dsl.fcomp.FcompPackage.Literals.*

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class FCompValidator extends AbstractFCompValidator {
  public static val NOT_EXPOSED = 'notExposed'
  public static val DUPLICATE_CONNECTOR = 'ducplicateConnector'
  	
	@Check
	def duplicateDelegateOuter(FCDelegateConnector dc) {
		if (dc.outer?.port === null || 
			dc.inner?.prototype === null || 
			dc.inner?.port === null)
			return
		
		val comp = FCompUtils.getComponentForObject(dc)
		var found = comp.delegates.findFirst[
				it != dc && 
				it.inner.port == dc.inner.port &&
				it.inner.prototype == dc.inner.prototype && 
				it.outer.port == dc.outer.port] 
		if (found !== null) {
			error('Duplication of delegates is not allowed', dc, FC_DELEGATE_CONNECTOR__OUTER)
			return
		}
		
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.REQUIRED &&
				it.inner.port == dc.inner.port && 
				it.inner.prototype == dc.inner.prototype && 
				it.outer.port != dc.outer.port] 
		if (found !== null) {
			error('Required delegate must not connect to different outer \'' + found.outer.port.name + '\'', dc, FC_DELEGATE_CONNECTOR__INNER)
			return
		}	
		
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.PROVIDED &&
				it.outer.port == dc.outer.port] 
		if (found !== null) {
			error('Duplicate provided delegate outer to \'' + found.inner.prototype.name + '.' + found.inner.port.name + '\'', dc, FC_DELEGATE_CONNECTOR__OUTER)
			return
		}	
			
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.PROVIDED &&
				it.inner.prototype == dc.inner.prototype && 
				it.inner.port == dc.inner.port ] 
		if (found !== null) {
			error('Duplicate provided delegate inner from \'' + found.outer.port.name + '\'', dc, FC_DELEGATE_CONNECTOR__OUTER)
			return
		}		
	}
	
	@Check
	def duplicateAssemblyFromConnector(FCAssemblyConnector ac) {
		if (ac.from === null || ac.from.prototype === null) 
			return
		
		val comp = FCompUtils.getComponentForObject(ac)
		val found = comp.assembles.findFirst[
				it != ac && 
				it.from.prototype == ac.from.prototype && 
				it.from.port == ac.from.port ]
		if (found !== null) 
			error('Assembly port already connected to \'' + found.to.prototype.name + '.' + found.to.port.name + '\'', ac, FC_ASSEMBLY_CONNECTOR__FROM) 	
	}
	
	@Check
	def duplicateAssembly(FCAssemblyConnector ac) {
		if (ac.from?.port === null || ac.to?.prototype === null || ac.to?.port === null)
			return
		
		val comp = FCompUtils.getComponentForObject(ac)		
		if (true == comp.assembles.exists[
				it != ac && 
				it.from.prototype == ac.from.prototype &&
				it.from.port == ac.from.port]) {
			error('Duplication of assembly connectors is not allowed', ac, FC_ASSEMBLY_CONNECTOR__FROM)	
		}
	}
	
	@Check
	def isSingleton(FCPrototype proto) {
		if (true == proto.component.singleton == true) {
			val allCompRefs = EcoreUtil2.getRootContainer(proto).eAllContents.filter(FCPrototype)
			if (allCompRefs.exists[it != proto && it.component == proto.component]) {
				error('Duplicate containment for singleton \'' + proto.component.name + '\'', proto, 
					FC_GENERIC_PROTOTYPE__COMPONENT)
			}
		}
	}
	
	@Check 
	def uniquePortNames(FCPort port) {
		val comp = FCompUtils.getComponentForObject(port)
		if (comp.providedPorts.exists[it != port && name == port.name] || 	
			comp.requiredPorts.exists[it != port && name == port.name])
 				error('Port name must be unique \'' + port.name + '\'', port, 
					FC_PORT__NAME)	
	}

	@Check 
	def uniqueComponentRefNames(FCGenericPrototype proto) {
		val comp = FCompUtils.getComponentForObject(proto)
		if (comp.prototypes.filter(FCPrototype).exists[it != proto && name == proto.name])
 				error('Component alias must be unique \'' + proto.name + '\'', proto, 
					FC_GENERIC_PROTOTYPE__NAME)	
	}	
	
	@Check 
	def uniqueComponentNames(FCComponent comp) {
		val allComps = EcoreUtil2.getRootContainer(comp).eAllContents.filter(FCComponent)
		if (allComps.exists[it != comp && name == comp.name])
 				error('Component name must be unique \'' + comp.name + '\'', comp, 
					FC_COMPONENT__NAME)	
	}
	
	@Check 
	def simpleNameForImplicitPortName(FCPort port) {
		if (port.name.contains('.'))
		 	error('Implicit port name must be simple name. No namespace separators allowed in \'' + port.name + '\'', port, 
					FC_PORT__NAME)	
	}
	
	@Check
	def selfContainment(FCPrototype proto) {
		val protoType = proto.component
		var parentType = proto.eContainer as FCComponent
		
		if (parentType == protoType) 
			error('Component \'' + parentType.name + '\' must not contain prototype of component, which is already present in hierarchy', proto, 
					FC_GENERIC_PROTOTYPE__COMPONENT)
		// TODO: check for cyclic references from proto to components in parents 	
	}
	
		/**
	 * Call external validators (those have been installed via an
	 * Eclipse extension point).
	 */
	@Check
	def checkExtensionValidators(FCModel model) {
		val mode = getCheckMode();
		
		for (IFCompExternalValidator validator : ValidatorRegistry.getValidatorMap().get(mode))
			validator.validateModel(model, getMessageAcceptor())
	}
	
	/**
	 * Checks if each mandatory required port is either assembly connected or has a valid delegation connection to a providing port, which has to be typed by the same interface
	 */
	@Check
	def checkValidConnectionForMandatoryRequiredPorts(FCGenericPrototype prototype){
		
		val parentComponent = prototype.eContainer as FCComponent;
		val FCModel model = EcoreUtil2.getRootContainer(prototype) as FCModel;
		
		prototype.component.requiredPorts.filter(FCRequiredPort).filter[!it.cardinality].forEach[requiredPort |
			
			val assemblies = parentComponent.assembles.filter[it.from.prototype == prototype && it.from.port == requiredPort && it.to.port.interface == requiredPort.interface]
			if(assemblies.nullOrEmpty){
				
				val errorsForThisPort = new HashSet<String>()
				findErrorsInDelegationPath(model, parentComponent, prototype, requiredPort, errorsForThisPort)
				
				if(!errorsForThisPort.nullOrEmpty){
					warning('''Required port not properly connected. Delegation- or assembly-connector broken at: «FOR error : errorsForThisPort» «error» «ENDFOR»''', requiredPort, FC_REQUIRED_PORT__CARDINALITY)
				}
			}	
		]
	}
	
	/**
	 * Follows the "delegation connector path" for a given port. Errors will be added to the error list. 
	 * Will add no error if a valid assembly connection was found (providing port typed by same interface) or the delegation connection leads to a valid providing port 
	 */
	def private void findErrorsInDelegationPath(FCModel model, FCComponent component, FCGenericPrototype prototype, FCRequiredPort rPort, Set<String> errorsForThisPort){
		
		if(component === null || prototype === null || rPort === null){
			errorsForThisPort.add("Model error")
			return
		}
		
		val delegates = component.delegates.filter[it.inner.port == rPort && it.inner.prototype == prototype].toSet
		
		if(delegates.size == 0){
			val assemblies = component.assembles.filter[it.from.prototype == prototype && it.from.port == rPort && it.to.port.interface == rPort.interface]
			if(assemblies.size == 0)
				errorsForThisPort.add(prototype.name + "," + rPort.name)
		}
		else{
		
			delegates.forEach[del |
				val nextOuter = del.outer.port as FCRequiredPort
	
				val nextComponent = model.eAllContents.filter(FCGenericPrototype).filter[it.component  == component].head.eContainer as FCComponent
							
				var FCGenericPrototype nextPrototype = null;
				if(nextComponent !== null)
					nextPrototype = nextComponent.prototypes.filter[it.component == component].head
				
				findErrorsInDelegationPath(model, nextComponent, nextPrototype, nextOuter, errorsForThisPort)
			]
		}
		
	}
	
}
