/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.labeling

import com.google.inject.Inject
import org.franca.compmodel.dsl.fcomp.FCInstance
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCLabel
import org.franca.compmodel.dsl.fcomp.FCRequiredPort
import org.franca.compmodel.dsl.fcomp.FCProvidedPort
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.Import
import org.franca.compmodel.dsl.fcomp.FCPrototypeInstance
import org.franca.compmodel.dsl.fcomp.FCLabelKind
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCAnnotation
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCVersion
import org.franca.compmodel.dsl.fcomp.FCContainedInstance
import org.franca.compmodel.dsl.fcomp.FCHostedInstance
import org.franca.compmodel.dsl.fcomp.FCInjectedPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class FCompLabelProvider extends org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider {

	@Inject
	new(org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}
	
	@Inject
	org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider fqnProvider

	// labels
	public def String text(FCInstance element) {
		if (element.name === null)
			element.component.name
		else
			element.name
	}

	public def String text(FCPrototypeInstance element) {
		fqnProvider.getFullyQualifiedName(element).toString
	}
	
	public def String text(FCHostedInstance element) {
		fqnProvider.getFullyQualifiedName(element.instance).toString
	}

	public def String text(FCLabel element) {
		element.kind.toString.replaceFirst('@', '')
	}

	public def String text(FCComponent element) {
		if (element.labels.exists[kind == FCLabelKind.ABSTRACT])
			"\u00ABabstract\u00BB " + element.name
		else
			element.name
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
	
	public def String text(FCVersion element) {
		"v" + element.major + "." + element.minor
	}
	
	public def String text(Import element) {
		element.importedNamespace + " \u2192 " + element.importURI
	}      
	
	// icons
	
	public def String image(FCAnnotation element) {
		"annotation.png"
	}
   
    public def String image(FCAnnotationBlock element) {
		"annotation.png"
	}

	public def String image(FCComponent element) {
		if (element.labels.exists[kind == FCLabelKind.ROOT])
			"root.png"
		else if (element.labels.exists[kind == FCLabelKind.FRAMEWORK])
			"framework.png"
		else if (element.labels.exists[kind == FCLabelKind.CLUSTER])
			"cluster.png"
		else
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

	public def String image(FCLabel element) {
		"label.png"
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
