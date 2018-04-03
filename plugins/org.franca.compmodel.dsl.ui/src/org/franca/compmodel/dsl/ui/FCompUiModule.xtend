/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */
package org.franca.compmodel.dsl.ui

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.autoedit.AbstractEditStrategyProvider
import org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import org.franca.compmodel.dsl.ui.contentassist.ExternalProposalProviderRegistryLoader
import org.franca.compmodel.dsl.ui.contentassist.FCompAutoEditStrategyProvider
import org.franca.compmodel.dsl.ui.contentassist.FCompDocumentationProvider
import org.franca.compmodel.dsl.ui.contentassist.FCompProposalPrefixMatcher
import org.franca.compmodel.dsl.ui.contentassist.FCompProposalProvider
import org.franca.compmodel.dsl.ui.highlighting.FCompHighlightingConfiguration
import org.franca.compmodel.dsl.ui.highlighting.FCompSemanticHighlightCalculator

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class FCompUiModule extends AbstractFCompUiModule {
	
	override public void configure(Binder binder) {
		super.configure(binder);
		binder.bind(String)
				.annotatedWith(
						Names
								.named((XtextContentAssistProcessor.COMPLETION_AUTO_ACTIVATION_CHARS)))
				.toInstance(".:")
	}
		
	override def public Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return FCompProposalPrefixMatcher
	}
	
	// inject own highlighting configuration
	def public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FCompHighlightingConfiguration
	}

	// inject own semantic highlighting
	def public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FCompSemanticHighlightCalculator
	}
	
	override def public Class<? extends AbstractEditStrategyProvider> bindAbstractEditStrategyProvider() {
		return FCompAutoEditStrategyProvider
	}
	
	def public Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProviderr() {
        return FCompDocumentationProvider
    }
	
	// Load ProposalProvider. If extension is registered, the extension class is loaded, of not the FCompProposalProvider will be loaded.
	@SuppressWarnings("unchecked")
	override Class<? extends IContentProposalProvider> bindIContentProposalProvider() {
		val Object object = ExternalProposalProviderRegistryLoader.externalProposalProviderLoader();
		
		if(object !== null) 
			if (object instanceof IContentProposalProvider)
			return (object as IContentProposalProvider).class
		return FCompProposalProvider;
	}
}
