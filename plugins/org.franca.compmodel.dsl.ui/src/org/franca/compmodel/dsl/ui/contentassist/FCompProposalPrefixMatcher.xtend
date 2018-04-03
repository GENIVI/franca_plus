/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.contentassist

import org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher

class FCompProposalPrefixMatcher extends FQNPrefixMatcher {
	
	override isCandidateMatchingPrefix(String name, String prefix) {
		
		var String newPrefix = null
		
		if (prefix.contains("classpath:")) 
			newPrefix = prefix.substring(prefix.indexOf(':') + 1)
		else 
			newPrefix = prefix

		if (name.endsWith(".fcdl") || name.endsWith(".fidl"))
			delimiter = '/'
		else
			delimiter = '.'
		super.isCandidateMatchingPrefix(name, newPrefix)	
	}	
}