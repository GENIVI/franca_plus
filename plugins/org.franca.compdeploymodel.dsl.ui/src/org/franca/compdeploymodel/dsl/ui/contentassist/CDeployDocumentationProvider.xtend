/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compdeploymodel.dsl.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.franca.compdeploymodel.dsl.cDeploy.FDAnnotationBlock

class CDeployDocumentationProvider extends MultiLineCommentDocumentationProvider {
	
	/**
	 * Deliver a documentation for the hover including
	 * normal comments and structured comments
	 */
	override String getDocumentation(EObject o) {
		val comment = super.getDocumentation(o)
		var structuredComment = ""
		switch o { 
			// types with comment
			// TODO: enable the structured comments in CDeploy
			// FDElement: structuredComment += o.comment.string 
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
	
	def String getString(FDAnnotationBlock ab) {
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
