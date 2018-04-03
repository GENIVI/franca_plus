/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(MultiInjectorProvider)
class ComponentInternalTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	var model = null as FCModel
	
	var COMPONENT_TO_TEST = 2
	
	@Before
	def void init()
	{	
		model = '''
		package org.example
		import org.example.* from "testfidls/WindowLifter.fidl"
		
		service component WindowLifter {
			provides WindowLifter as PPort
		}
		
		service component WindowLifterMaster {
			requires WindowLifter as RDriverPort
			requires WindowLifter as RCoDriverPort
		}
		
		
		component BodyCluster {
			provides WindowLifter as PDriverPort
		    provides WindowLifter as PCoDriverPort
		    	
			contains WindowLifter as DriverWindowLifterPrototype
			contains WindowLifter as CoDriverWindowLifterPrototype
			
			contains WindowLifterMaster as WindowLifterMasterPrototype
				
			connect WindowLifterMasterPrototype.RDriverPort to DriverWindowLifterPrototype.PPort
			connect WindowLifterMasterPrototype.RCoDriverPort to CoDriverWindowLifterPrototype.PPort
			
			delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
			delegate provided PCoDriverPort to CoDriverWindowLifterPrototype.PPort
		}
		'''.parse
		
		model.assertNoErrors
	}
	
	@Test
	def void ClusterContainsDienstPrototype()
	{
		//Check first containment of the WindowLifter service and the given name
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).prototypes.get(0).component.name)
		Assert.assertEquals("DriverWindowLifterPrototype", model.components.get(COMPONENT_TO_TEST).prototypes.get(0).name)
		//Check second containment of the WindowLifter service and the given name
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).prototypes.get(1).component.name)
		Assert.assertEquals("CoDriverWindowLifterPrototype", model.components.get(COMPONENT_TO_TEST).prototypes.get(1).name)
	}
	
	@Test
	def void ClusterTestVerifyConnectors()
	{
		//Check first required Port for the connection and the Interface Type
		Assert.assertEquals("RDriverPort", model.components.get(COMPONENT_TO_TEST).assembles.get(0).from.port.name)
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).assembles.get(0).from.port.interface.name)
		//Check first provided Port for the connection and the Interface Type
		Assert.assertEquals("PPort", model.components.get(COMPONENT_TO_TEST).assembles.get(0).to.port.name)
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).assembles.get(0).to.port.interface.name)
		
		//Check second required Port for the connection and the Interface Type
		Assert.assertEquals("RCoDriverPort", model.components.get(COMPONENT_TO_TEST).assembles.get(1).from.port.name)
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).assembles.get(1).from.port.interface.name)
		//Check second provided Port for the connection and the Interface Type
		Assert.assertEquals("PPort", model.components.get(COMPONENT_TO_TEST).assembles.get(1).to.port.name)
		Assert.assertEquals("WindowLifter", model.components.get(COMPONENT_TO_TEST).assembles.get(1).to.port.interface.name)
	}
	
	@Test
	def void ClusterVerifyDelegate()
	{
		//Check first Delegation
		Assert.assertEquals("PPort", model.components.get(COMPONENT_TO_TEST).delegates.get(0).inner.port.name)
		Assert.assertEquals("PDriverPort", model.components.get(COMPONENT_TO_TEST).delegates.get(0).outer.port.name)
		Assert.assertEquals("provided", model.components.get(COMPONENT_TO_TEST).delegates.get(0).kind.getName)
		//Check second Delegation
		Assert.assertEquals("PPort", model.components.get(COMPONENT_TO_TEST).delegates.get(1).inner.port.name)
		Assert.assertEquals("PCoDriverPort", model.components.get(COMPONENT_TO_TEST).delegates.get(1).outer.port.name)
		Assert.assertEquals("provided", model.components.get(COMPONENT_TO_TEST).delegates.get(1).kind.getName)
	}
}
