/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.validation

import com.google.common.collect.Sets
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage
import org.franca.compdeploymodel.dsl.cDeploy.FDComAdapter
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.compdeploymodel.dsl.cDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compdeploymodel.dsl.cDeploy.FDPort
import org.franca.compdeploymodel.dsl.cDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.cDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.cDeploy.FDService
import org.franca.compdeploymodel.dsl.cDeploy.FDVariant
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage

import static extension java.lang.String.format
import static extension org.franca.compdeploymodel.dsl.CDeployUtils.*
import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.utils.CycleChecker.*

/**
 * This class contains custom validation rules for Component Model Deployment.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CDeployValidator extends AbstractCDeployValidator {
	
	public static final String COMPONENT_IS_NO_SERVICE = "Component is no service."
	public static final String CYCLIC_USE_RELATION_IN_ELEMENT = "Cyclic use-relation in element '%s'."
	public static final String SPECIFICATION_REQUIRES_MANDATORY_PROPERTY_FOR_ELEMENT = "Specification '%s' requires mandatory property %s."
	public static final String SPECIFICATION_REQUIRES_DEPLOYMENT_FOR_PORT = "Specification '%s' requires deployment for %s port %s."
	public static final String USAGE_OF_SERVICE_WITH_DERIVED_ROOT = "Usage of service with derived root in variant '%s'."
	public static final String DEVICE_CONTAINS_SERVICE_WITH_DERIVED_ROOT = "Device contains service '%s' with derived root."
	public static final String VARIANT_CONTAINS_SERVICES_WITH_INCOMPATIBLE_ROOT = "Variant contains services with incompatible root."
	public static final String USE_RELEATION_REFERS_TO_DEPLOYMENT_WITH_INCOMAPTIBLE_SPEC = "Use-relation '%s' refers to deployment with incompatible specification '%s'."
	public static final String DUPLICATE_DEPLOYMENT_OF_PORT= "Duplicate deployment for port '%s'."
	public static final String PORT_IS_ALREADY_DEPLOYED = "Port is already deployed."
	public static final String INCONSISTENT_INTERFACE_DEPLOYMENT_USE = "Inconsistent use of deployed interface '%s'. The use at the port conflicts with the use '%s' on component level."
	public static final String PORT_HAS_MULTIPLE_INTERFACE_DEPLOYMENTS = "Port has multiple interface deployments."
	public static final String SERVICE_IS_SINGLETON = "Service component '%s' is declared as singleton, but instantiated more than once."
	public static final String MULTIPLE_DEPLOYMENT_USE_FOR_INTERFACE = "For interface '%s' exist multiple deployment uses %s."
	
	
	/** 
	 * Check if a service target points to a component with stereotype <service>
	 * @param instance: component instance to check for being service
	 */
	@Check 
	def void checkComponentInstance4ServiceNature(FDService service) {
		if (service.target !== null && service.serviceComponent === null)
			error(COMPONENT_IS_NO_SERVICE, CDeployPackage.Literals.FD_SERVICE__TARGET) 
	}
	
	/** 
	 * Check if a service target points to a component with stereotype <service>
	 * @param instance: component instance to check for being service
	 */
	@Check 
	def void checkSingletons(FDVariant variant) {
		val HashSet<FCComponent> singles = newHashSet()
		var index = 0
		for (service: variant.use.filter(FDDevice).map[use].flatten.filter(FDService)) {
			val component = service.serviceComponent
			if (component.singleton) {
				if (singles.contains(component)) 
					error(SERVICE_IS_SINGLETON.format(component.name), CDeployPackage.Literals.FD_VARIANT__ROOT, index++) 
				else
					singles.add(component)
			}
		}
	}
	
	@Check
	override checkRootElement (FDRootElement it) {
		// for variants the check is not necessary 
		if (it instanceof FDVariant)
			return
			
		var FDSpecification rootSpec = null

		// Ports may inherit specification from parent object
		if (spec === null && eContainer instanceof FDRootElement)
			rootSpec = (eContainer as FDRootElement).spec
		else 
			rootSpec = spec
		
		// ensure that use-relation is non-cyclic 
		val path = isReferenced[e | e.use] 
		if (path !== null) {
			val idx = use.indexOf(path.get(0))
			error(CYCLIC_USE_RELATION_IN_ELEMENT.format(name),
				it, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE, idx)
		}
		
		// ensure that all use-relations are covered by a compatible deployment spec
		for(other : use) {
			if (!rootSpec.isCompatible(other.spec)) {
				error(USE_RELEATION_REFERS_TO_DEPLOYMENT_WITH_INCOMAPTIBLE_SPEC.format(other.name, other.spec.name),
					it, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE, use.indexOf(other))
			}
		}
	}

	// compatible means either same spec or a derived (i.e. more detailed) spec
	def private isCompatible (FDSpecification parentSpec, FDSpecification childSpec) {
		// we cannot do this check if there are cycles in the extend-relation
		if (childSpec.cyclicBaseSpec !== null) {
			// return true to avoid an additional error message, the cyclic-check
			// will issue an error.
			return true
		}
			
		var check = childSpec
		do {
			if (parentSpec == check)
				return true
			check = check.base
		} while (check!==null)
		
		return false
	}
	
	/**
	 * Check if extends-relation on FDSpecifications has cycles.
	 * 
	 * @returns FDSpecification which has an extends-cycle, null if the
	 *          extends-relation is cycle-free.
	 * */
	def private getCyclicBaseSpec(FDSpecification spec) {
		var Set<FDSpecification> visited = newHashSet
		var s = spec
		var FDSpecification last = null
		do {
			visited.add(s)
			last = s
			s = s.base
			if (s!==null && visited.contains(s)) {
				return last
			}
		} while (s !== null)
		return null
	}
	
	
	/**
	 * Check for the unique deployment of a provided port in the scope of a service instance
	 * @param provided port
	 */
	@Check
	def checkDuplicatePortDeployment(FDProvidedPort pp) {
		val container = pp.eContainer
		var duplicates = 0
		switch container {
			FDService: 		duplicates = container.providedPorts.filter[it.target == pp.target].length 
			FDComponent: 	duplicates = container.providedPorts.filter[it.target == pp.target].length
		}
		
		if (duplicates <=  1) {
			true
		} else {
			error(DUPLICATE_DEPLOYMENT_OF_PORT.format(pp.target.name), pp, CDeployPackage.Literals.FD_PROVIDED_PORT__TARGET)
			error(PORT_IS_ALREADY_DEPLOYED, CDeployPackage.Literals.FD_PROVIDED_PORT__TARGET) 
			false
		}		
	}
	
	
	/** 
	 * Check if a port has maximum one interface deployment for each 
	 * inherited interface
	 * @param port
	 */ 
	@Check
	def boolean checkForUniqueInterfaceDeployment(FDPort port) {
		var fails = 0
		val portInterfaceDeployments = port.use.filter(FDInterface).toList
		val inheritedInterfaces = portInterfaceDeployments.map[target].map[interfaceInheritationSet].flatten
		
		for(ii: inheritedInterfaces) {
			val duplicates = portInterfaceDeployments.filter[ii == target]
			if (duplicates.length > 1)
				error(MULTIPLE_DEPLOYMENT_USE_FOR_INTERFACE.format(ii.name, duplicates.join(', ' )["'"+name+"'"]), port, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE, fails++)
		}    		
		return fails == 0
	}
	
	/** 
	 * Report a warning if a port in a service uses an interface deployment 
	 * which is inconsistent to a interface deployment of port on component level
	 * @param port
	 */ 
	@Check
	def boolean checkForConsistentInterfaceDeployment(FDPort port) {
		val container = port.eContainer
		var fails = 0
		if (container instanceof FDService) {
			val portInterfaceDeployments = port.use.filter(FDInterface).toList

			val usedComponents = container.use.filter(FDComponent).toList
			val List<FDInterface> compInterfaceDeployments = newArrayList()
			switch port {
				FDRequiredPort:
					compInterfaceDeployments += usedComponents.map[requiredPorts].flatten
						.filter[port.target == it.target].map[use].flatten.filter(FDInterface)
				FDProvidedPort:
					compInterfaceDeployments += usedComponents.map[providedPorts].flatten
						.filter[port.target == it.target].map[use].flatten.filter(FDInterface)
			}
			
			if ( ! portInterfaceDeployments.empty && ! compInterfaceDeployments.empty) {
				for (portDI: portInterfaceDeployments) {
					val otherDefinitionExists = compInterfaceDeployments.findFirst[portDI != it && portDI.target === it.target]
					if (otherDefinitionExists !== null) {
						warning(INCONSISTENT_INTERFACE_DEPLOYMENT_USE.format(portDI.name, otherDefinitionExists.name), port, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE, fails++)
					}
				}
				return fails == 0
			}
		}
		return true
	}
	
	
	/**
	 * In a variant all used devices shall only host services from the same root. 	
	 * 
	 * Check all used devices for the root of the referenced services.
	 * If root of variant and root of service match, every thing ok.
	 * If root of variant is super of service, give a warning.
	 * Else give error.
	 * @param instance: provided port
	 */
	@Check
	def boolean checkRootCompatibilityOfUsedDevicesInVariant( FDVariant variant) {
		var ok = true
		for (device: variant.use) {
			if (device instanceof FDDevice) {
				for (service: device.use) {
					if (service instanceof FDService) {
						val componentInstance = service.target
						val serviceRoot = componentInstance.getRootOfComponentInstance
						if(serviceRoot !== variant.root) {
						   if (FCompUtils::isDerivedFrom(serviceRoot, variant.root)) {
						   	   warning(USAGE_OF_SERVICE_WITH_DERIVED_ROOT.format(variant.name), componentInstance, CDeployPackage.Literals.FD_COMPONENT_INSTANCE__TARGET)
						   	   warning(DEVICE_CONTAINS_SERVICE_WITH_DERIVED_ROOT.format(componentInstance.name), variant, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE)
						   	   warning(VARIANT_CONTAINS_SERVICES_WITH_INCOMPATIBLE_ROOT, CDeployPackage.Literals.FD_VARIANT__ROOT) 
						   }
						   else {
							   ok = false
						   	   error(USAGE_OF_SERVICE_WITH_DERIVED_ROOT.format(variant.name), componentInstance, CDeployPackage.Literals.FD_COMPONENT_INSTANCE__TARGET)
						   	   error(DEVICE_CONTAINS_SERVICE_WITH_DERIVED_ROOT.format(componentInstance.name), variant, FDeployPackage.Literals.FD_ROOT_ELEMENT__USE)
						   	   error(VARIANT_CONTAINS_SERVICES_WITH_INCOMPATIBLE_ROOT, CDeployPackage.Literals.FD_VARIANT__ROOT) 
						   }
						}
					}
				}
			}
		}
		return ok
	}
	
	
	// *****************************************************************************
	
	/** 
	 * Checks whether all of the mandatory properties of the given {@link FDSpecification} instance are present. 
	 * @param elem the given element
	 * @param feature the corresponding feature instance
	 * @return true if there was an error (missing property), false otherwise
	 */
	def private boolean checkSpecificationElementProperties(FDElement elem,	EStructuralFeature feature) {
			
		val FDSpecification spec = elem.specification
		var mandatoryDecls = PropertyMappings::getAllPropertyDecls(spec, elem).filter[PropertyMappings::isMandatory(it)]
		var List<String> missing = newArrayList
		val properties = elem.properties
		for (FDPropertyDecl propDecl : mandatoryDecls) {
			if (properties === null || properties.items.exists[decl == propDecl] == false) 
				missing.add(propDecl.name)
		}
		if (!missing.empty) 
			error(SPECIFICATION_REQUIRES_MANDATORY_PROPERTY_FOR_ELEMENT.format(spec.name, missing.join(', ')[''' '«it»' ''']), elem, feature, -1)
		
		missing.empty == false
	}
	
	@Check 
	def void checkPropertiesComplete(FDComponent elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_SERVICE__TARGET)
	}
	
	@Check 
	def void checkPropertiesComplete(FDService elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_SERVICE__TARGET)
		
		val spec = elem.specification
		checkForMandatoryPortDeployment(spec, elem, FCPortKind.PROVIDED)
		checkForMandatoryPortDeployment(spec, elem, FCPortKind.REQUIRED)
	}
	
	/**
	 * If the service refers to a specification with mandatory properties for ports,
	 * then check, if for all ports a definition exists.
	 * The actual test for the mandatory properties is done later in the checkPropertiesComplete() for ports.
	 * @param deployment specification of service
	 * @param service
	 * @param kind of port direction
	 */
	def private checkForMandatoryPortDeployment(FDSpecification spec, FDService service, FCPortKind kind) {
		
		val propertyHostName = kind.literal.toFirstLower + "_ports"
		
		val propertyHostForPorts = spec.declarations.findFirst[host.name == propertyHostName]
		if (propertyHostForPorts !== null) {
			val propertyDecls = PropertyMappings::getAllPropertyDecls(spec, propertyHostForPorts.host)
			val hasMandatoryProps = propertyDecls.exists[PropertyMappings::isMandatory(it)]
			
			if (hasMandatoryProps) {
				val FDComponentInstance instance = service.target
				var List<FCPort> ports = newArrayList
				if (instance !== null) {
					var FCComponent component = null 
					if (instance.target !== null)
						component = instance.target
					else
						component = instance.prototype.component
					FCompUtils::collectInheritedPorts(component, kind, ports)
				}		
				val List<String> missing = newArrayList
				
				for (port : ports) {
					if (kind == FCPortKind.PROVIDED) {
						if (service.providedPorts.exists[target == port] === false &&
							checkUsedComponentDeployments(service.use.filter(FDComponent), port, kind) === false)
							missing.add(port.name)
					}
					else {
						if (service.requiredPorts.exists[target == port] === false &&
							checkUsedComponentDeployments(service.use.filter(FDComponent), port, kind) === false)
							missing.add(port.name)
					}
				}
				if (!missing.empty)
					error(SPECIFICATION_REQUIRES_DEPLOYMENT_FOR_PORT.format(spec.name, 
						kind.literal.toLowerCase, missing.join(', ') [''' '«it»' ''']), 
						service, CDeployPackage.Literals.FD_SERVICE__TARGET, -1)
			}
		}
	}	
	
	/**
	 * Check all the used components ports for a deployment of a given port.
	 * Calls recursivly all used components.
	 * @returns true, if any deployment for the port is found.
	 */
	private def boolean checkUsedComponentDeployments(Iterable<FDComponent> usedComponents, FCPort port, FCPortKind kind) {
		for (use: usedComponents) {
			if (kind == FCPortKind.PROVIDED) {
				if (use.providedPorts.exists[target == port])
					return true
			}
			else {
				if (use.requiredPorts.exists[target == port])
					return true
			}
			if (checkUsedComponentDeployments(use.use.filter(FDComponent), port, kind) == true)
				return true
		}
		
		false
	}
	
	@Check 
	def void checkPropertiesComplete(FDProvidedPort elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_PROVIDED_PORT__TARGET)
	}
	
	@Check 
	def void checkPropertiesComplete(FDRequiredPort elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_REQUIRED_PORT__TARGET)
	}
	
	@Check 
	def void checkPropertiesComplete(FDDevice elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_DEVICE__TARGET)
	}
	
	@Check 
	def void checkPropertiesComplete(FDComAdapter elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_COM_ADAPTER__TARGET)
	}
	
	@Check 
	def void checkPropertiesComplete(FDVariant elem) {
		checkSpecificationElementProperties(elem, CDeployPackage.Literals.FD_VARIANT__ROOT)
	}
	
	
	/**
	 * Workaround for the bug:
	 * https://github.com/franca/franca/issues/256 
	 * @author Bernhard Hennlich
	 * TODO: remove, if bug is fixed
	 *
	 * Check if a FDSpecification contains properties which lead 
	 * to clashes in the generated property accessor Java code.
	 */
	@Check 
	override checkClashingProperties(FDSpecification spec) {
		// compute groups of properties with same name
		val allPropertyDecls = spec.declarations.map[properties].flatten
		val groups = allPropertyDecls.groupBy[name]
		
		// check each group in turn
		for(propName : groups.keySet) {
			val props = groups.get(propName)
			
			// find duplicates in the group if they have the same host
			val perHost = props.groupBy[(eContainer as FDDeclaration).host]
			val directDuplicates = perHost.values.filter[size>1].flatten.toSet 
			for(pd : directDuplicates) {
				error(
					"Duplicate property name '" + pd.name + "'",
					pd, FDeployPackage.Literals.FD_PROPERTY_DECL__NAME)
			}

			// continue with all remaining property declarations
			// (if there is a clash already for the same host, we skip all other checks)
			val localUnique = Sets.difference(props.toSet, directDuplicates)

			// check properties according to clashes due to their argument type
			// of the resulting property accessor methods
			// TODO: Validator fails for duplicate property names at interface elements
			// localUnique.checkGroupArgumentType

			// enumeration-typed properties must not have the same name
			val enumProps = localUnique.filter[type.complex !== null && (type.complex instanceof FDEnumType)]
			if (enumProps.size > 1) {
				for(ep : enumProps) {
					error(
						"Deployment property '" + ep.name + "' with an enumeration type has to be unique",
						ep, FDeployPackage.Literals.FD_PROPERTY_DECL__NAME)
				}
			}
		} 
	}
}
