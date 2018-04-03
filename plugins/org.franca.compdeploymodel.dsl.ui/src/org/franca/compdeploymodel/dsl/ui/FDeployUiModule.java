/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.compdeploymodel.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher;
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.franca.compdeploymodel.dsl.ui.contentassist.FCompDeployProposalPrefixMatcher;
import org.franca.compdeploymodel.dsl.ui.contentassist.FCompDeployDocumentationProvider;
import org.franca.compdeploymodel.dsl.ui.highlighting.FCompDeployHighlightingConfiguration;
import org.franca.compdeploymodel.dsl.ui.highlighting.FCompDeploySemanticHighlightingCalculator;
import org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider;
import org.franca.compdeploymodel.dsl.ui.contentassist.ExternalDeployProposalProviderRegistryLoader;
import org.franca.compdeploymodel.dsl.ui.contentassist.FDeployProposalProvider;

import com.google.inject.Binder;

/**
 * Use this class to register components to be used within the IDE.
 * 
 * This version of the module assumes that org.eclipse.jdt.core and dependent 
 * plug-ins are installed in the runtime platform. If not, FDeployUiModuleWithoutJDT
 * should be used.
 * 
 * @see FDeployUiModuleWithoutJDT
 */
public class FDeployUiModule extends org.franca.compdeploymodel.dsl.ui.AbstractFDeployUiModule {
	public FDeployUiModule(AbstractUIPlugin plugin) {
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
	
//	@Override
//	public Provider<IAllContainersState> provideIAllContainersState() {
//		return Access.getWorkspaceProjectsState();
//	}
//
//	@Override
//	public Class<? extends IResourceSetProvider> bindIResourceSetProvider() {
//		return SimpleResourceSetProvider.class;
//	}
//
//	@Override
//	public Class<? extends IResourceForEditorInputFactory> bindIResourceForEditorInputFactory() {
//		return ResourceForIEditorInputFactory.class;
//	}
	
	@Override
	public Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return FCompDeployProposalPrefixMatcher.class;
	}
	
	public Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProviderr() {
        return FCompDeployDocumentationProvider.class;
    }
	
	// inject own highlighting configuration
	public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FCompDeployHighlightingConfiguration.class;
	}

	// inject own semantic highlighting
	public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FCompDeploySemanticHighlightingCalculator.class;
	}
	// Load ProposalProvider. If extension is registered, the extension class is loaded, of not the FCompProposalProvider will be loaded.
		@SuppressWarnings("unchecked")
		@Override
		public Class<? extends org.eclipse.xtext.ui.editor.contentassist.IContentProposalProvider> bindIContentProposalProvider() {
			
			Object o = ExternalDeployProposalProviderRegistryLoader.externalProposalProviderLoader();
			
			if(o != null && o instanceof IContentProposalProvider)
			{
				return (Class<? extends IContentProposalProvider>) o.getClass();
			}
			return FDeployProposalProvider.class;
		}
}
