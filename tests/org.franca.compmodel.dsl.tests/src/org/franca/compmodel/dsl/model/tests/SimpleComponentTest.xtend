/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compmodel.dsl.model.tests;

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
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
	
	@Test
	def void Devices()
	{
		val model = '''
		package org.example
		
		device HelloServerECU { 
			adapter EthernetCard1
			adapter EthernetCard2
			adapter CAN_TX_1
		}
		
		device HelloClientECU {
			device Core_1
			adapter EthernetCard
		}
		'''.parse
		
		model.assertNoErrors
		
		var adapter1 = model.devices.get(1).adapters.get(0)
		
		Assert.assertEquals("EthernetCard", adapter1.name)
	}
	
	@Test
	def void HelloWorld()
	{
		val model = '''
		package org.example
		
		import org.example.* from "testfidls/HelloWorld.fidl"
		
		service component HelloWorldServer {
			contains SubOrdinateService as InnerStructure
			provides HelloWorld2 as AskMePort
			provides HelloWorld as AskMePortCan
		}
		
		service component HelloWorldClient {
			requires org.example.HelloWorld2 as AnswerMePort
		}
		
		service component SubOrdinateService {}
		
		
		component MeetingPoint {
			contains HelloWorldServer as Service
			
			contains HelloWorldClient as Client1
			contains HelloWorldClient as Client2 
			
			connect Client1.AnswerMePort to Service.AskMePort
			connect Client2.AnswerMePort to Service.AskMePort
		}
		
		root component World {
			contains MeetingPoint as Room1
			contains MeetingPoint as Room2
		}
		
		root component Universe extends World
		
		component MeetingPointET extends MeetingPoint {
			provides HelloWorld as HelloThereOutInSpace
			delegate provided HelloThereOutInSpace to Service.AskMePortCan
		}
		
		service root component Galaxy {
			contains MeetingPoint as Room1
			contains MeetingPointET as Room2
			
			provides HelloWorld as HalloGalaxy
			delegate provided HalloGalaxy to Room2.HelloThereOutInSpace
		}
		
		'''.parse
		
		model.assertNoErrors
	}

	
	@Test
	def void HelloWorldInjection()
	{
		val model = '''
		package org.example
		
		import org.example.* from "testfidls/HelloWorld.fidl"
		
		service component HelloWorldServer {
			provides HelloWorld2 as AskMePort
		}
		
		service component ChatterClient {}
		
		component GenericClient {
			version { major 1 minor 2 }
			contains ChatterClient as GenericChatterClient
		}
		
		abstract component HelloWorldClient extends GenericClient {
			requires org.example.HelloWorld2 as AnswerMePort
			contains ChatterClient as HyperActiveChatterClient
			contains ChatterClient as BoringChatterClient
			contains ChatterClient as AdditionalChatterClient
		}
		
		
		component MeetingPoint {
			contains HelloWorldServer as Service
			
			contains HelloWorldClient as Client1
			contains DerivedHelloWorldClient2 as DerivedClient2 
			
			connect Client1.AnswerMePort to Service.AskMePort
			connect DerivedClient2.AnswerMePort to Service.AskMePort
		}
		
		// now implement in derived classes for derived types
		service component DerivedChatterClient extends ChatterClient {}
		
		component DerivedHelloWorldClient extends HelloWorldClient {
			implement HyperActiveChatterClient as InjectedHyperActiveChatterClient by DerivedChatterClient   
			implement BoringChatterClient as InjectedBoringChatterClient by DerivedChatterClient finally
		}
		
		component DerivedHelloWorldClient2 extends DerivedHelloWorldClient {}
		'''.parse
		
		model.assertNoErrors
	}
	
	@Test
	def void DiensteFrameworkComponent()
	{
		
		val model = '''
		package test
		import model "classpath:/Tags.fcdl"
				
		<**@framework **>
		component comp
		'''.parse
		
		model.assertNoErrors
		
	}
	
}