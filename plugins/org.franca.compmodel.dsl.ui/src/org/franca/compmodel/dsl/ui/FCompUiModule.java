/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher;
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor;
import org.franca.compmodel.dsl.ui.contentassist.FCompProposalPrefixMatcher;

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
				.toInstance(":");
	}
		
	@Override
	public Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return FCompProposalPrefixMatcher.class;
	}
}
