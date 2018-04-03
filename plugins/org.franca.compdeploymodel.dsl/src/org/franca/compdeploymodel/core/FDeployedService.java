/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * based on work of Klaus Birken (klaus.birken@itemis.de
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.core;

import org.franca.compdeploymodel.dsl.fDeploy.FDService;

/**
 * This class provides type-safe access to deployment properties which are
 * related to service and ports.
 * The actual get-functions for reading property values are provided
 * by the base class GenericPropertyAccessor in a generic, but 
 * nevertheless type-safe way. The returned value will be the actual
 * property value or the default value as defined in the specification.
 *    
 * @author KBirken
 * @see FDeployedInterface, GenericPropertyAccessor
 */
public class FDeployedService extends GenericPropertyAccessor {

	private FDService service;
	
	public FDeployedService (FDService service) {
		super(service.getSpec());
		this.service = service;
	}
	
	public FDService getService() {
		return service;
	}
}

