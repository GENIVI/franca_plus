/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */
package org.franca.compdeploymodel.dsl

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.formatting.IFormatter
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.validation.CompositeEValidator
import org.franca.compdeploymodel.dsl.formatting.CDeployFormatter
import org.franca.deploymodel.dsl.valueconverter.FDeployValueConverters

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class CDeployRuntimeModule extends AbstractCDeployRuntimeModule {

	// TODO: is this really needed? remove and test!
	def configureUseEObjectValidator(Binder binder) {
		binder.bind(Boolean).annotatedWith(
			Names.named(CompositeEValidator.USE_EOBJECT_VALIDATOR)
		).toInstance(Boolean.FALSE)
	}

	// support importURI global scoping
	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return ImportUriGlobalScopeProvider
	}

//	name space aware scoping not yet implemented	
//	override public void configureIScopeProviderDelegate(Binder binder) {
//		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
//			ImportedNamespaceAwareLocalScopeProvider)
//	}

	override Class<? extends IFormatter> bindIFormatter() {
		return CDeployFormatter
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return FDeployValueConverters
	}

    override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
        CDeployDeclarativeNameProvider
    }
    
    protected static class NullGenerator2 extends IGenerator.NullGenerator implements IGenerator2 {					
		override afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {} 
		override beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {} 		
		override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
			super.doGenerate(input, fsa) // does nothing
		}
	}
    
    /**
     * Disable the deployment generator by the JVM switch -DnoFDeployGenerator
     * @returns generator class
     */
    override Class<? extends IGenerator2> bindIGenerator2() {
		val String noFDeployGenerator = System.getProperty( "noFDeployGenerator");
		if (noFDeployGenerator !== null)
			return NullGenerator2
		else 
			return super.bindIGenerator2
	}
}
