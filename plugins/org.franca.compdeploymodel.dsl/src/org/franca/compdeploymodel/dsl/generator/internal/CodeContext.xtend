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