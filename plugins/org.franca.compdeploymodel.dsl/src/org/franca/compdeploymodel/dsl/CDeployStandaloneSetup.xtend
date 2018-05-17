/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */
package org.franca.compdeploymodel.dsl


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class CDeployStandaloneSetup extends CDeployStandaloneSetupGenerated {

	def static void doSetup() {
		new CDeployStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
