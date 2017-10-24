/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.validation;

import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.compmodel.dsl.fcomp.FCModel;

public interface IFCompExternalValidator 
{
	/**
	 * This method is used to perform external validation logic on a given Franca Component File (.fcdl). 
	 * 
	 * @param model the FrancaPlus model created from the FCDL file
	 * @param messageAcceptor the message acceptor to log the validation messages
	 */
	
	public void validateModel(FCModel model, ValidationMessageAcceptor messageAcceptor);
}
