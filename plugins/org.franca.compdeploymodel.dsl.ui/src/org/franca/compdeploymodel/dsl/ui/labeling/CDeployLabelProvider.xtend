/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui.labeling

import javax.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.jface.viewers.StyledString
import org.eclipse.jface.viewers.StyledString.Styler
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.FontData
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.utils.TextStyle
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.eclipse.xtext.ui.label.InjectableAdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.StylerFactory
import org.franca.compdeploymodel.dsl.CDeployUtils
import org.franca.compdeploymodel.dsl.cDeploy.FDAnnotation
import org.franca.compdeploymodel.dsl.cDeploy.FDAnnotationBlock
import org.franca.compdeploymodel.dsl.cDeploy.FDComAdapter
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.compdeploymodel.dsl.cDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compdeploymodel.dsl.cDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.cDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.cDeploy.FDService
import org.franca.compdeploymodel.dsl.cDeploy.FDVariant
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FType
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.core.GenericPropertyAccessor
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArray
import org.franca.deploymodel.dsl.fDeploy.FDAttribute
import org.franca.deploymodel.dsl.fDeploy.FDBoolean
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDEnumerator
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDGeneric
import org.franca.deploymodel.dsl.fDeploy.FDInteger
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertySet
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDString
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDTypedef
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion
import org.franca.deploymodel.dsl.fDeploy.Import

import static extension org.franca.compdeploymodel.dsl.CDeployUtils.*

/** 
 * Provides labels for a EObjects.
 * see
 * http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
class CDeployLabelProvider extends DefaultEObjectLabelProvider {
	
	
	final String DEFAULT_PROPERTY_MARKER = "?"
	final String DEFAULT_VALUE_MARKER = "?="
	final StylerFactory stylerFactory
	final DefaultHighlightingConfiguration configuration

	@Inject new(InjectableAdapterFactoryLabelProvider delegate, StylerFactory stylerFactory,
		DefaultHighlightingConfiguration configuration) {
		super(delegate)
		this.stylerFactory = stylerFactory
		this.configuration = configuration
	}

	def String text(FDMethod element) {
		return element.target.name
	}

	def String text(FDAttribute element) {
		return element.target.name
	}

	def String text(FDBroadcast element) {
		return element.target.name
	}

	def String text(FDArgument element) {
		return element.target.name
	}

	def String text(FDArray element) {
		return element.target.name
	}

	def String text(FDEnumeration element) {
		return element.target.name
	}

	def String text(FDField element) {
		return element.target.name
	}

	def String text(FDStruct element) {
		return element.target.name
	}

	def String text(FDUnion element) {
		return element.target.name
	}

	def String text(FDTypedef element) {
		return element.target.name
	}

	def String text(FDProperty element) {
		return element.getDecl().name
	}

	def String text(FDVariant element) {
		return element.name
	}

	def String text(FDTypeOverwrites element) {
		return "overwrites"
	}

	def String text(FDInteger element) {
		return getDefaultMarker(element) + String::valueOf(element.value)
	}

	def String text(FDString element) {
		return getDefaultMarker(element) + element.getValue()
	}

	def String text(FDBoolean element) {
		return getDefaultMarker(element) + element.getValue()
	}

	def String text(FDGeneric element) {
		var String dm = getDefaultMarker(element)
		if (FDModelUtils::isEnumerator(element)) {
			return dm + FDModelUtils::getEnumerator(element).name
		}
//		if (FDModelUtils.isInstanceRef(element)) {
//			return dm + FDModelUtils.getInstanceRef(element).name
//		}
		return '''«dm»UNKNOWN'''.toString // shouldn't happen
	}

	def String text(FDEnumerator element) {
		return getDefaultMarker(element) + element.name
	}

	def String text(FDDeclaration element) {
		var String name = element.host.name
		return name.substring(0, 1).toUpperCase() + name.substring(1).toLowerCase()
	}

	def String text(FDPropertyDecl element) {
		var String name = new String()
		if (!PropertyMappings::isMandatory(element)) {
			name += DEFAULT_PROPERTY_MARKER
		}
		name += element.name
		return name
	}

	def String text(FDPropertySet element) {
		return "properties"
	}

	def String getDefaultMarker(EObject element) {
		if (GenericPropertyAccessor::isSpecification(element)) {
			if (GenericPropertyAccessor::isDefault(element)) {
				return DEFAULT_VALUE_MARKER
			}
		}
		return ""
	}

	def StyledString text(FDTypes element) {
		return getStyledStringForElement(element.name, element.target.name)
	}

	def StyledString text(FDInterface element) {
		return getStyledStringForElement(element.name, element.target.name)
	}

	def StyledString text(FDDevice element) {
		return getStyledStringForElement(element.name, element.targetName)
	}
	
	def StyledString text(FDComAdapter element) {
		return getStyledStringForElement(element.name, element.targetName)
	}

	def StyledString text(FDService element) {
		return getStyledStringForElement(element.name, element.target.name)
	}

	def StyledString text(FDRequiredPort element) {
		var FDSpecification spec = CDeployUtils.getSpecification(element)
		var String specName = if(spec !== null) spec.name else "unknown"
		return getStyledStringForElement(element.name, specName)
	}

	def StyledString text(FDProvidedPort element) {
		var FDSpecification spec = CDeployUtils.getSpecification(element)
		var String specName = if(spec !== null) spec.name else "unknown"
		return getStyledStringForElement(element.name, specName)
	}

	def StyledString text(FDComponent element) {
		var FDSpecification spec = CDeployUtils.getSpecification(element)
		var String specName = if(spec !== null) spec.name else "unknown"
		return getStyledStringForElement(element.name, specName)
	}

	def private StyledString getStyledStringForElement(String name, String targetName) {
		var String elementName = if (name !== null) name else targetName
		var Styler style = stylerFactory.createXtextStyleAdapterStyler(configuration.defaultTextStyle())
		var StyledString styledString = new StyledString(elementName, style)
		// append derived type in italic
		if (name !== null) {
			var TextStyle textStyle = new TextStyle()
			var FontData[] fontData = JFaceResources::getDialogFont().getFontData()
			fontData.get(0).setStyle(SWT::ITALIC)
			textStyle.setFontData(fontData)
			textStyle.setColor(new RGB(0, 0, 0))
			styledString.append(" [");
			styledString.append(stylerFactory.createFromXtextStyle(targetName, textStyle))
			styledString.append(Character.valueOf(']').charValue)
		}
		return styledString
	}

	def String text(FDAnnotationBlock element) {
		return "annotations"
	}

	def String text(FDAnnotation element) {
		return '''«((element as FAnnotation)).getType().toString().replaceFirst("@", "")»:«((element as FDAnnotation)).getComment()»'''.
			toString
	}

	def String image(FDAnnotationBlock element) {
		return "annotation.png"
	}

	def String image(FDAnnotation element) {
		return "@.png"
	}

	def String image(FDInterface element) {
		return "interface.png"
	}

	def String image(FDAttribute element) {
		return "attribute.gif"
	}

	def String image(FDMethod element) {
		return "method.gif"
	}

	def String image(FDField element) {
		return "field.gif"
	}

	def String image(FDPropertySet element) {
		return "yellowlabel.png"
	}

	def String image(FDProperty element) {
		return "yellowlabel.png"
	}

	def String image(FDGeneric element) {
		if (FDModelUtils::isEnumerator(element)) {
			return "enum.gif"
		}
		return null // shouldn't happen
	}

	def String image(FDEnumerator element) {
		return "enumerator.gif"
	}

	def String image(FDEnumeration element) {
		return "enum.gif"
	}

	def String image(FDArray element) {
		return "arrays.png"
	}

	def String image(FType element) {
		return "types.gif"
	}

	def String image(FDStruct element) {
		return "struct.gif"
	}

	def String image(FDUnion element) {
		return "struct.gif" // TODO: different image for unions?
	}

	def String image(Import element) {
		return "import.gif"
	}

	def String image(FDTypeOverwrites element) {
		return "overwrite.png"
	}

	def String image(FDBroadcast element) {
		return "event.png"
	}

	def String image(FDService element) {
		return "instance.png"
	}

	def String image(FDComponentInstance element) {
		return "instance.png"
	}

	def String image(FDDevice element) {
		return "deployment.png"
	}

	def String image(FDComAdapter element) {
		return "adapter.png"
	}

	def String image(FDProvidedPort element) {
		return "provides.png"
	}

	def String image(FDRequiredPort element) {
		return "requires.png"
	}

	def String image(FDComponent element) {
		return "component.png"
	}

	def String image(FDModel element) {
		return "package.png"
	}

	def String image(FDVariant element) {
		return "variant.png"
	}

	def String image(FDTypes element) {
		return "types.gif"
	}

	def String image(FDArgument element) {
		var EObject parent = element.eContainer().eContainer()
		if (parent instanceof FDBroadcast ||
			(parent instanceof FDMethod && ((parent as FDMethod)).getOutArguments().getArguments().contains(element))) {
			return "overlay-out.gif"
		} else {
			return "overlay-in.gif"
		}
	}

	def String image(FDDeclaration element) {
		
		val builtIn = element.host.builtIn
		
		switch (builtIn) {
			case INTERFACES: {
				return "interface.png"
			}
			case ATTRIBUTES: {
				return "attribute.gif"
			}
			case METHODS: {
				return "method.gif"
			}
			case STRUCT_FIELDS: {
				return "field.gif"
			}
			case UNION_FIELDS: {
				return "field.gif"
			}
			case FIELDS: {
				return "field.gif"
			}
			case ENUMERATIONS: {
				return "enum.gif"
			}
			case ENUMERATORS: {
				return "enumerator.gif"
			}
			case BROADCASTS: {
				return "event.png"
			}
			case STRINGS: {
				return "strings.png"
			}
			case NUMBERS, // fall-through
			case INTEGERS, // fall-through
			case FLOATS: {
				return "numbers.png"
			}
			case ARRAYS: {
				return "arrays.png"
			}
			default: {
				switch (element.host.getText()) {
					case "devices": {
						return "device.png"
					}
					case "services": {
						return "service.png"
					}
					case "provided_ports": {
						return "provides.png"
					}
					case "required_ports": {
						return "requires.png"
					}
					case "adapters": {
						return "adapter.png"
					}
					case "variants": {
						return "variant.png"
					}
					case "components": {
						return "component.png"
					}
					case "attribute_notifiers",
					case "attribute_getters",
					case "attribute_setters": {
						return "attribute.png"
					}
					default: {
						return null
					}
				}
			}
		}
	}
}
