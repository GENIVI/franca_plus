/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compmodel.dsl.valueconverter

import org.eclipse.xtext.common.services.Ecore2XtextTerminalConverters
//import org.eclipse.xtext.conversion.IValueConverter
//import org.eclipse.xtext.conversion.ValueConverter
//import org.eclipse.xtext.conversion.impl.AbstractNullSafeConverter
//import org.eclipse.xtext.nodemodel.INode
//import org.eclipse.xtext.conversion.ValueConverterException

public class FCompValueConverters extends Ecore2XtextTerminalConverters {
	
//	@ValueConverter(rule = "AT_ALPHA_NUMERIC_ID")
//	public def IValueConverter<String> AT_ALPHA_NUMERIC_ID() {
//		return new AbstractNullSafeConverter<String>() {
//			override String internalToValue(String string, INode node) {
//				var String value = string
//				// cut trailing whitespace or newlines
//				var int j = string.length()-1;
//				while (j>=0 && Character.isWhitespace(string.charAt(j))) {
//					j--;
//				}
//				
//				if (j>=0) {
//					value = string.substring(0, j+1);
//				}
//				return value.replaceFirst('@', '');
//			}
//			
//			override String internalToString(String value) {
//				return '@' + value;
//			}			
//		};
//	}
}
