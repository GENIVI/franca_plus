/* Copyright (C) 2018 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compdeploymodel.dsl.validator.tests

import com.google.inject.Inject
import com.itemis.xtext.testing.XtextTest
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.franca.compdeploymodel.dsl.tests.internal.CDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import static extension java.lang.String.format
import static extension org.franca.compdeploymodel.dsl.validation.CDeployValidator.*
import org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage

@RunWith(XtextRunner) 
@InjectWith(CDeployTestsInjectorProvider) 
class CDeployValidatorTest extends XtextTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FDModel>
	
	@Test
	def void testComponentInstance4ServiceNature() 
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/architecture_deployment_spec.cdepl"
			import "classpath:/fcdl/70-HelloWorld.fcdl"
			
			define system.architecture for service World.Room1 as Service {}
			define system.architecture for service World as Service2 {}
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(2, issues.length)
		Assert.assertEquals(COMPONENT_IS_NO_SERVICE, issues.get(0).message)
		Assert.assertEquals(COMPONENT_IS_NO_SERVICE, issues.get(1).message) 
	}
	
	@Test
	def void testRootElement()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/network_CAN_deployment_spec.cdepl"
			import "classpath:/platform/network_SOMEIP_deployment_spec.cdepl"
			
			import "classpath:/fidl/70-HelloWorld.fidl"
			import "classpath:/fidl/71-HelloWorldTypes.fidl"
			
			define network.someip for typeCollection org.example as HelloWorldTypesDeployment {
				use HelloWorldTypesDeployment2
			}
			
			define network.someip for typeCollection org.example as HelloWorldTypesDeployment2 {
				use HelloWorldTypesDeployment
			} 
			
			define network.can for interface org.example.HelloWorld as CanDeployment4HelloWorld {
				use org.example.deployment.HelloWorldTypesDeployment
			}
			
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(3, issues.length)
		Assert.assertEquals(CYCLIC_USE_RELATION_IN_ELEMENT.format("HelloWorldTypesDeployment"), issues.get(0).message)
		Assert.assertEquals(CYCLIC_USE_RELATION_IN_ELEMENT.format("HelloWorldTypesDeployment2"), issues.get(1).message)
		Assert.assertEquals(USE_RELEATION_REFERS_TO_DEPLOYMENT_WITH_INCOMAPTIBLE_SPEC.format("HelloWorldTypesDeployment", "someip"), issues.get(2).message)
	}
	
	@Test
	def void testDuplicatePortDeployment()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/network_CAN_deployment_spec.cdepl"
			import "classpath:/platform/network_SOMEIP_deployment_spec.cdepl"
			
			import "classpath:/fcdl/70-HelloWorld.fcdl"
			
			define network.someip for service World.Room1.Service as Service {
				provide AskMePort {	
					SomeIpInstanceID = 1
			        SomeIpReliableUnicastPort = 30506
			        SomeIpUnreliableUnicastPort = 0
			   	}
			   	
			   	provide AskMePort on network.can {	
			   	}
			   	
			   	provide AskMePortCan on network.can {
			   	}
			}
			
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(4, issues.length)
		Assert.assertEquals(DUPLICATE_DEPLOYMENT_OF_PORT.format("AskMePort"), issues.get(0).message)
		Assert.assertEquals(PORT_IS_ALREADY_DEPLOYED, issues.get(1).message)
		Assert.assertEquals(DUPLICATE_DEPLOYMENT_OF_PORT.format("AskMePort"), issues.get(2).message)
		Assert.assertEquals(PORT_IS_ALREADY_DEPLOYED, issues.get(3).message)
	}
	
	@Test
	def void testForUniqueInterfaceDeployment()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/network_CAN_deployment_spec.cdepl"
			import "classpath:/platform/network_SOMEIP_deployment_spec.cdepl"
			import "classpath:/platform/architecture_deployment_spec.cdepl"
			
			import "classpath:/fidl/70-HelloWorld.fidl"
			import "classpath:/fcdl/70-HelloWorld.fcdl"
			
			define network.someip for interface org.example.HelloWorld {
				SomeIpServiceID = 0
				method sayHello {
					SomeIpMethodID = 0
				}
			}
			
			define network.someip for interface org.example.HelloWorld as HelloWorldAlternative {
				SomeIpServiceID = 0
				method sayHello {
					SomeIpMethodID = 0
				}
			}
			
			define network.someip for component org.example.HelloWorldServer {
				provide AskMePort on network.someip {
					use HelloWorld_depl
					use HelloWorldAlternative
					SomeIpInstanceID = 1
				}
			}
			
			define network.someip for service World.Room1.Service as Service {
				use HelloWorldServer_depl
				provide AskMePort {
					use HelloWorld_depl
					SomeIpInstanceID = 1
					SomeIpReliableUnicastPort = 30506
					SomeIpUnreliableUnicastPort = 0
				}	
				provide AskMePortCan on system.architecture {
				}
			}
			
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(3, issues.length)
		model.deployments.get(2).assertError(CDeployPackage::eINSTANCE.FDProvidedPort, null, MULTIPLE_DEPLOYMENT_USE_FOR_INTERFACE.format("HelloWorld", "'HelloWorld_depl', 'HelloWorldAlternative'"))
		model.deployments.get(2).assertError(CDeployPackage::eINSTANCE.FDProvidedPort, null, MULTIPLE_DEPLOYMENT_USE_FOR_INTERFACE.format("HelloWorld", "'HelloWorld_depl', 'HelloWorldAlternative'"))
		model.deployments.get(3).assertWarning(CDeployPackage::eINSTANCE.FDProvidedPort, null, INCONSISTENT_INTERFACE_DEPLOYMENT_USE.format("HelloWorld_depl", "HelloWorldAlternative"))
	}
	
	@Test
	def void testRootCompatibilityOfUsedDevicesInVariant()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/network_CAN_deployment_spec.cdepl"
			import "classpath:/platform/network_SOMEIP_deployment_spec.cdepl"
			import "classpath:/platform/architecture_deployment_spec.cdepl"
			
			import "classpath:/fidl/70-HelloWorld.fidl"
			import "classpath:/fcdl/70-HelloWorld.fcdl"
			
			define network.someip for service World.Room1.Service {
				provide AskMePort {
					SomeIpInstanceID = 1
				}	
				provide AskMePortCan on system.architecture {}
			}
			
			// use different root
			define network.someip for service Universe.Room1.Client1 
			
			define network.someip for device org.example.HelloServerECU {
				use Service_depl
			}
			define network.someip for device org.example.HelloClientECU {
				use Client1_depl
			}
			
			define variant AIO for root World {
				use HelloClientECU_depl
				use HelloServerECU_depl
			}
			
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(3, issues.length)
		Assert.assertEquals(USAGE_OF_SERVICE_WITH_DERIVED_ROOT.format("AIO"), issues.get(0).message)
		Assert.assertEquals(DEVICE_CONTAINS_SERVICE_WITH_DERIVED_ROOT.format("Universe.Room1.Client1"), issues.get(1).message)
		Assert.assertEquals(VARIANT_CONTAINS_SERVICES_WITH_INCOMPATIBLE_ROOT, issues.get(2).message)
	}
	
	@Test
	def void testCheckPropertiesComplete()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/network_CAN_deployment_spec.cdepl"
			import "classpath:/platform/network_SOMEIP_deployment_spec.cdepl"
			import "classpath:/platform/architecture_deployment_spec.cdepl"
			
			import "classpath:/fcdl/70-HelloWorld.fcdl"
			
			// no mandatory elements
			define system.architecture for service World.Room1.Service as Service2 {
				provide AskMePort
			}
			
			// mandatory port deployment, because of mandatory properties in spec someip
			define network.someip for service World.Room1.Service as Service {
				provide AskMePort on network.someip
			}
			
			
		'''.parse
		
		var issues = model.validate
		Assert.assertEquals(2, issues.length)
		Assert.assertEquals(SPECIFICATION_REQUIRES_DEPLOYMENT_FOR_PORT.format("someip", "provided", " 'AskMePortCan' "), issues.get(0).message)
		Assert.assertEquals(SPECIFICATION_REQUIRES_MANDATORY_PROPERTY_FOR_ELEMENT.format("someip", " 'SomeIpInstanceID' "), issues.get(1).message)
	}
	
	@Test 
	def void testCheckSingletons()
	{
		var model = '''
			package org.example.deployment
			
			import "classpath:/platform/architecture_deployment_spec.cdepl"
			
			import "classpath:/fcdl/72-HelloWorldSingleton.fcdl"
			
			define system.architecture for service World.Room1.Service as Service1
			define system.architecture for service World.Room1.Service as Service2
			
			define system.architecture for device org.example.HelloServerECU {
				use Service1
				use Service2
			}
			
			define variant AIO for root World {
				use HelloServerECU_depl
			}		
			
		'''.parse
		model.assertError(CDeployPackage::eINSTANCE.FDVariant, null, SERVICE_IS_SINGLETON.format("HelloWorldServer"))
	}
}
	