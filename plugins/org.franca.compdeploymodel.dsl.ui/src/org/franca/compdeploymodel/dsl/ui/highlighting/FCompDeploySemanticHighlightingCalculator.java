package org.franca.compdeploymodel.dsl.ui.highlighting;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;

public class FCompDeploySemanticHighlightingCalculator implements ISemanticHighlightingCalculator {

	@Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
		if (resource == null || resource.getParseResult() == null)
			return;

		INode root = resource.getParseResult().getRootNode();
		for (INode node : root.getAsTreeIterable()) {
			EObject obj = node.getGrammarElement();
			if (obj instanceof RuleCall) {
				RuleCall ruleCall = (RuleCall) obj;
				String name = ruleCall.getRule().getName();
				if (name.equals("FDAnnotationBlock") || name.equals("CommentString")) {
					// System.out.println("Highlighting node " +
					// node.getOffset() + ", length " + node.getLength());
					acceptor.addPosition(node.getOffset(), node.getLength(),
							FCompDeployHighlightingConfiguration.HL_ANNOTATION_BLOCK_ID);
				}
			}
		}

	}
}
