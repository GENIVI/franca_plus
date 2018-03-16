/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compmodel.dsl.validator.tests

import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.junit4.util.ParseHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.franca.compmodel.dsl.fcomp.FcompPackage
import org.junit.Before
import org.franca.compmodel.dsl.external.validator.ExternalTestValidator
import org.franca.compmodel.dsl.validation.ValidationRegistryModifier
import org.junit.After

@RunWith(XtextRunner2)
@InjectWith(MultiInjectorProvider)
class ExternalValidationTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	ExternalTestValidator exVal = new ExternalTestValidator
	
	@Before
	def void init(){
		ValidationRegistryModifier.addExternalValidator(exVal, "FAST" );
	}
	
	@After
	def void removeExternalValidator(){
		ValidationRegistryModifier.removeExternalValidator(exVal)
	}
	
	@Test
	def void externalValidatorACommentSectionMustBeAvailable()
	{
		val model = '''
		package test
		
		component testcomp{}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_COMPONENT, null,
			"A comment section is required")
	}
	
	@Test
	def void externalValidatorAtagIsRequiredInsideTheCommentSection()
	{
		val model = '''
		package test
		<** **>
		component testcomp{}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_ANNOTATION_BLOCK, null,
			"A Tag is required inside the comment section")
	}
	
	@Test
	def void externalValidatorAndTagIsGiven()
	{
		val model = '''
		package test
		<**@author: Felix **>
		component testcomp{}
		'''.parse
		
		model.assertNoErrors
	}
}
	