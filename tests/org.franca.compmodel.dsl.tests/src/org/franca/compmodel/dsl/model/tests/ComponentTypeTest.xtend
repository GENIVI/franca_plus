/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import com.google.inject.Inject

import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.tests.FCompInjectorProvider
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.InjectWith

@RunWith(XtextRunner)
@InjectWith(FCompInjectorProvider)
class ComponentTypeTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	@Test
	def void testComponentName()
	{
		val model = '''
		package test
		component comp{} 
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertEquals(1, model.components.size)
	}
	
		@Test
	def void testModelWithVersion()
	{
		val model = '''
		package test
		
		component comp
		{
		version{major 47 minor 11}
		}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals(47, model.components.get(0).version.major)
		Assert.assertEquals(11, model.components.get(0).version.minor)
	}
	
	@Test
	def void testServiceComponent()
	{
		val model = '''
		package test
		service component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertTrue(model.components.get(0).service)
	}
	
	@Test
	def void testAbstractComponent()
	{
		val model = '''
		package test
		abstract component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertFalse(model.components.get(0).service)
		Assert.assertTrue(model.components.get(0).abstract)
	}
	
	@Test
	def void testAbstractServiceComponent()
	{
		val model = '''
		package test
		abstract service component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertTrue(model.components.get(0).service)
		Assert.assertTrue(model.components.get(0).abstract)
	}
	
	@Test
	def void testSingletonComponent()
	{
		val model = '''
		package test
		singleton component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertFalse(model.components.get(0).service)
		Assert.assertTrue(model.components.get(0).singleton)
	}
	
	@Test
	def void testSingletonServiceComponent()
	{
		val model = '''
		package test
		singleton service component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertTrue(model.components.get(0).service)
		Assert.assertTrue(model.components.get(0).singleton)
	}
	
	@Test
	def void testSingletonAbstractComponent()
	{
		val model = '''
		package test
		singleton abstract component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertTrue(model.components.get(0).abstract)
		Assert.assertTrue(model.components.get(0).singleton)
	}
	
	@Test
	def void testAbstractSingletonServiceComponent()
	{
		val model = '''
		package test
		abstract singleton service component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("comp", model.components.get(0).name)
		Assert.assertTrue(model.components.get(0).abstract)
		Assert.assertTrue(model.components.get(0).singleton)
		Assert.assertTrue(model.components.get(0).service)
		
	}
}