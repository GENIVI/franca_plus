/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.linking.ILinker;
import org.eclipse.xtext.linking.ILinkingService;
import org.eclipse.xtext.naming.IQualifiedNameProvider;

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
        return org.franca.compmodel.dsl.scoping.FCompDeclarativeNameProvider.class;
    }
	
	@Override
	public Class<? extends IValueConverterService> bindIValueConverterService() {
		return org.franca.compmodel.dsl.valueconverter.FCompValueConverters.class;
	}	
	
	@Override
	public Class<? extends ILinkingService> bindILinkingService() {
		return org.franca.compmodel.dsl.linker.FCompLinkingService.class;
	}
	
	@Override
	public Class<? extends ILinker> bindILinker() {
		return org.franca.compmodel.dsl.linker.FCompLinker.class;
	}	
}
