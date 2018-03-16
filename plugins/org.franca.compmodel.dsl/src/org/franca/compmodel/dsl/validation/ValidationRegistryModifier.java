/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.validation;

import org.franca.compmodel.dsl.validation.internal.ValidatorRegistry;

//This class is provided for test puropses only
public class ValidationRegistryModifier 
{
	public static void addExternalValidator(IFCompExternalValidator validator, String mode)
	{
		ValidatorRegistry.addValidator(validator, mode);
	}
	
	public static void removeExternalValidator(IFCompExternalValidator validator)
	{
		ValidatorRegistry.removeValidator(validator);
	}
}
