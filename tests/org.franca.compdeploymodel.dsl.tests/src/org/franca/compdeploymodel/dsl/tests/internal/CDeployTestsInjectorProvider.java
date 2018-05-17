/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl.tests.internal;

import org.franca.compdeploymodel.dsl.CDeployExtension;
import org.franca.compdeploymodel.dsl.tests.CDeployInjectorProvider;
import org.franca.compmodel.dsl.FCompStandaloneSetup;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.deploymodel.extensions.ExtensionRegistry;

import com.google.inject.Injector;

public class CDeployTestsInjectorProvider extends CDeployInjectorProvider {

//	private Injector francaInjector = null;
	
	@Override
	public Injector getInjector() {
//		if (francaInjector == null) {
//			francaInjector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
//		}
		return super.getInjector();
	}
	
	protected Injector internalCreateInjector() {
		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		new FCompStandaloneSetup().createInjectorAndDoEMFRegistration();
	    return new CDeployTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
	}

	@Override
	public void setupRegistry() {
		// A stand-alone test will not load the CDeployExtension ExtensionPoint. 
		// We must explicitly make an ExtensionRegistry.addExtension (new CDeployExtension ()) 
		// during the test initialization.
		ExtensionRegistry.addExtension(new CDeployExtension());
		
//		if (francaInjector != null) {
//			new FrancaIDLStandaloneSetup().register(francaInjector);
//		}
		super.setupRegistry();
	}
	
	@Override
	public void restoreRegistry() {
		ExtensionRegistry.reset();
		super.restoreRegistry();
	}
}
