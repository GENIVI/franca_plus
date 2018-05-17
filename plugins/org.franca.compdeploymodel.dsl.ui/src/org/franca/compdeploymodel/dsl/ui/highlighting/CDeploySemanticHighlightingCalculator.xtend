/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compdeploymodel.dsl.ui.highlighting

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator

class CDeploySemanticHighlightingCalculator implements ISemanticHighlightingCalculator {
	override void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor,
		CancelIndicator cancelIndicator) {
		if(resource === null || resource.getParseResult() === null) return;
		var INode root = resource.getParseResult().getRootNode()
		for (INode node : root.getAsTreeIterable()) {
			var EObject obj = node.getGrammarElement()
			if (obj instanceof RuleCall) {
				var RuleCall ruleCall = (obj as RuleCall)
				var String name = ruleCall.getRule().getName()
				if (name.equals("FDAnnotationBlock") || name.equals("CommentString")) {
					// System.out.println("Highlighting node " +
					// node.getOffset() + ", length " + node.getLength());
					acceptor.addPosition(node.getOffset(), node.getLength(),
						CDeployHighlightingConfiguration.HL_ANNOTATION_BLOCK_ID)
				}
			}
		}
	}
}
