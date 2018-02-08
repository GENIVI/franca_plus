/* Copyright (C) 2027 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 2.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v20.html. 
 */
 
package org.franca.compmodel.dsl.formatting

import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.franca.compmodel.dsl.services.FCompGrammarAccess
import com.google.inject.Inject

/**
 * This class contains custom formatting declarations.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#formatting
 * on how and when to use it.
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class FCompFormatter extends AbstractDeclarativeFormatter {

	@Inject extension FCompGrammarAccess
	
	override protected void configureFormatting(FormattingConfig c) {
		c.setLinewrap(0, 2, 2).before(getSL_COMMENTRule());
		c.setLinewrap(0, 2, 2).before(getML_COMMENTRule());
		c.setLinewrap(0, 2, 2).after(getML_COMMENTRule());
		
		
		findKeywords(",").forEach[
			c.setNoLinewrap().before(it);
			c.setNoSpace().before(it);
			c.setLinewrap().after(it);
		]
		
		findKeywords(".").forEach[
			c.setNoSpace.before(it);
			c.setNoSpace.after(it);
		]

		// generic formatting of curly bracket sections
		findKeywordPairs("{", "}").forEach[ 
			c.setIndentation(it.getFirst, it.getSecond);
			c.setLinewrap.after(it.getFirst);
			c.setLinewrap.before(it.getSecond);
			c.setLinewrap.after(it.getSecond);
		]
		
		//generic formatting of Annotation Blocks
		findKeywordPairs("<**", "**>").forEach[
			c.setIndentationIncrement.after(it.getFirst);
			c.setIndentationDecrement.before(it.getSecond);
		]
		//details for Annotation Blocks
		c.setLinewrap(2).before(FCAnnotationBlockRule);
		c.setLinewrap.around(FCAnnotationBlockAccess.getAlternatives_2);
		c.setLinewrap.after(FCAnnotationBlockAccess.getAsteriskAsteriskGreaterThanSignKeyword_3);
		
		// 'package' definition in model file
		c.setLinewrap(2).after(FCModelAccess.nameAssignment_1);
		
		//import rules
		c.setLinewrap.after(FCModelAccess.getImportsAssignment_2)
		
		//versioning
		c.setLinewrap.after(FCVersionAccess.getMajorAssignment_4);
		c.setLinewrap.after(FCVersionAccess.getMinorAssignment_6);
		
		
		//formatting inside component
		
		//linewrap of curly braces for the component itself
		c.setLinewrap(2).after(FCComponentAccess.leftCurlyBracketKeyword_6_0);
		c.setLinewrap(2).before(FCComponentAccess.rightCurlyBracketKeyword_6_3);
		
		//clustering ports
		c.setLinewrap(2).after(FCComponentAccess.requiredPortsAssignment_6_2_0);
		c.setLinewrap.after(FCComponentAccess.requiredPortsFCRequiredPortParserRuleCall_6_2_0_0);
		c.setLinewrap(2).after(FCComponentAccess.providedPortsAssignment_6_2_1);
		c.setLinewrap.after(FCComponentAccess.providedPortsFCProvidedPortParserRuleCall_6_2_1_0);
		
		//clustering prototypes
		c.setLinewrap(2).after(FCComponentAccess.prototypesAssignment_6_2_2);
		c.setLinewrap.after(FCComponentAccess.prototypesFCPrototypeParserRuleCall_6_2_2_0);
		
		//clustering injection
		c.setLinewrap(2).after(FCComponentAccess.injectionsAssignment_6_2_3);
		c.setLinewrap.after(FCComponentAccess.injectionsFCPrototypeInjectionParserRuleCall_6_2_3_0);
		
		//clustering assembly connectors
		c.setLinewrap(2).after(FCComponentAccess.assemblesAssignment_6_2_4);
		c.setLinewrap.after(FCComponentAccess.assemblesFCAssemblyConnectorParserRuleCall_6_2_4_0);
		
		//clustering delegations
		c.setLinewrap(2).after(FCComponentAccess.delegatesAssignment_6_2_5);
		c.setLinewrap.after(FCComponentAccess.delegatesFCDelegateConnectorParserRuleCall_6_2_5_0);
		
		//clustering devices
		c.setLinewrap(2).after(FCDeviceAccess.adaptersAssignment_3_1_0);
		c.setLinewrap.after(FCDeviceAccess.adaptersFCComAdapterParserRuleCall_3_1_0_0);
		
		//clustering adapters
		c.setLinewrap(2).after(FCComAdapterAccess.adapterKeyword_1);
		c.setLinewrap.after(FCComAdapterAccess.nameIDTerminalRuleCall_2_0);
		
		//components in general
		c.setLinewrap(2).after(getFCComponentRule);

		//ports
		c.setLinewrap.after(getFCProvidedPortRule);
		c.setLinewrap.after(getFCRequiredPortRule);
		
		//prototype containment
		c.setLinewrap.after(FCPrototypeRule)
		
		//assembly connectors
		c.setLinewrap.after(FCAssemblyConnectorRule);
		
		//delegations
		c.setLinewrap.after(FCDelegateConnectorRule);
		
		//implements
		c.setLinewrap.after(FCPrototypeInjectionRule);
		
		}
}
