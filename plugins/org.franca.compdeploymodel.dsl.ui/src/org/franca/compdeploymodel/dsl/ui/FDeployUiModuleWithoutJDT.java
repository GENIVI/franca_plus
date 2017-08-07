/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.compdeploymodel.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.resource.containers.IAllContainersState;
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory;
import org.eclipse.xtext.ui.editor.model.ResourceForIEditorInputFactory;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.eclipse.xtext.ui.resource.SimpleResourceSetProvider;
import org.eclipse.xtext.ui.shared.Access;

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
}
