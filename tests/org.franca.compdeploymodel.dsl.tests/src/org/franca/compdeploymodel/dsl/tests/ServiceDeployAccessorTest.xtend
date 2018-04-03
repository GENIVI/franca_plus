/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */package org.franca.compdeploymodel.dsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner

import org.franca.compdeploymodel.core.FDeployedComponent
import org.franca.compdeploymodel.core.FDeployedDevice
import org.franca.compdeploymodel.core.FDeployedService
import org.franca.compdeploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.compdeploymodel.dsl.fDeploy.FDComponent
import org.franca.compdeploymodel.dsl.fDeploy.FDDevice
import org.franca.compdeploymodel.dsl.fDeploy.FDModel
import org.franca.compdeploymodel.dsl.fDeploy.FDService
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(FDeployTestsInjectorProvider)

class ServiceDeployAccessorTest extends DeployAccessorTestBase {

	var FDModel model = null

	@Before
	def void setup() {
		suppressSerialization();
		val root = loadModel(
			"testcases/comp/750_ServiceAccessor.fdepl"
		);

		model = root as FDModel
		assertNotNull(model)
		assertFalse(model.deployments.empty)
	}

	@Test
	def void test_750_ComponentAccessor() {
		val component = model.deployments.filter(FDComponent).get(0)
		val deployed = new FDeployedComponent(component)
		val accessor = new org.example.spec.SpecSimpleServiceDeploymentRef.ComponentPropertyAccessor(deployed)		

		val str = accessor.getComponentName(component)
		assertEquals(str, "Component")
		
		val id = accessor.getInstanceID(component.providedPorts.get(0))
		assertEquals(id, 11)
	 }
	
	@Test
	def void test_750_ServiceAccessor() {
		val service = model.deployments.filter(FDService).get(0)
		val deployed = new FDeployedService(service)
		val accessor = new org.example.spec.SpecSimpleServiceDeploymentRef.ServicePropertyAccessor(deployed)

		val str = accessor.getServiceString(service)
		assertEquals(str, "Service")
		
		val id = accessor.getInstanceID(service.providedPorts.get(0))
		assertEquals(id, 11)
	}
	
	@Test
	def void test_750_ServiceAccessorExtended() {
		val service = model.deployments.filter(FDService).get(0)
		val deployed = new FDeployedService(service)
		val accessor = new org.example.spec.SpecExtendedServiceDeploymentRef.ServicePropertyAccessor(deployed)

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
		val deployed = new FDeployedDevice(device)
		val accessor = new org.example.spec.SpecSimpleServiceDeploymentRef.DevicePropertyAccessor(deployed)

		val str = accessor.getDeviceString(device)
		assertEquals(str, "ECU")
		
		val id = accessor.getUnicastAddress(device.adapters.get(0))
		assertEquals(id, "123.567.890.100")
	}
	
	
	
	
}