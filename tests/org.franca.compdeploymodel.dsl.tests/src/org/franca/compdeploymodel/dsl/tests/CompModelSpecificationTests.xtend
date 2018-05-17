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
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.Before

@RunWith(XtextRunner) 
@InjectWith(CDeployTestsInjectorProvider) 
class CompModelSpecificationTests extends XtextTest {
	
	@Before 
	override void before() {
		suppressSerialization()
	}
	
	@Test 
	def void TestArchitectureSpec() {
		testFile("platform/architecture_deployment_spec.cdepl")
	}

	@Ignore 
	@Test def void TestNetworkSomeIPSpec() {
		testFile("platform/network_SOMEIP_deployment_spec.cdepl")
	}

	@Test def void fullSpec() {
		testFile("platform/full_property_hosts_spec.cdepl")
	}
}
