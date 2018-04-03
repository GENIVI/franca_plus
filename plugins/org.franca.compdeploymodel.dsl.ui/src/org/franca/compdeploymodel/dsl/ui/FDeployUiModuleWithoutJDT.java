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
import org.eclipse.xtext.resource.containers.IAllContainersState;
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher;
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor;
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory;
import org.eclipse.xtext.ui.editor.model.ResourceForIEditorInputFactory;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.eclipse.xtext.ui.resource.SimpleResourceSetProvider;
import org.eclipse.xtext.ui.shared.Access;
import org.franca.compdeploymodel.dsl.ui.contentassist.FCompDeployProposalPrefixMatcher;
import org.franca.compdeploymodel.dsl.ui.contentassist.FCompDeployDocumentationProvider;
import org.franca.compdeploymodel.dsl.ui.highlighting.FCompDeployHighlightingConfiguration;
import org.franca.compdeploymodel.dsl.ui.highlighting.FCompDeploySemanticHighlightingCalculator;

import com.google.inject.Binder;
import com.google.inject.Provider;

/**
 * Use this class to register components to be used within the IDE.
 * 
 * This version of the UiModule avoids using JDT (i.e., org.eclipse.jdt.core and others).
 * However, if this version is used, resolution of "classpath:"-URIs will not work.
 * 
 * For details see also: https://bugs.eclipse.org/bugs/show_bug.cgi?id=404322#c5
 * 
 */
public class FDeployUiModuleWithoutJDT extends FDeployUiModule {
	public FDeployUiModuleWithoutJDT(AbstractUIPlugin plugin) {
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
	public Provider<IAllContainersState> provideIAllContainersState() {
		return Access.getWorkspaceProjectsState();
	}

	@Override
	public Class<? extends IResourceSetProvider> bindIResourceSetProvider() {
		return SimpleResourceSetProvider.class;
	}

	@Override
	public Class<? extends IResourceForEditorInputFactory> bindIResourceForEditorInputFactory() {
		return ResourceForIEditorInputFactory.class;
	}
	
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
}
