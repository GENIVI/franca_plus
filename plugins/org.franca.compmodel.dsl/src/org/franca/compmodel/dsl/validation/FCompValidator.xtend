/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.validation

import java.util.List
import javax.inject.Inject
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
import org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider
import org.franca.compmodel.dsl.validation.internal.ValidatorRegistry
import org.franca.core.FrancaModelExtensions

import static org.franca.compmodel.dsl.fcomp.FcompPackage.Literals.*

import static extension java.lang.String.format

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class FCompValidator extends AbstractFCompValidator {
	public static val NOT_EXPOSED = "notExposed"
	public static val DUPLICATE_CONNECTOR = "duplicateConnector"

	public final static String DUPLICATION_OF_DELEGATES_IS_NOT_ALLOWED = "Duplication of delegates is not allowed."
	public final static String REQUIRED_DELEGATE_MUST_NOT_CONNECT_TO_DIFFERENT_OUTER = "Required delegate must not connect to different outer '%s'."
	public final static String DUPLICATE_PROVIDED_DELEGATE_OUTER_TO = "Duplicate provided delegate outer to '%s.%s'."
	public final static String DUPLICATE_PROVIDED_DELEGATE_INNER_FROM = "Duplicate provided delegate inner from '%s'."
	public final static String ASSEMBLY_PORT_ALREADY_CONNECTED_TO = "Port already assembly connected to '%s.%s'."
	public final static String DUPLICATION_OF_ASSEMBLY_CONNECTORS_IS_NOT_ALLOWED = "Duplication of assembly connectors is not allowed."
	public final static String ASSEMBLY_AND_DELEGATE_CONNECTOR_IS_NOT_ALLOWED = "Required port '%s.%s' must not be delegate and assembly connected at the same time."
	public final static String DUPLICATE_CONTAINMENT_FOR_SINGLETON = "Duplicate containment for singleton '%s'."
	public final static String PROTOTYPE_EXISTS_ALREADY = "Prototype exists already: '%s'."
	public final static String COMPONENT_NAME_MUST_BE_UNIQUE = "Component name must be unique '%s'."
	public final static String NO_NAMESPACE_SEPARATORS_ALLOWED_IN = "No name space separators allowed in '%s'. Implicit port name must be simple name."
	public final static String COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_COMPONENT = "Component '%s' must not contain prototype of its own type."
	public final static String COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_PARENT_COMPONENT = "Component '%s' must not contain prototype of super component '%s'."
	public final static String REQUIRED_PORT_IS_NEITHER_CONNECTED_NOR_DELEGATED = "Required port '%s.%s' is neither connected nor delegated."
	public final static String PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT = "Provided port '%s' can be delegated to port '%s.%s'."
	public final static String INHERITED_PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT = "Inherited provided port '%s' can be delegated to port '%s.%s'."
	public final static String PORT_EXISTS_ALREADY = "Port exists already: '%s'."

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
			error(DUPLICATION_OF_DELEGATES_IS_NOT_ALLOWED, dc, FC_DELEGATE_CONNECTOR__OUTER)
			return
		}
		
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.REQUIRED &&
				it.inner.port == dc.inner.port && 
				it.inner.prototype == dc.inner.prototype && 
				it.outer.port != dc.outer.port] 
		if (found !== null) {
			error(REQUIRED_DELEGATE_MUST_NOT_CONNECT_TO_DIFFERENT_OUTER.format(found.outer.port.name), dc, FC_DELEGATE_CONNECTOR__INNER)
			return
		}	
		
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.PROVIDED &&
				it.outer.port == dc.outer.port] 
		if (found !== null) {
			error(DUPLICATE_PROVIDED_DELEGATE_OUTER_TO.format(found.inner.prototype.name, found.inner.port.name), dc, FC_DELEGATE_CONNECTOR__OUTER)
			return
		}	
			
		found = comp.delegates.findFirst[
				it != dc && 
				it.kind == FCPortKind.PROVIDED &&
				it.inner.prototype == dc.inner.prototype && 
				it.inner.port == dc.inner.port ] 
		if (found !== null) {
			error(DUPLICATE_PROVIDED_DELEGATE_INNER_FROM.format(found.outer.port.name), dc, FC_DELEGATE_CONNECTOR__OUTER)
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
			error(ASSEMBLY_PORT_ALREADY_CONNECTED_TO.format(found.to.prototype.name, found.to.port.name), ac, FC_ASSEMBLY_CONNECTOR__FROM) 	
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
			error(DUPLICATION_OF_ASSEMBLY_CONNECTORS_IS_NOT_ALLOWED, ac, FC_ASSEMBLY_CONNECTOR__FROM)	
		}
	}
	
	@Check
	def delegateAndAssemblyATheSameTime(FCAssemblyConnector ac) {
		if (ac.from?.port === null || ac.to?.prototype === null)
			return
		
		val comp = FCompUtils.getComponentForObject(ac)		
		val delegate = comp.delegates.findFirst[inner.prototype == ac.from.prototype &&	inner.port == ac.from.port]
			
		if (delegate !== null) 
			error(ASSEMBLY_AND_DELEGATE_CONNECTOR_IS_NOT_ALLOWED.format(ac.from.prototype.name, ac.from.port.name), ac.from, FC_FROM__PORT)
	}
	
	@Check
	def assemblyAndDelegateATheSameTime(FCDelegateConnector dc) {
		if (dc.inner?.port === null || dc.inner?.prototype === null)
			return
		
		val comp = FCompUtils.getComponentForObject(dc)		
		val assembly = comp.assembles.findFirst[from.prototype == dc.inner.prototype &&	from.port == dc.inner.port]
			
		if (assembly !== null) {
			error(ASSEMBLY_AND_DELEGATE_CONNECTOR_IS_NOT_ALLOWED.format(dc.inner.prototype.name, dc.inner.port.name), dc.inner, FC_INNER__PORT)
		}
	}
	
	@Check
	def isSingleton(FCPrototype proto) {
		if (true == proto.component.singleton == true) {
			val allCompRefs = EcoreUtil2.getRootContainer(proto).eAllContents.filter(FCPrototype)
			if (allCompRefs.exists[it != proto && it.component == proto.component]) {
				error(DUPLICATE_CONTAINMENT_FOR_SINGLETON.format(proto.component.name), proto, 
					FC_GENERIC_PROTOTYPE__COMPONENT)
			}
		}
	}
	
	@Inject FCompDeclarativeNameProvider nameProvider
	
	@Check 
	def uniquePortNames(FCPort port) {
		val comp = FCompUtils.getComponentForObject(port)
		
		val List<FCPort> ports = newArrayList
		FCompUtils::collectInheritedPorts(comp, FCPortKind.REQUIRED, ports)
		FCompUtils::collectInheritedPorts(comp, FCPortKind.PROVIDED, ports)
		
		var index = 0 
		for (pp: ports.filter[it != port && name == port.name]) {
 			error(PORT_EXISTS_ALREADY.format(nameProvider.getFullyQualifiedName(pp)), port, FC_PORT__NAME, index++)	
		}
	}

	@Check 
	def uniqueComponentRefNames(FCGenericPrototype proto) {
		val List<FCGenericPrototype> protos = newArrayList
		FCompUtils::collectInheritedPrototypes(FCompUtils.getComponentForObject(proto), protos)
		protos.filter[it != proto && name == proto.name].forEach [
 			error(PROTOTYPE_EXISTS_ALREADY.format(nameProvider.getFullyQualifiedName(it)), proto, 
					FC_GENERIC_PROTOTYPE__NAME)	
		]
	}	
	
	@Check 
	def uniqueComponentNames(FCComponent comp) {
		val allComps = EcoreUtil2.getRootContainer(comp).eAllContents.filter(FCComponent)
		if (allComps.exists[it != comp && name == comp.name])
 			error(COMPONENT_NAME_MUST_BE_UNIQUE.format(comp.name), comp, FC_COMPONENT__NAME)	
	}
	
	@Check 
	def simpleNameForImplicitPortName(FCPort port) {
		if (port.name.contains("."))
		 	error(NO_NAMESPACE_SEPARATORS_ALLOWED_IN.format(port.name), port, FC_PORT__NAME)	
	}
	
	@Check
	def selfContainment(FCPrototype proto) {
		val protoComponentType = proto.component
		var parentComponent = proto.eContainer as FCComponent
		val parentComponentName = parentComponent.name
		
		if (parentComponent == protoComponentType) 
			error(COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_COMPONENT.format(parentComponentName), proto, FC_GENERIC_PROTOTYPE__COMPONENT)
			
		do {
			if(parentComponent.superType == protoComponentType)
				error(COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_PARENT_COMPONENT.format(parentComponentName, parentComponent.superType.name), proto, FC_GENERIC_PROTOTYPE__COMPONENT)
			parentComponent = parentComponent.superType
		} while(parentComponent.superType !== null)
	}
	
   /**
	* Prototypes within a Component (container) shall be connect correctly.
	* A container contains prototypes:
	* For all required ports of the prototypes must be connected either to a providing prototype or a required port of the container.
	* All provided ports of the container shall be connected to a provided port of a prototype if they have matching interfaces.
	*/

	@Check
	def allRequiredPortsConnected(FCComponent component) {
		
		for (proto: component.prototypes + component.injections) {
			val List<FCPort> reqPorts = newArrayList
			FCompUtils::collectInheritedPorts(proto.component, FCPortKind.REQUIRED, reqPorts)
			for (reqPort: reqPorts.filter(FCRequiredPort)) {				
				if (reqPort.cardinality == false) {
					if ((component.assembles === null || ! component.assembles.exists[from.prototype == proto && from.port == reqPort] ) &&
						(component.delegates === null || ! component.delegates.exists[inner.prototype == proto && inner.port == reqPort])) {
						error(REQUIRED_PORT_IS_NEITHER_CONNECTED_NOR_DELEGATED.format(proto.name, reqPort.name), proto, FC_GENERIC_PROTOTYPE__COMPONENT)
					}
				}
			}
		}
	}
	
	@Check
	def allProvidedPortsConnected(FCComponent component) {
		
		val List<FCPort> provPorts = newArrayList
		FCompUtils::collectInheritedPorts(component, FCPortKind.PROVIDED, provPorts)
		val List<FCGenericPrototype> protos = newArrayList
		FCompUtils::collectInheritedPrototypes(component, protos)
		
		var index = 1
		
		for (proto: protos) {
			for (provPort: provPorts) {
				val List<FCPort> provProtoPorts = newArrayList
				FCompUtils::collectInheritedPorts(proto.component, FCPortKind.PROVIDED, provProtoPorts)
				for (provProtoPort: provProtoPorts) {
					// at least one contained prototype offers the same interface or a derived one				
					if (FrancaModelExtensions::getInterfaceInheritationSet(provProtoPort.interface).contains(provPort.interface)) {
						// probably the port should be delegated
						if (component.delegates === null || ! component.delegates.exists[outer.port == provPort]) {
							if (component.prototypes.contains(proto))
								info(PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format(provPort.name, proto.name, provProtoPort.name), proto, FC_GENERIC_PROTOTYPE__NAME)
							else if (component.providedPorts.contains(provPort))
								info(PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format(provPort.name, proto.name, provProtoPort.name), provPort, FC_PORT__NAME)
							else if (component.superType !== null )
								info(INHERITED_PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format(provPort.name, proto.name, provProtoPort.name), component, FC_COMPONENT__SUPER_TYPE, index++)
						}	
					}
				}
			}
		}
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
}
