/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner2)
@InjectWith(MultiInjectorProvider)
class CompmodelSystemTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	var model = null as FCModel
	
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
		
		component ComfortCluster {
			requires WindowLifter as RDriverPort
			requires WindowLifter as RCoDriverPort
			
			contains WindowLifterMaster as WindowLifterClient
			
			delegate required RDriverPort to WindowLifterClient.RDriverPort
			delegate required RCoDriverPort to WindowLifterClient.RCoDriverPort	
		}
		
		component BodyFramework {
			contains BodyCluster
			contains ComfortCluster
			
			connect ComfortCluster.RDriverPort to BodyCluster.PDriverPort	
			connect ComfortCluster.RCoDriverPort to BodyCluster.PCoDriverPort
		}
		
		
		component Vehicle2021 {
			contains BodyFramework
		}
		
		system Vehicle2021 with root Vehicle2021
		{
			device MasterECU
			device ClientECU
		} 
		'''.parse
		
		model.assertNoErrors
	}
	
	@Test
	def void TestSystemRoot()
	{
		Assert.assertEquals(model.components.get(5), model.systems.get(0).root.component)
		Assert.assertEquals("Vehicle2021", model.systems.get(0).root.component.name)
	}
	
	@Test
	def void TestDevicesInSystem()
	{
		Assert.assertEquals("MasterECU", model.systems.get(0).devices.get(0).name)
		Assert.assertEquals("ClientECU", model.systems.get(0).devices.get(1).name)
	}
}
