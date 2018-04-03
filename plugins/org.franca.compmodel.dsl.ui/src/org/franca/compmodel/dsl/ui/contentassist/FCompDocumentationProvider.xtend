/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compmodel.dsl.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComAdapter
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection
import org.franca.compmodel.dsl.fcomp.FCProvidedPort
import org.franca.compmodel.dsl.fcomp.FCRequiredPort

class FCompDocumentationProvider extends MultiLineCommentDocumentationProvider {
	
	/**
	 * Deliver a documentation for the hover including
	 * normal comments and structured comments
	 */
	override String getDocumentation(EObject o) {
		val comment = super.getDocumentation(o)
		var structuredComment = ""
		switch o { 
			// component model types with comment
			FCComponent: structuredComment += o.comment.string 
			FCRequiredPort: structuredComment += o.comment.string
			FCProvidedPort: structuredComment += o.comment.string
			FCDevice: structuredComment += o.comment.string
			FCComAdapter: structuredComment += o.comment.string
			FCAssemblyConnector: structuredComment += o.comment.string
			FCDelegateConnector: structuredComment += o.comment.string
			FCPrototype: structuredComment += o.comment.string
			FCPrototypeInjection: structuredComment += o.comment.string
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
	
	def private String getString(FCAnnotationBlock ab) {
		val StringBuilder anno = new StringBuilder
		if (ab !== null ) 
			for (a: ab.elements) {
				anno.append("<i>" + a.kind.toString + "</i>" + a.value?.replace("\n", "<br/>"))
			}
		
		anno.toString
	}
}