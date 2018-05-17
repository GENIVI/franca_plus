/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl

import org.franca.compdeploymodel.dsl.cDeploy.FDComAdapter
import org.franca.compdeploymodel.dsl.cDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.compdeploymodel.dsl.cDeploy.FDService

class CDeployUtils {
	
	/** 
	 * Get the first segment for a component instance, the so called root.
	 * 
	 * @param component instance
	 * @return root 
	 */
	public def static FCComponent getRootOfComponentInstance(FDComponentInstance instance) {
		var FDComponentInstance temp = instance
		while (temp.getParent() !== null)
			temp = temp.getParent()
		return temp.getTarget()
	}
	
	/**
	 * Get the service component of a given service.
	 */
	public def static FCComponent getServiceComponent(FDService service) {

		var FCComponent component = null
		if (service.target !== null) {
			if (service.target.prototype === null) {
				if (service.target.target !== null && service.target.target.service) {
					component = service.target.target
				}
			} else {
				if (service.target.prototype.component.service)
					component = service.target.prototype.component
			}
		}
		component	
	}
	
	/**
	 * Delivers the specification of a deploymodel element.
	 * If element's root element has a specification, the specification property from the containing root element is given back.
	 * If the root element has no specification and is not contained by an other root element NULL is returned.
	 *  
	 * @param element
	 * @return specification
	 */
	public def static FDSpecification getSpecification(FDElement element) {
		val FDRootElement root = FDModelUtils::getRootElement(element)
		if (root !== null) {
			var FDSpecification spec = root.getSpec()
			if (spec !== null)
				return spec
			if (root.eContainer() instanceof FDElement) {
				return getSpecification( (root.eContainer()) as FDElement)
			}
		}
		return null;
	}
	
	/* 
	 * target is not resolved in the ui package, 
	 * so this two methods help providing the correct label strings
	 */
	public def static getTargetName(FDDevice it) { target.name }
	public def static getTargetName(FDComAdapter it) { target.name }
}
