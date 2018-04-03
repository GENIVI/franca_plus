/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html.
 */

package org.franca.compmodel.dsl.formatting2

import javax.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.franca.compmodel.dsl.fcomp.FCAnnotation
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComAdapter
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.Import
import org.franca.compmodel.dsl.services.FCompGrammarAccess

// Discouraged Access because this API is not final and will maybe 
// not provide backwards compatibility with upcoming versions 
@SuppressWarnings("all")
class FCompFormatter extends AbstractFormatter2 {

	@Inject extension FCompGrammarAccess fcga

	def dispatch void format(FCModel fCModel, extension IFormattableDocument document) {
		val lastImport = fCModel.imports.last
		val firstImport = fCModel.imports.stream.findFirst
		for (Import _import : fCModel.getImports()) {
			_import.format
			if (_import === firstImport.get)
				_import.prepend[setNewLines(2)]
			if (_import === lastImport)
				_import.append[setNewLines(2)]
			else
				_import.append[setNewLines(1)]
		}

		for (FCComponent fCComponent : fCModel.getComponents()) {
			fCComponent.surround[setNewLines(2)]
			fCComponent.format;
		}

		for (FCDevice fCDevice : fCModel.getDevices()) {
			fCDevice.surround[setNewLines(2)]
			fCDevice.format;
		}

		fCModel.regionFor.ruleCallTo(ML_COMMENTRule).surround[newLine]
	}

	def dispatch void format(FCAnnotationBlock fCAnnotationBlock, extension IFormattableDocument document) {
		val open = fCAnnotationBlock.regionFor.keyword(
			fcga.FCAnnotationBlockAccess.lessThanSignAsteriskAsteriskKeyword_1)
		val close = fCAnnotationBlock.regionFor.keyword(
			fcga.FCAnnotationBlockAccess.asteriskAsteriskGreaterThanSignKeyword_3)

		interior(open, close)[highPriority indent]
		open.prepend[lowPriority newLine]
		open.append[newLine]
		fCAnnotationBlock.elements.forEach[format]
		close.append[newLine]
		fCAnnotationBlock.append[newLine]
	}

	def dispatch void format(FCAnnotation fCAnnotation, extension IFormattableDocument document) {
		// prevent adding new line by suppress adding extra newline formatter call after terminal symbol	
		var ISemanticRegion region = fCAnnotation.regionFor.ruleCall(
			fcga.FCAnnotationAccess.valueANNOTATION_VALUETerminalRuleCall_1_0)
		if (region !== null) {
				
			if (region.text.contains("\n"))
				region.append[lowPriority setNewLines(0, 0, 0)]
			else
				region.append[lowPriority setNewLines(1, 1, 1)]
				
			// pretty print the value "@tag: value"
			region = fCAnnotation.regionFor.ruleCall(
				fcga.FCAnnotationAccess.kindFCBuiltinAnnotationTypeEnumRuleCall_0_0_0)?.append[noSpace]
			region = fCAnnotation.regionFor.ruleCall(fcga.FCAnnotationAccess.tagFCTagDeclTAG_IDParserRuleCall_0_1_0_1)?.
				append[noSpace]
		} 
		else
			fCAnnotation.append[lowPriority setNewLines(1, 1, 1)]	
	}

	def dispatch void format(FCComponent fCComponent, extension IFormattableDocument document) {
		
		fCComponent.comment?.format
		
		// keep the component modifier together with the component name in one line
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.singletonSingletonKeyword_2_2_0).surround[oneSpace]
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.abstractAbstractKeyword_2_0_0).surround[oneSpace]
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.serviceServiceKeyword_2_3_0).surround[oneSpace]
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.rootRootKeyword_2_1_0).surround[oneSpace]
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.componentKeyword_3).surround[oneSpace]
		fCComponent.regionFor.ruleCall(fcga.FCComponentAccess.nameIDTerminalRuleCall_4_0).surround[oneSpace]
		fCComponent.regionFor.keyword(fcga.FCComponentAccess.extendsKeyword_5_0).surround[oneSpace]
		fCComponent.regionFor.ruleCall(fcga.FCComponentAccess.superTypeFCComponentFQNParserRuleCall_5_1_0_1).surround[oneSpace]
		
		val lastProto = fCComponent.prototypes.last
		val lastRequiredPort = fCComponent.requiredPorts.last
		val lastProvidedPort = fCComponent.providedPorts.last
		val lastDeleagtion = fCComponent.delegates.last
		val lastConnector = fCComponent.assembles.last
		val lastInject = fCComponent.injections.last

		val brackets = fCComponent.regionFor.keywordPairs("{", "}")

		for (Pair<ISemanticRegion, ISemanticRegion> p : brackets) {
			p.key.append[setNewLines(1)]
			interior(p)[indent]
		}

		for (FCGenericPrototype proto : fCComponent.prototypes) {
			proto.comment?.format
			if (proto === lastProto) {
				if (proto.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					proto.append[setNewLines(1)]
				else
					proto.append[setNewLines(2)]
			} else
				proto.append[setNewLines(1)]
			proto.regionFor.keyword(fcga.FCPrototypeAccess.asKeyword_4_0).surround[oneSpace]
		}

		for (FCPort requiredPort : fCComponent.requiredPorts) {
			requiredPort.comment?.format
			if (requiredPort === lastRequiredPort) {
				if (requiredPort.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					requiredPort.append[setNewLines(1)]
				else
					requiredPort.append[setNewLines(2)]
			} else
				requiredPort.append[setNewLines(1)]
			requiredPort.regionFor.keyword(fcga.FCRequiredPortAccess.asKeyword_5_0).surround[oneSpace]
		}

		for (FCPort providedPort : fCComponent.providedPorts) {
			providedPort.comment?.format
			if (providedPort === lastProvidedPort) {
				if (providedPort.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					providedPort.append[setNewLines(1)]
				else
					providedPort.append[setNewLines(2)]
			} else
				providedPort.append[setNewLines(1)]
			providedPort.regionFor.keyword(fcga.FCProvidedPortAccess.asKeyword_4_0).surround[oneSpace]
			
		}

		for (FCDelegateConnector delegate : fCComponent.delegates) {
			delegate.comment?.format
			if (delegate === lastDeleagtion) {
				if (delegate.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					delegate.append[setNewLines(1)]
				else
					delegate.append[setNewLines(2)]
			} else
				delegate.append[setNewLines(1)]
			delegate.regionFor.keyword(fcga.FCDelegateConnectorAccess.toKeyword_4).surround[oneSpace]
		}

		for (FCAssemblyConnector assembly : fCComponent.assembles) {
			assembly.comment?.format
			if (assembly === lastConnector) {
				if (assembly.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					assembly.append[setNewLines(1)]
				else
					assembly.append[setNewLines(2)]
			} else
				assembly.append[setNewLines(1)]
			assembly.regionFor.keyword(fcga.FCAssemblyConnectorAccess.toKeyword_3).surround[oneSpace]
		}

		for (FCGenericPrototype inject : fCComponent.injections) {
			inject.comment?.format
			if (inject === lastInject) {
				if (inject.nextHiddenRegion.nextSemanticRegion.identityEquals(brackets.get(0).value))
					inject.append[setNewLines(1)]
				else
					inject.append[setNewLines(2)]
			} else
				inject.append[setNewLines(1)]
			inject.regionFor.keyword(fcga.FCInjectionModifierAccess.finallyFinallyKeyword_0).surround[oneSpace]
			inject.regionFor.keyword(fcga.FCPrototypeInjectionAccess.asKeyword_4_0).surround[oneSpace]
		}
	}

	def dispatch void format(FCDevice fCDevice, extension IFormattableDocument document) {
		fCDevice.comment.format
		interior(fCDevice.regionFor.keyword("{").append[newLine], fCDevice.regionFor.keyword("}"), [indent])
		fCDevice.adapters.forEach[format]
		fCDevice.devices.forEach[{ surround[newLine] format }]
	}

	def dispatch void format(FCComAdapter fCAdapter, extension IFormattableDocument document) {
		fCAdapter.comment?.format
		fCAdapter.surround[setNewLines(1)]
	}
}
