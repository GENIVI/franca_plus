/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.editor.autoedit.AbstractEditStrategyProvider;
import org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider;
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher;
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.franca.compmodel.dsl.ui.contentassist.ExternalProposalProviderRegistryLoader;
import org.franca.compmodel.dsl.ui.contentassist.FCompAutoEditStrategyProvider;
import org.franca.compmodel.dsl.ui.contentassist.FCompProposalPrefixMatcher;
import org.franca.compmodel.dsl.ui.contentassist.FCompProposalProvider;
import org.franca.compmodel.dsl.ui.highlighting.FCompHighlightingConfiguration;
import org.franca.compmodel.dsl.ui.highlighting.FCompSemanticHighlightCalculator;

import com.google.inject.Binder;

/**
 * Use this class to register components to be used within the IDE.
 */
public class FCompUiModule extends org.franca.compmodel.dsl.ui.AbstractFCompUiModule {
	
	public FCompUiModule(AbstractUIPlugin plugin) {
		super(plugin);
	}
	
	@Override
	public void configure(Binder binder) {
		super.configure(binder);
		binder.bind(String.class)
				.annotatedWith(
						com.google.inject.name.Names
								.named((XtextContentAssistProcessor.COMPLETION_AUTO_ACTIVATION_CHARS)))
				.toInstance(".:");
	}
		
	@Override
	public Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return FCompProposalPrefixMatcher.class;
	}
	
	// inject own highlighting configuration
	public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FCompHighlightingConfiguration.class;
	}

	// inject own semantic highlighting
	public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FCompSemanticHighlightCalculator.class;
	}
	
	public Class<? extends AbstractEditStrategyProvider> bindAbstractEditStrategyProvider() {
		return FCompAutoEditStrategyProvider.class;
	}
	
	// Load ProposalProvider. If extension is registered, the extension class is loaded, of not the FCompProposalProvider will be loaded.
	@SuppressWarnings("unchecked")
	@Override
	public Class<? extends org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider> bindIContentProposalProvider() {
		
		Object o = ExternalProposalProviderRegistryLoader.externalProposalProviderLoader();
		
		if(o != null && o instanceof IContentProposalProvider)
		{
			return (Class<? extends IContentProposalProvider>) o.getClass();
		}
		return FCompProposalProvider.class;
	}
}
