/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl.tests.internal;

import org.eclipse.xtext.util.Modules2;
import org.franca.compdeploymodel.dsl.CDeployRuntimeModule;
import org.franca.compdeploymodel.dsl.CDeployStandaloneSetup;
import org.franca.compmodel.dsl.FCompRuntimeModule;
import org.franca.core.dsl.FrancaIDLRuntimeModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class CDeployTestsStandaloneSetup extends CDeployStandaloneSetup {
    @Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(
        		new FrancaIDLRuntimeModule(),
        		new FCompRuntimeModule(),
        		new CDeployRuntimeModule(),
        		new CDeployTestsModule()));
    }
}
