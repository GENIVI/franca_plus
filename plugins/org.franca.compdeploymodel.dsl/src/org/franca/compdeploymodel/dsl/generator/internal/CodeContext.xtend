/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl.generator.internal

import org.franca.compdeploymodel.dsl.generator.internal.ICodeContext

class CodeContext implements ICodeContext {
	
	boolean targetIsNeeded = false
	
	override requireTargetMember() {
		targetIsNeeded = true
	}

	def isTargetNeeded() {
		targetIsNeeded
	}	
}