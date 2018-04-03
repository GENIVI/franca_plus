/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */
package org.franca.compmodel.dsl

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider
import org.franca.compmodel.dsl.valueconverter.FCompValueConverters

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class FCompRuntimeModule extends AbstractFCompRuntimeModule {

	override public Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return ImportUriGlobalScopeProvider
	}

	override public void configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
			ImportedNamespaceAwareLocalScopeProvider)
	}

	override public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return FCompDeclarativeNameProvider
	}

	override public Class<? extends IValueConverterService> bindIValueConverterService() {
		return FCompValueConverters
	}
}
