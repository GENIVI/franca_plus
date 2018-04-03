package org.franca.compmodel.dsl.visual


import com.google.inject.Inject
import org.eclipse.xtext.GrammarToDot
import org.eclipse.xtext.IGrammarAccess
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.eclipse.xtext.xbase.lib.InputOutput.*
import org.franca.compmodel.dsl.tests.FCompInjectorProvider
import org.junit.Ignore

@RunWith(XtextRunner)
@InjectWith(FCompInjectorProvider)
class FCompVisual {

	@Inject extension IGrammarAccess
	@Inject extension GrammarToDot

	@Ignore
	@Test def void visualizeGrammar(){
		grammar.draw.println
	}
}