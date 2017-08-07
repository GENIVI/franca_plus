/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.ui.highlighting

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor;
import org.eclipse.xtext.ui.editor.utils.TextStyle;

/* see also https://github.com/mn-mikke/Model-driven-Pretty-Printer-for-Xtext-Framework.wiki.git */
class FCompHighlightingConfiguration extends DefaultHighlightingConfiguration {
	// provide an id string for the highlighting calculator
	val static public String HL_ANNOTATION_BLOCK_ID = "hl_annotation_block"
	val static public String HL_SIMPLE_ANNOTATION_ID = "hl_simple_annotation"
	val static public String HL_TAG_ANNOTATION_ID = "hl_tag_annotation"
	val static public String HL_ANNOTATION_VALUE_ID = "hl_annotation_text"
	
	// default fonts used by this specific highlighting (defaults)
//	private static FontData defaultAnnotationBlockFont = new FontData("Courier New", 12);

	// configure the acceptor providing the id, the description string
	// that will appear in the preference page and the initial text style
	override void configure(IHighlightingConfigurationAcceptor acceptor) {
		super.configure(acceptor)
		acceptor.acceptDefaultHighlighting(HL_ANNOTATION_BLOCK_ID, "Annotation Block", typeAnnotationBlock())
		acceptor.acceptDefaultHighlighting(HL_SIMPLE_ANNOTATION_ID, "Simple Annotation", typeSimpleAnnotation())
		acceptor.acceptDefaultHighlighting(HL_TAG_ANNOTATION_ID, "Tag Annotation", typeTagAnnotation())
		acceptor.acceptDefaultHighlighting(HL_ANNOTATION_VALUE_ID, "Annotation Text", typeAnnotationValue())
	}

	// method for calculating an actual text styles
	def TextStyle typeAnnotationBlock() {
		var textStyle = new TextStyle()
		textStyle.setColor(new RGB(63, 72, 204))
		// textStyle.setStyle(SWT.ITALIC);
		return textStyle
	}
	
	def TextStyle typeSimpleAnnotation() {
		var textStyle = new TextStyle()
		textStyle.setColor(new RGB(150, 150, 50))
		textStyle.setStyle(SWT.ITALIC);
		return textStyle
	}
	
	def TextStyle typeAnnotationValue() {
		var textStyle = new TextStyle()
		// textStyle.setColor(new RGB(63, 72, 204))
		textStyle.setStyle(SWT.ITALIC);
		return textStyle
	}
	
	def TextStyle typeTagAnnotation() {
		var textStyle = new TextStyle()
		textStyle.setColor(new RGB(63, 72, 204))
		textStyle.setStyle(SWT.ITALIC);
		return textStyle
	}
}