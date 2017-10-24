/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.junit4.util.ParseHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.junit.Assert
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.junit.Ignore

@RunWith(XtextRunner2)
@InjectWith(MultiInjectorProvider)
class SimpleComponentTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	@Test
	def void ComponentProvidePort()
	{
		
		val model = '''
		package test
		import org.example.* from "testfidls/example1.fidl"
		
		component comp
		{
			provides FirstTestInterface as interface
		}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("FirstTestInterface", model.components.get(0).providedPorts.get(0).interface.name)
		Assert.assertEquals("interface", model.components.get(0).providedPorts.get(0).name)
	}

	@Test
	def void ComponentRequiresPort()
	{
		
		val model = '''
		package test
		import org.example.* from "testfidls/example1.fidl"
		
		component comp
		{
			requires FirstTestInterface as interface
		}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("FirstTestInterface", model.components.get(0).requiredPorts.get(0).interface.name)
		Assert.assertEquals("interface", model.components.get(0).requiredPorts.get(0).name)
	}
	
	@Test
	def void ComponentProvidesAndRequiresPort()
	{
		
		val model = '''
		package test
		import org.example.* from "testfidls/example1.fidl"
		import org.example.* from "testfidls/example2.fidl"
		
		component comp
		{
			requires FirstTestInterface as interface1
			provides SecondTestInterface as interface2
		}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("FirstTestInterface", model.components.get(0).requiredPorts.get(0).interface.name)
		Assert.assertEquals("interface1", model.components.get(0).requiredPorts.get(0).name)
		Assert.assertEquals("SecondTestInterface", model.components.get(0).providedPorts.get(0).interface.name)
		Assert.assertEquals("interface2", model.components.get(0).providedPorts.get(0).name)
	}
	
	@Test
	def void ComponentExtending()
	{
		val model = '''
		package test
		import org.example.* from "testfidls/example1.fidl"
		import org.example.* from "testfidls/example2.fidl"
		
		component compSuper
		{
			requires FirstTestInterface as interface1
			provides SecondTestInterface as interface2
		}
		
		component compDerived extends compSuper{
			
		}
		
		component Test{
			provides FirstTestInterface as inter
		}
		
		component Cluster{
			contains compDerived as derived
			contains Test as testing
			
			connect derived.interface1 to testing.inter
		}
		'''.parse
		
		model.assertNoErrors
		
		var comp = model.components.get(1)
		
		Assert.assertEquals("compSuper", comp.superType.name)
	}
	
	@Ignore
	@Test
	def void FullDiensteComponent()
	{
		
		val model = '''
		package test
		import model "testfcdls/Tags.fcdl"
		import org.example.* from "testfidls/example1.fidl"
		import org.example.* from "testfidls/example2.fidl"
		
		<**@dienst **>
		component comp
		{
			requires FirstTestInterface as interface1
			provides SecondTestInterface as interface2
		}
		'''.parse
		
		model.assertNoErrors
		
		Assert.assertEquals("FirstTestInterface", model.components.get(0).requiredPorts.get(0).interface.name)
		Assert.assertEquals("interface1", model.components.get(0).requiredPorts.get(0).name)
		Assert.assertEquals("SecondTestInterface", model.components.get(1).requiredPorts.get(1).interface.name)
		Assert.assertEquals("interface2", model.components.get(1).requiredPorts.get(1).name)
	}
	
}