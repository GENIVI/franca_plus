/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl.formatting;

import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter;
import org.eclipse.xtext.formatting.impl.FormattingConfig;
import org.eclipse.xtext.util.Pair;
import org.franca.compdeploymodel.dsl.services.FDeployGrammarAccess;

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#formatting
 * on how and when to use it
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an
 * example
 */
public class FDeployFormatter extends AbstractDeclarativeFormatter {

	@Override
	protected void configureFormatting(FormattingConfig c) {
		FDeployGrammarAccess f = (FDeployGrammarAccess) getGrammarAccess();
		
		c.setAutoLinewrap(132);

		// add newlines around comments
		c.setLinewrap(0, 1, 2).before(f.getSL_COMMENTRule());
		c.setLinewrap(0, 1, 2).before(f.getML_COMMENTRule());
		c.setLinewrap(0, 1, 1).after(f.getML_COMMENTRule());

		// format structured comment
		c.setIndentation(
				f.getFDAnnotationBlockAccess().getLessThanSignAsteriskAsteriskKeyword_0(),
				f.getFDAnnotationBlockAccess().getAsteriskAsteriskGreaterThanSignKeyword_2());
		c.setNoSpace().between(f.getFDAnnotationRule(), 
				f.getFDAnnotationBlockAccess().getAsteriskAsteriskGreaterThanSignKeyword_2());
		c.setLinewrap(1, 1, 2).after(f.getFDAnnotationBlockRule());

		// one line per "use"
		for (Keyword use : f.findKeywords("use", "provide", "require"))
			c.setLinewrap(1).before(use);

		// standard comma formatting
		for (Keyword comma : f.findKeywords(",")) {
			c.setNoLinewrap().before(comma);
			c.setNoSpace().before(comma);
		}
		
		for(Keyword dot: f.findKeywords(".")) {
			c.setNoLinewrap().before(dot);
			c.setNoSpace().before(dot);
			c.setNoSpace().after(dot);
//			c.setLinewrap().after(comma);
		}
		//Component Instance
		
		

		// generic formatting of curly bracket sections
		for (Pair<Keyword, Keyword> pair : f.findKeywordPairs("{", "}")) {
			c.setIndentationIncrement().after(pair.getFirst());
			c.setIndentationDecrement().before(pair.getSecond());
			c.setLinewrap(1).after(pair.getFirst());
			c.setLinewrap(1).before(pair.getSecond());
			c.setLinewrap(1).after(pair.getSecond());
		}

		for (Keyword dot : f.findKeywords(".")) {
			c.setNoSpace().before(dot);
			c.setNoSpace().after(dot);
		}

		// property declaration lists in deployment specification
		c.setLinewrap(1).around(f.getFDPropertyDeclRule());

		// property lists
		c.setLinewrap(1).around(f.getFDPropertyRule());

		// top-level formatting
		c.setLinewrap(1).around(f.getImportRule());
		c.setLinewrap(2).before(f.getFDSpecificationRule());
		c.setLinewrap(2).before(f.getFDTypesRule());
		c.setLinewrap(2).before(f.getFDInterfaceRule());
		c.setLinewrap(2).around(f.getFDAttributeRule());
		c.setLinewrap(2).around(f.getFDMethodRule());
		c.setLinewrap(2).around(f.getFDBroadcastRule());
		c.setLinewrap(2).around(f.getFDTypeDefinitionRule());
		c.setLinewrap(2).around(f.getFDServiceRule());
		c.setLinewrap(2).around(f.getFDComponentRule());
		c.setLinewrap(2).around(f.getFDDeviceRule());

		c.setLinewrap(2).around(f.getFDProvidedPortRule());
		c.setLinewrap(2).around(f.getFDRequiredPortRule());
		c.setLinewrap(2).around(f.getFDComAdapterRule());

		// some details...
		c.setNoLinewrap().after(f.getFDTypesAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDTypesAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDServiceAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDServiceAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDComponentAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDComponentAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDDeviceAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDDeviceAccess().getForKeyword_3());
		
		c.setNoLinewrap().after(f.getFDTypesAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDTypesAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getAsKeyword_6_0());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getForKeyword_3());
		
		// no linewraps for imports 
		c.setNoLinewrap().after(f.getImportAccess().getImportKeyword_0());
		c.setNoLinewrap().before(f.getImportAccess().getImportURISTRINGTerminalRuleCall_1_0_0());
		
		//variant
		c.setNoLinewrap().after(f.getFDVariantAccess().getDefineKeyword_1());
		c.setNoLinewrap().after(f.getFDVariantAccess().getVariantKeyword_2());
		c.setNoLinewrap().after(f.getFDVariantAccess().getNameAssignment_3());
		c.setNoLinewrap().after(f.getFDVariantAccess().getNameIDTerminalRuleCall_3_0());
		c.setNoLinewrap().after(f.getFDVariantAccess().getForKeyword_4());
		c.setNoLinewrap().after(f.getFDVariantAccess().getRootKeyword_5());
		
		//define
		c.setNoLinewrap().after(f.getFDServiceAccess().getDefineKeyword_1());
		c.setNoLinewrap().after(f.getFDServiceAccess().getSpecAssignment_2());
		c.setNoLinewrap().after(f.getFDServiceAccess().getSpecFDSpecificationCrossReference_2_0());
		c.setNoLinewrap().after(f.getFDServiceAccess().getSpecFDSpecificationFQNParserRuleCall_2_0_1());
		c.setNoLinewrap().after(f.getFDServiceAccess().getForKeyword_3());
		c.setNoLinewrap().after(f.getFDServiceAccess().getServiceKeyword_4());
		c.setNoLinewrap().after(f.getFDServiceAccess().getTargetAssignment_5());
		c.setNoLinewrap().before(f.getFDServiceAccess().getAsKeyword_6_0());
		c.setNoLinewrap().before(f.getFDServiceAccess().getNameAssignment_6_1());
		c.setNoLinewrap().before(f.getFDServiceAccess().getNameIDTerminalRuleCall_6_1_0());
	}
}
