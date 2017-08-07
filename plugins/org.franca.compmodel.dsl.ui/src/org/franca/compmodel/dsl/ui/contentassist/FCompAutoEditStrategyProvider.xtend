/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.contentassist
 
import org.eclipse.xtext.ui.editor.autoedit.DefaultAutoEditStrategyProvider
import org.eclipse.xtext.ui.editor.autoedit.AbstractEditStrategyProvider
import org.eclipse.jface.text.IDocument

class FCompAutoEditStrategyProvider extends DefaultAutoEditStrategyProvider {
	override public void configureStringLiteral(AbstractEditStrategyProvider.IEditStrategyAcceptor acceptor) {
		super.configureStringLiteral(acceptor)
		acceptor.accept(singleLineTerminals.newInstance("<**", " **>"), IDocument.DEFAULT_CONTENT_TYPE)
		// acceptor.accept(multiLineTerminals.newInstance("<**", " ** ", " **>"), IDocument.DEFAULT_CONTENT_TYPE)
	}
}