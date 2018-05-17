/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.tests

import com.itemis.xtext.testing.XtextTest
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.franca.compdeploymodel.dsl.tests.internal.CDeployTestsInjectorProvider
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(CDeployTestsInjectorProvider) 

class CompModelDefinitionTests extends XtextTest {
	@Before 
	override void before() {
		suppressSerialization()
	}

	@Test 
	def void TestInterfaceDeployment() {
		testFile("testcases/702_Interface.cdepl", "fidl/70-HelloWorld.fidl")
	}

	@Test 
	def void TestComponentDeployment() {
		testFile("testcases/703_Component.cdepl", "fcdl/70-HelloWorld.fcdl")
	}

	@Test 
	def void TestClientDeployment() {
		testFile("testcases/704_Client.cdepl", "fcdl/70-HelloWorld.fcdl")
	}

	@Test 
	def void TestServiceDeployment() {
		testFile("testcases/705_Service.cdepl", "fcdl/70-HelloWorld.fcdl")
	}

	@Test 
	def void TestClientECUDeployment() {
		testFile("testcases/706_ClientECU.cdepl", "testcases/705_Service.cdepl",
			"testcases/704_Client.cdepl")
	}

	@Test 
	def void TestServerECUDeployment() {
		testFile("testcases/707_ServerECU.cdepl", "testcases/705_Service.cdepl")
	}

	@Test 
	def void TestVariant() {
		testFile("testcases/708_Variant.cdepl", "testcases/707_ServerECU.cdepl",
			"testcases/706_ClientECU.cdepl")
	}

	@Test 
	def void TestVariantAlternatives() {
		testFile("testcases/710_Variant_Alternatives.cdepl", "testcases/704_Client.cdepl")
	}

	@Test 
	def void TestHelloWorldAllInOneDeployment() {
		testFile("testcases/709_HelloWorldAllInOne.cdepl", "fcdl/70-HelloWorld.fcdl")
	}

	@Test 
	def void TestSignalsOnComponents() {
		testFile("testcases/720_SignalOnComp.cdepl", "platform/bus_signal_spec.cdepl")
	}
}
