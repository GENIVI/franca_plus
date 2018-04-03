/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.utils.TextStyle
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.eclipse.xtext.ui.label.StylerFactory
import org.franca.compmodel.dsl.fcomp.FCAnnotation
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCAnnotationType
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection
import org.franca.compmodel.dsl.fcomp.FCProvidedPort
import org.franca.compmodel.dsl.fcomp.FCRequiredPort
import org.franca.compmodel.dsl.fcomp.FCVersion
import org.franca.compmodel.dsl.fcomp.Import
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCTagsDeclaration
import org.franca.compmodel.dsl.fcomp.FCTagDecl
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCComAdapter

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class FCompLabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}
	
	@Inject 
	StylerFactory stylerFactory

	// ********** labels ***********
	public def text(FCPort element) {
		val styledString = element.name.convertToStyledString
		if (element.name != element.interface.name) {
			val TextStyle textStyle = new TextStyle()
			val fontData= JFaceResources.getDialogFont().getFontData
			fontData.get(0).style = SWT.ITALIC
			textStyle.setFontData(fontData)
			// textStyle.color = new RGB(63, 72, 204)
			textStyle.color = new RGB(0, 0, 0)
			styledString.append(' [')
			styledString.append(stylerFactory.createFromXtextStyle(element.interface.name, textStyle))
			styledString.append(']')
		}
		styledString	
	}
	
	public def String text(FCComponent element) {
		var String text = ''
		if (element.abstract)
			text += "<abstract> "
		if (element.service)
			text += "<service> "
		if (element.singleton)
			text += "<root> "
		
		text + element.name.split('\\.').last
	}

	public def String text(FCAssemblyConnector element) {
		element.from.port.name + " to " + element.to.port.name 
	}

	public def String text(FCDelegateConnector element) {
		element.outer.port.name + " to " + element.inner.port.name
	}
	
	public def String text(FCAnnotationBlock element) {
		"annotations"
	}
	
	public def String text(FCPrototypeInjection inject) {
		inject.ref.name.split('\\.').last +" by " + inject.name.split('\\.').last  
	}
	
	public def String text(FCAnnotation element) {
		var String name 
		if (element.kind == FCAnnotationType.CUSTOM) 
			name = element.tag.name.substring(1) 
		else 
			name = element.kind.literal.substring(1) 
			
		if (element.value === null)
			name
		else 
			name + element.value	
	}
	
	public def String text(FCVersion element) {
		"v" + element.major + "." + element.minor
	}
	
	public def String text(FCTagsDeclaration element) {
		"tags"
	}
	
	public def String text(Import element) {
		var String imported = null
		if (element.importedNamespace !== null)
			imported = element.importedNamespace
		else 
			imported = '*' 
		imported + " from " + element.importURI
	}     

	
	// ******** icons *********
	
	public def String image(FCAnnotation element) {
		if (element.kind == FCAnnotationType.CUSTOM)
			"bluelabel.png"
		else
			"@.png"
			
	}
	
    public def String image(FCAnnotationBlock element) {
		"annotation.png"
	}

	val static datags = #["@framework", "@cluster", "@dienst" ]
	public def String image(FCComponent element) {
		
		if (element.comment !== null ) {
			var tags = element.comment.elements
				.filter(FCAnnotation).filterNull()
				.filter[kind == FCAnnotationType.CUSTOM]
				.map[tag.name]
			
			// TODO: test if label is present in file system	
			val found = tags.findFirst[datags.contains(it)]
			if (found !== null)
				return found + ".png"			
		}
		"component.png"
	}

	public def String image(FCPrototype element) {
		"prototype.png"
	}

	public def String image(FCRequiredPort element) {
		"requires.png"
	}

	public def String image(FCProvidedPort element) {
		"provides.png"
	}

	public def String image(FCAssemblyConnector element) {
		"connector.png"
	}

	public def String image(FCDelegateConnector element) {
		"delegate.png"
	}
	
	public def String image(FCPrototypeInjection element) {
		"inject.png"
	}

	public def String image(Import element) {
		"import.gif"
	}

	public def String image(FCVersion element) {
		"version.gif"
	}
	
	public def String image(FCModel element) {
		"package.png"
	}
	
	public def String image(FCTagsDeclaration element) {
		"library.png"
	}
	
	public def String image(FCTagDecl element) {
		"bluelabel.png"
	}
	
	public def String image(FCDevice element) {
		"device.png"
	}	
	
	public def String image(FCComAdapter element) {
		"adapter.png"
	}
}
