/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import org.junit.Test
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.junit4.util.ParseHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.junit.Assert
import org.franca.compmodel.dsl.fcomp.FCAnnotationType
import org.franca.compmodel.dsl.FCompInjectorProvider
import org.junit.Ignore

@RunWith(XtextRunner)
@InjectWith(FCompInjectorProvider)
class ModelTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	
	@Test
	def void mustAtLeastContainPackageAndName()
	{
		val model = ''''''.parse
		
		Assert.assertNull("Model should not be created", model)
	}
	
	
	@Test
	def void testModelName()
	{
		val model = '''
			package test
			'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("test", model.name)
	}
	
	@Test
	def void modelContainsComponent()
	{
		val model = '''
		package test
		component comp{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals(1, model.components.size)	
	}
	
	@Test
	def void modelContainsMultipleComponents()
	{
		val model = '''
		package test
		component comp1{}
		abstract component comp2{}
		service component comp3{}
		abstract service component comp4{}
		singleton service component comp5{}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals(5, model.components.size)
	}
	
	@Test
	def void modelContainsImport()
	{
		val model = '''
		package test
		import org.example from "testfidls/example1.fidl"
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals(1, model.imports.size)
		Assert.assertEquals("org.example", model.imports.get(0).importedNamespace)
		Assert.assertEquals("testfidls/example1.fidl", model.imports.get(0).importURI)
	}
	
	@Test
	def void modelContainsMultipleImports()
	{
		val model = '''
		package test
		import org.example from "testfidls/example1.fidl"
		import org.example from "testfidls/example2.fidl"
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals(2, model.imports.size)
		Assert.assertEquals("org.example", model.imports.get(0).importedNamespace)
		Assert.assertEquals("testfidls/example1.fidl", model.imports.get(0).importURI)
		Assert.assertEquals("org.example", model.imports.get(1).importedNamespace)
		Assert.assertEquals("testfidls/example2.fidl", model.imports.get(1).importURI)
	}
	
	@Test
	def void modelImportTagsModel()
	{
		val model = '''
		package test
		import model "testfcdls/Tags.fcdl"
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("testfcdls/Tags.fcdl", model.imports.get(0).importURI)
	}
	
	@Test
	def void modelImportAnnotateDefaultValue()
	{
		val model = '''
		package test
		
		<**@author: test author**>
		component comp{}
		'''.parse
		
		model.assertNoErrors
		
		val comp = model.components.get(0)		
		Assert.assertEquals(FCAnnotationType.AUTHOR, comp.comment.elements.get(0).kind)
		Assert.assertEquals(": test author", comp.comment.elements.get(0).value)
		Assert.assertNull(comp.comment.elements.get(0).tag)
	}
	
	@Ignore
	@Test
	def void modelImportAnnotateDefinedValue()
	{
		val model = '''
		package test
		
		import model "testfcdls/Tags.fcdl"
		
		<**@dienst: This is a Dienst**>
		component comp{}
		'''.parse
		
		model.assertNoErrors
		
		val comp = model.components.get(0)		
		Assert.assertEquals(FCAnnotationType.CUSTOM, comp.comment.elements.get(0).kind)
		Assert.assertEquals(": This is a Dienst", comp.comment.elements.get(0).value)
		Assert.assertEquals("@Dienst", comp.comment.elements.get(0).tag.name)
	}
	
	@Test
	def void modelCreateSingleSystem()
	{
		val model = '''
		package test
		component comp{}
		system Sys with root comp{}
		'''.parse
		
		model.assertNoErrors
	
		Assert.assertEquals(1, model.systems.size)
		Assert.assertEquals(model.components.get(0), model.systems.get(0).root.component)
	}
	
	@Test
	def void modelCreateMultipleSystems()
	{
		val model = '''
		package test
		component comp{}
		component comp1{}
		system Sys with root comp{}
		system Sys1 with root comp1{}
		'''.parse
		
		model.assertNoErrors
	
		Assert.assertEquals(2, model.systems.size)
		Assert.assertEquals(model.components.get(0), model.systems.get(0).root.component)
		Assert.assertEquals(model.components.get(1), model.systems.get(1).root.component)
	}

}