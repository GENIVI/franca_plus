/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.highlighting

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.CrossReference
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.franca.compmodel.dsl.services.FCompGrammarAccess
import org.franca.compmodel.dsl.fcomp.FCTagDecl

/* see also https://github.com/mn-mikke/Model-driven-Pretty-Printer-for-Xtext-Framework.wiki.git */
public class FCompSemanticHighlightCalculator implements ISemanticHighlightingCalculator {
	
	@Inject
	private FCompGrammarAccess ga
	
	@Inject
	private EObjectAtOffsetHelper helper

	override void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor) {
		if (resource === null || resource.getParseResult() === null)
			return;

		var INode root = resource.getParseResult().getRootNode();
		for (INode node : root.getAsTreeIterable()) {
			var EObject obj = node.getGrammarElement();
			
			if (obj instanceof CrossReference) {
				if (ga.FCAnnotationAccess.tagFCTagDeclCrossReference_0_1_0 === obj) {
					var EObject target = helper.resolveElementAt(resource, node.getOffset());
					if (target instanceof FCTagDecl)
						acceptor.addPosition(node.getOffset(), node.getLength(), 
							FCompHighlightingConfiguration.HL_TAG_ANNOTATION_ID
						);
				}
			}
			else if (obj instanceof RuleCall) {
				var String name = obj.getRule().getName();
				if (name.equals("FCBuiltinAnnotationType")) {
					acceptor.addPosition(node.getOffset(), node.getLength(),
						FCompHighlightingConfiguration.HL_SIMPLE_ANNOTATION_ID);
				}
				else if (name.equals("TAG_ID")) {
					acceptor.addPosition(node.getOffset(), node.getLength(),
						FCompHighlightingConfiguration.HL_TAG_ANNOTATION_ID);
				}
				else if (name.equals("ANNOTATION_VALUE")) {
					acceptor.addPosition(node.getOffset(), node.getLength(),
						FCompHighlightingConfiguration.HL_ANNOTATION_VALUE_ID);
				}
				
			}
		}

	}
}