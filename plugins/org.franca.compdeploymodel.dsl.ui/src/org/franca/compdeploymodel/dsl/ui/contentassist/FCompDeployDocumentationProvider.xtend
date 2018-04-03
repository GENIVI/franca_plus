/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compdeploymodel.dsl.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.franca.compdeploymodel.dsl.fDeploy.FDAnnotationBlock
import org.franca.compdeploymodel.dsl.fDeploy.FDElement

class FCompDeployDocumentationProvider extends MultiLineCommentDocumentationProvider {
	
	/**
	 * Deliver a documentation for the hover including
	 * normal comments and structured comments
	 */
	override String getDocumentation(EObject o) {
		val comment = super.getDocumentation(o)
		var structuredComment = ""
		switch o { 
			// component model types with comment
			FDElement: structuredComment += o.comment.string 
		}
		if (comment !== null && structuredComment.length > 0)
			// documentation is displayed as HTML, 
			// and surrounded by paragraph tags
			comment + "</p><p>" + structuredComment
		else if (comment !== null)
			comment
		else 
			structuredComment
	}
	
	def private String getString(FDAnnotationBlock ab) {
		val StringBuilder anno = new StringBuilder
		if (ab !== null ) {
			ab.elements.forEach[
				anno.append("<i>" + type.toString + "</i>: " + comment.replace("\n", "<br/>"))
			]
			anno.append("<br/>")
		}
		
		anno.toString
	}
}
