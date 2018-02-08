/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/ 
 
package org.franca.compdeploymodel.dsl;

import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Injector;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FDeployStandaloneSetup extends FDeployStandaloneSetupGenerated{

	public static void doSetup() {
		new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
	
	public Injector createInjectorAndDoEMFRegistration() {
		if (! EPackage.Registry.INSTANCE.containsKey("http://www.franca.org/compdeploymodel/dsl/FDeploy")) {
			EPackage.Registry.INSTANCE.put("http://www.franca.org/compdeploymodel/dsl/FDeploy", org.franca.compdeploymodel.dsl.fDeploy.FDeployPackage.eINSTANCE);
		}
		return super.createInjectorAndDoEMFRegistration();
	}
}

