/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FCompStandaloneSetup extends FCompStandaloneSetupGenerated{

	public static void doSetup() {
		new FCompStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}