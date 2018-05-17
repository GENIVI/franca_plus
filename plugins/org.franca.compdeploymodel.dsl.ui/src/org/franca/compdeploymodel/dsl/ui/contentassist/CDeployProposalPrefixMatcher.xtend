/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui.contentassist

import org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher

class CDeployProposalPrefixMatcher extends FQNPrefixMatcher {
	
	override isCandidateMatchingPrefix(String name, String prefix) {
		
		var String newPrefix = null
		
		if (prefix.contains("platform:") || prefix.contains("classpath:")) 
			newPrefix = prefix.substring(prefix.indexOf(':') + 1)
		else 
			newPrefix = prefix

		if (name.endsWith(".fcdl") || name.endsWith(".fidl") || 
			name.endsWith(".fdepl") || name.endsWith(".cdepl")
		)
			super.delimiter = '/'
		else
			super.delimiter = '.'
		super.isCandidateMatchingPrefix(name, newPrefix)	
	}
	
//	public static class MyLastSegmentFinder implements LastSegmentFinder {
//
//		/**
//		 * Returns the filename and not the file extension
//		 */
//		override String getLastSegment(String fqn, char delimiter) {
//			val segments = fqn.split("\\.")
//			val index = segments.length - 2
//			if (index >= 0)
//				return segments.get(index)
//			else
//				return null
//		}	
//	}	
}