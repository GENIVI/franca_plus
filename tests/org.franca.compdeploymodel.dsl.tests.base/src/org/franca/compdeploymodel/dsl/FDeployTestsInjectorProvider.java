/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl;

import org.franca.compdeploymodel.dsl.FDeployInjectorProvider;
import org.franca.compmodel.dsl.FCompStandaloneSetup;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca deployment tests.
 * @author Klaus Birken
 */
public class FDeployTestsInjectorProvider extends FDeployInjectorProvider {

	@Override
	protected Injector internalCreateInjector() 
	{
		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		new FCompStandaloneSetup().createInjectorAndDoEMFRegistration();
		return super.internalCreateInjector();

	}
}
