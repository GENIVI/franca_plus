/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.tests.util;

import org.franca.compmodel.dsl.FCompInjectorProvider;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;

import com.google.inject.Injector;

public class MultiInjectorProvider extends FCompInjectorProvider 
{
	@Override
	protected Injector internalCreateInjector() 
	{
		new FrancaIDLTestsInjectorProvider().getInjector();
		return super.internalCreateInjector();
	}
}

