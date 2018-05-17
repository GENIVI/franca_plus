/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui.labeling

/** 
 * Provides labels for IEObjectDescriptions and IResourceDescriptions.
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class CDeployDescriptionLabelProvider extends org.eclipse.xtext.ui.label.DefaultDescriptionLabelProvider { // Labels and icons can be computed like this:
	// String text(IEObjectDescription ele) {
	// return ele.getName().toString();
	// }
	//
	// String image(IEObjectDescription ele) {
	// return ele.getEClass().getName() + ".gif";
	// }	 
}
