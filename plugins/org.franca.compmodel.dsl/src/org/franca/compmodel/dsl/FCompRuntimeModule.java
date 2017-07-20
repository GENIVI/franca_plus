/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl;

import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider;

import com.google.inject.Binder;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class FCompRuntimeModule extends org.franca.compmodel.dsl.AbstractFCompRuntimeModule {
	
	@Override
	public Class<? extends org.eclipse.xtext.scoping.IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider.class;
	}
	
	@Override
	public void configureIScopeProviderDelegate(Binder binder) {
		binder.bind(org.eclipse.xtext.scoping.IScopeProvider.class).annotatedWith(
				com.google.inject.name.Names.named(org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
						org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider.class);
	}
	
	@Override
    public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
        return FCompDeclarativeNameProvider.class;
    }
}
