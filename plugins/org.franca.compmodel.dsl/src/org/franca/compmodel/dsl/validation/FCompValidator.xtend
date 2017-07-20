/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.validation

import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCLabelKind
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototype

import static org.franca.compmodel.dsl.fcomp.FcompPackage.Literals.*
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype

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
		if (true == proto.component.labels.map[kind].contains(FCLabelKind.SINGLETON.value)) {
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
}
