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
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCContainedInstance
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCHostedInstance
import org.franca.compmodel.dsl.fcomp.FCInjectedPrototype
import org.franca.compmodel.dsl.fcomp.FCInstance
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection
import org.franca.compmodel.dsl.fcomp.FCPrototypeInstance
import org.franca.compmodel.dsl.fcomp.FCProvidedPort
import org.franca.compmodel.dsl.fcomp.FCRequiredPort
import org.franca.compmodel.dsl.fcomp.FCVersion
import org.franca.compmodel.dsl.fcomp.Import
import org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider
import org.franca.compmodel.dsl.fcomp.FCAnnotation
import org.franca.compmodel.dsl.fcomp.FCAnnotationType

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
	FCompDeclarativeNameProvider fqnProvider

	// labels
	public def String text(FCInstance element) {
		if (element.name === null)
			element.component.name
		else
			element.name.split('\\.').last
	}

	public def String text(FCPrototypeInstance element) {
		fqnProvider.getFullyQualifiedName(element).toString.split('\\.').last
	}
	
	public def String text(FCHostedInstance element) {
		fqnProvider.getFullyQualifiedName(element.instance).toString.split('\\.').last
	}

	public def String text(FCComponent element) {
		var String text = ''
		if (element.abstract)
			text += "\u00ABabstract\u00BB "
		if (element.service)
			text += "\u00ABservice\u00BB "
		if (element.root)
			text += "\u00ABroot\u00BB "
		if (element.singleton)
			text += "\u00ABroot\u00BB "
		
		text + element.name.split('\\.').last
	}

	public def String text(FCAssemblyConnector element) {
		element.from.port.name + "." + element.from.port.name // + ' \u221E ' + element.to.port.name + "." + element.to.port.name 
	}

	public def String text(FCDelegateConnector element) {
		element.inner.port.name + element.inner.port.name // + ' \u221E ' + element.outer.port.name
	}
	
	public def String text(FCAnnotationBlock element) {
		"annotations"
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
	
	public def String text(Import element) {
		var String imported = null
		if (element.importedNamespace !== null)
			imported = element.importedNamespace
		else 
			imported = '*' 
		imported + " \u2192 " + element.importURI
	}      
	
	// icons
	
	public def String image(FCAnnotation element) {
		if (element.kind == FCAnnotationType.CUSTOM)
			"bluelabel.png"
		else
			"@.png"
			
	}
	
    public def String image(FCAnnotationBlock element) {
		"annotation.png"
	}

	public def String image(FCComponent element) {
		
		if (element.comment !== null ) {
			var tags = element.comment.elements
				.filter(FCAnnotation).filterNull()
				.filter[kind == FCAnnotationType.CUSTOM]
				.map[tag.name]
			
			// TODO: test if label is present in file system	
			val found = tags.findFirst[#["@framework", "@cluster", 	"@dienst"].contains(it)]
			if (found != null)
				return found + ".png"			
		}
		"component.png"
	}

	public def String image(FCPrototype element) {
		"prototype.png"
	}

	public def String image(FCInstance element) {
		"instance.png"
	}
	
	public def String image(FCContainedInstance element) {
		"instance.png"
	}
	
	public def String image(FCHostedInstance element) {
		"hosted.png"
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
	
	public def String image(FCInjectedPrototype element) {
		"inject.png"
	}
	
	public def String image(FCPrototypeInjection element) {
		"inject.png"
	}

	public def String image(Import element) {
		"import.gif"
	}

	public def String image(FCDevice element) {
		"device.png"
	}

	public def String image(FCVersion element) {
		"version.gif"
	}
	
}
