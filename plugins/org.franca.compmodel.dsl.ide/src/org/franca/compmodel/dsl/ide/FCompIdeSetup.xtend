/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */
package org.franca.compmodel.dsl.ide

import com.google.inject.Guice
import org.eclipse.xtext.util.Modules2
import org.franca.compmodel.dsl.FCompRuntimeModule
import org.franca.compmodel.dsl.FCompStandaloneSetup

/**
 * Initialization support for running Xtext languages as language servers.
 */
class FCompIdeSetup extends FCompStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new FCompRuntimeModule, new FCompIdeModule))
	}
	
}
