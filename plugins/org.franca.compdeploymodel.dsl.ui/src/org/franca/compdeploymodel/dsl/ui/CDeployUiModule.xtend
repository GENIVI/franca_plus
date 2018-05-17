/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui

import com.google.inject.Binder
import com.google.inject.Provider
import com.google.inject.name.Names
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.resource.containers.IAllContainersState
import org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import org.eclipse.xtext.ui.shared.Access
import org.franca.compdeploymodel.dsl.ui.contentassist.CDeployDocumentationProvider
import org.franca.compdeploymodel.dsl.ui.contentassist.CDeployProposalPrefixMatcher
import org.franca.compdeploymodel.dsl.ui.contentassist.CDeployProposalProvider
import org.franca.compdeploymodel.dsl.ui.contentassist.ExternalDeployProposalProviderRegistryLoader
import org.franca.compdeploymodel.dsl.ui.highlighting.CDeployHighlightingConfiguration
import org.franca.compdeploymodel.dsl.ui.highlighting.CDeploySemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory
import org.eclipse.xtext.ui.editor.model.ResourceForIEditorInputFactory

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class CDeployUiModule extends AbstractCDeployUiModule {
	
	override configure(Binder binder) {
		super.configure(binder);
		binder.bind(String).annotatedWith(
			Names.named((XtextContentAssistProcessor.COMPLETION_AUTO_ACTIVATION_CHARS))).
			toInstance(".:")
	}

	override Provider<IAllContainersState> provideIAllContainersState() {
		return Access.getWorkspaceProjectsState();
	}

//	override Class<? extends IResourceSetProvider> bindIResourceSetProvider() {
//		return SimpleResourceSetProvider
//	}

	override Class<? extends IResourceForEditorInputFactory> bindIResourceForEditorInputFactory() {
		return ResourceForIEditorInputFactory
	}

	override Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return CDeployProposalPrefixMatcher
	}

	def public Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProviderr() {
        return CDeployDocumentationProvider
	}
	
	// inject own highlighting configuration
	def public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return CDeployHighlightingConfiguration
	}

	// inject own semantic highlighting
	def public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return CDeploySemanticHighlightingCalculator
	}
	
	// Load ProposalProvider. If extension is registered, the extension class is loaded, 
	// of not the FCompProposalProvider will be loaded.
	// TODO: enable extension class loader again
	override Class<? extends IContentProposalProvider> bindIContentProposalProvider() {
		val Object o = ExternalDeployProposalProviderRegistryLoader.externalProposalProviderLoader();
		
		if (o !== null && o instanceof IContentProposalProvider) {
			println("bindIContentProposalProvider: use custom proposal provider " + o.class.toString)
			return o as Class<? extends IContentProposalProvider>
		}
		else
			return CDeployProposalProvider as Class<? extends IContentProposalProvider>
	}
}
