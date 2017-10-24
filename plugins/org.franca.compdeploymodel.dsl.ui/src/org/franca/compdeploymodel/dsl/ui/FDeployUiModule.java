/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.compdeploymodel.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher;
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor;
import org.franca.compdeploymodel.dsl.ui.contentassist.FCompDeployProposalPrefixMatcher;

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
}
