/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 
package org.franca.compdeploymodel.dsl.tests

import com.itemis.xtext.testing.XtextTest
import deployment.Extended
import deployment.Simple
import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compdeploymodel.dsl.cDeploy.FDService
import org.franca.compdeploymodel.dsl.tests.internal.CDeployTestsInjectorProvider
import org.franca.deploymodel.core.FDeployedRootElement
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(CDeployTestsInjectorProvider)
class ServiceDeployAccessorTest extends XtextTest {

	var FDModel model = null
	
	def protected loadModel(String fileToTest, String... referencedResources) {
		val resList = new ArrayList(referencedResources);
		resList += fileToTest
		var EObject result = null
		for (res : resList) {
			val uri = URI::createURI(resourceRoot + "/" + res);
			result = loadModel(resourceSet, uri, getRootObjectType(uri));
		}
		result
	}

	@Before
	def void setup() {
		suppressSerialization();
		val root = loadModel(
			"testcases/750_ServiceAccessor.cdepl"
		);

		model = root as FDModel
		assertNotNull(model)
		assertFalse(model.deployments.empty)
	}

	@Test
	def void test_750_ComponentAccessor() {
		val component = model.deployments.filter(FDComponent).get(0)
		val deployed = new FDeployedRootElement<FDComponent>(component)
		val accessor = new Simple.ComponentPropertyAccessor(deployed)		

		val str = accessor.getComponentName(component)
		assertEquals(str, "Component")
	 }
	
	@Test
	def void test_750_ServiceAccessor() {
		val service = model.deployments.filter(FDService).get(0)
		val deployed = new FDeployedRootElement<FDService>(service)
		val accessor = new Simple.ServicePropertyAccessor(deployed)

		val str = accessor.getServiceString(service)
		assertEquals(str, "Service")
		
		val id = accessor.getInstanceID(service.providedPorts.get(0))
		assertEquals(id, 11)
	}
	
	@Test
	def void test_750_ServiceAccessorExtended() {
		val service = model.deployments.filter(FDService).get(0)
		val deployed = new FDeployedRootElement<FDService>(service)
		val accessor = new Extended.ServicePropertyAccessor(deployed)

		val str = accessor.getServiceString(service)
		assertEquals(str, "Service")
		
		var id = accessor.getInstanceID(service.providedPorts.get(0))
		assertEquals(id, 11)
		
		// wrong spec
		id = accessor.getInstanceIDExt(service.providedPorts.get(0))
		assertNull(id)
		
		id = accessor.getInstanceID(service.providedPorts.get(1))
		assertEquals(id, 22)
		
		id = accessor.getInstanceIDExt(service.providedPorts.get(1))
		assertEquals(id, 33)
	}
	
	@Test
	def void test_750_DeviceAccessor() {
		val device = model.deployments.filter(FDDevice).get(0)
		val deployed = new FDeployedRootElement<FDDevice>(device)
		val accessor = new Simple.DevicePropertyAccessor(deployed)

		val str = accessor.getDeviceString(device)
		assertEquals(str, "ECU")
		
		val id = accessor.getUnicastAddress(device.adapters.get(0))
		assertEquals(id, "123.567.890.100")
	}
}