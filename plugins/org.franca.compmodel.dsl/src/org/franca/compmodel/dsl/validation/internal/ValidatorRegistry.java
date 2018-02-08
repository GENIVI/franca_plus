/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * based on work of Klaus Birken (2013 itemis AG (http://www.itemis.de)
 *  
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.validation.internal;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.xtext.validation.CheckMode;
import org.franca.compmodel.dsl.validation.IFCompExternalValidator;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public class ValidatorRegistry {

	private static final String EXTENSION_POINT_ID = "org.franca.compmodel.dsl.francaplusValidator";
	private static Multimap<CheckMode, IFCompExternalValidator> validatorMap;
	
	public static final String MODE_EXPENSIVE = "EXPENSIVE";
	public static final String MODE_NORMAL = "NORMAL";
	public static final String MODE_FAST = "FAST";
			
	public static Multimap<CheckMode, IFCompExternalValidator> getValidatorMap() {
		if (validatorMap == null) {
			initializeValidators();
		}
		return validatorMap;
	}
	
	/**
	 * Add validator to registry with a given check mode.
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * 
	 * @param validator the external Franca IDL validator
	 * @param mode the proper check mode
	 */
	public static void addValidator(IFCompExternalValidator validator, String mode) {
		if (validatorMap == null) {
			validatorMap = ArrayListMultimap.create();
		}

		putToMap(validator, mode);
 	}
	
	public static void removeValidator(IFCompExternalValidator validator) {
		if (validatorMap != null) {
			removeFromMap(validator);
		}
 	}

	private static void initializeValidators() {
		validatorMap = ArrayListMultimap.create();

		IExtensionRegistry reg = Platform.getExtensionRegistry();
		if (reg==null) {
			// standalone mode, we cannot get validators from extension point registry
			return;
		}
		IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID);

		for (IExtension extension : ep.getExtensions()) {
			for (IConfigurationElement ce : extension
					.getConfigurationElements()) {
				if (ce.getName().equals("validator")) {
					try {
						Object o = ce.createExecutableExtension("class");
						if (o instanceof IFCompExternalValidator) {
							String mode = ce.getAttribute("mode");
							IFCompExternalValidator validator = (IFCompExternalValidator) o;
							putToMap(validator, mode);
						}
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}
	
	private static void putToMap (IFCompExternalValidator validator, String mode) {
		validatorMap.put(CheckMode.ALL, validator);
		
		if (mode.matches(MODE_EXPENSIVE)) {
			validatorMap.put(CheckMode.EXPENSIVE_ONLY, validator);
		} else if (mode.matches(MODE_NORMAL)) {
			validatorMap.put(CheckMode.NORMAL_ONLY, validator);
			validatorMap.put(CheckMode.NORMAL_AND_FAST, validator);
		} else {
			validatorMap.put(CheckMode.FAST_ONLY, validator);
			validatorMap.put(CheckMode.NORMAL_AND_FAST, validator);
		}
	}
	
	private static void removeFromMap(IFCompExternalValidator validator)
	{
		if(validatorMap.containsValue(validator))
		{
			validatorMap.remove(CheckMode.ALL, validator);
		}
	}
}
