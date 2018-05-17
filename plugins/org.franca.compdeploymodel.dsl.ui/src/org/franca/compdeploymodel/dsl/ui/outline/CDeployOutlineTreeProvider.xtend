/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui.outline

import com.google.inject.Inject
import org.eclipse.swt.graphics.Image
import org.eclipse.xtext.ui.IImageHelper
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.compdeploymodel.dsl.cDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compdeploymodel.dsl.cDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.cDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.cDeploy.FDService
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertySet
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDValue

/**
 * Customization of the default outline structure.
 *
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#outline
 */
class CDeployOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	
	@Inject 
	IImageHelper imageHelper
		
	def protected boolean _isLeaf(FDComponentInstance feature) {
	    return true
	}
	
	/**
	 * Return the correct icon name depending on the derived type of 
	 * the root element.
	 */
	def protected getImageName(FDRootElement re) {
		switch re {
			FDInterface: 	"use_interface.png" 
			FDDevice: 		"use_device.png"
			FDTypes: 		"use_types.png"
			FDService: 		"use_instance.png"
			FDComponent: 	"use_component.png"
			FDProvidedPort:	"use_provides.png"
			FDRequiredPort:	"use_requires.png"
			default:		"use.png"
		}
	}
	
	/**
	 * Provide a navigable tree structure for components and 
	 * dynamic use icons
	 */
	def protected void _createNode(IOutlineNode parentNode, FDRootElement rootElement) {		
		val EObjectNode rootElementNode = createEObjectNode(parentNode, rootElement)
		if ( ! rootElement.use.empty) {
			for (use: rootElement.use) {
				val Image useIcon = imageHelper.getImage(use.getImageName)
				if (use.name !== null) {
					val EObjectNode useNode = createEObjectNode(rootElementNode, use)
					useNode.setText(use.name)
					useNode.setImage(useIcon)
					_createNode(useNode, use)
				}
			}
			_createChildren(rootElementNode, rootElement)
		}
	}
	
	/**
	 * Omit the FDComplexValue element to get a neater outline 
	 */
	def protected void _createNode(IOutlineNode parentNode, FDComplexValue cv) {		
		
		if (cv.single !== null)
			createEObjectNode(parentNode, cv.single)
		else 
			for (FDValue v: cv.array.values) {
				createEObjectNode(parentNode, v)
			}
	}
	
	/**
	 * Omit properties collection element 
	 */
	def protected void _createNode(IOutlineNode parentNode, FDPropertySet ps) {		
		for (FDProperty p: ps.items) {
			val EObjectNode element = createEObjectNode(parentNode, p);
			createChildren(element, p.value)
		}
	}
	
	/**
	 * Omit component instance element 
	 */
	def protected void _createNode(IOutlineNode parentNode, FDComponentInstance i) {		
	}
	
	
	/**
	 * Omit argument list element 
	 */
	def protected void _createNode(IOutlineNode parentNode, FDArgumentList al) {		
		for (FDArgument a : al.arguments) {
			val EObjectNode element = createEObjectNode(parentNode, a);
			createChildren(element, a.properties)
			createChildren(element, a.overwrites)
		}
	}	
}