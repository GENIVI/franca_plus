/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.validator.tests;

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FcompPackage
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import static extension org.franca.compmodel.dsl.validation.FCompValidator.*
import static extension java.lang.String.format

@RunWith(XtextRunner)
@InjectWith(MultiInjectorProvider)
class FCompValidatorTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	@Test
	def void TestDuplicateDelegate()
	{
		var model = '''
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
					delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_DELEGATE_CONNECTOR, null,
			DUPLICATION_OF_DELEGATES_IS_NOT_ALLOWED)
	}
	
	@Test
	def void TestDifferentTypOfInnerAndOuter()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					requires WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					provides WindowLifter as RDriverPort
					provides WindowLifter as RCoDriverPort
				}
				
				
				component BodyCluster {
					requires WindowLifter as PDriverPort
				    requires WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect DriverWindowLifterPrototype.PPort to WindowLifterMasterPrototype.RDriverPort
					connect CoDriverWindowLifterPrototype.PPort to WindowLifterMasterPrototype.RCoDriverPort
					
					delegate required PDriverPort to DriverWindowLifterPrototype.PPort
					delegate required PCoDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).delegates.get(0).validate
		var first = issues.findFirst[it.message.contains("PDriverPort")]
		Assert.assertEquals(first.message, REQUIRED_DELEGATE_MUST_NOT_CONNECT_TO_DIFFERENT_OUTER.format('PDriverPort'))
		var second = issues.findFirst[it.message.contains("PCoDriverPort")]
		Assert.assertEquals(second.message, REQUIRED_DELEGATE_MUST_NOT_CONNECT_TO_DIFFERENT_OUTER.format('PCoDriverPort'))
	}
	
	@Test
	def void TestDuplicateProvidedDelegateOuter()
	{
		var model = '''
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
					delegate provided PDriverPort to CoDriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.validate
		// model.validate.forEach[println(message)]
		Assert.assertTrue(issues.map[message].contains(PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format('PCoDriverPort', 'DriverWindowLifterPrototype', 'PPort')))
		Assert.assertTrue(issues.map[message].contains(DUPLICATE_PROVIDED_DELEGATE_OUTER_TO.format('DriverWindowLifterPrototype', 'PPort')))
		Assert.assertTrue(issues.map[message].contains(DUPLICATE_PROVIDED_DELEGATE_OUTER_TO.format('CoDriverWindowLifterPrototype', 'PPort')))		
	}
	
	@Test
	def void TestDuplicateProvidedDelegateInner()
	{
		var model = '''
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
					delegate provided PCoDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).delegates.get(0).validate
		var first = issues.findFirst[it.message.contains("PDriverPort")]
		Assert.assertEquals(first.message, DUPLICATE_PROVIDED_DELEGATE_INNER_FROM.format('PDriverPort'))
		var second = issues.findFirst[it.message.contains("PCoDriverPort")]
		Assert.assertEquals(second.message, DUPLICATE_PROVIDED_DELEGATE_INNER_FROM.format('PCoDriverPort'))
	}
	
	@Test
	def void TestDuplicatedAssemblyFromConnector()
	{
		var model = '''
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
					connect WindowLifterMasterPrototype.RDriverPort to CoDriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).assembles.get(0).validate
		
		// model.validate.forEach[println(message)]
		Assert.assertTrue(issues.map[message].contains(PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format('PCoDriverPort', 'DriverWindowLifterPrototype', 'PPort')))
		Assert.assertTrue(issues.map[message].contains(PROVIDED_PORT_CAN_BE_DELEGATED_TO_PORT.format('PCoDriverPort', 'CoDriverWindowLifterPrototype', 'PPort')))
		Assert.assertTrue(issues.map[message].contains(ASSEMBLY_PORT_ALREADY_CONNECTED_TO.format('DriverWindowLifterPrototype', 'PPort')))
		Assert.assertTrue(issues.map[message].contains(ASSEMBLY_PORT_ALREADY_CONNECTED_TO.format('CoDriverWindowLifterPrototype', 'PPort')))
		Assert.assertEquals(2, issues.map[message].filter[it == DUPLICATION_OF_ASSEMBLY_CONNECTORS_IS_NOT_ALLOWED].size)
	}

	@Test
	def void TestSingeltonComponentValidation()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service singleton component WindowLifter {
					provides WindowLifter as PPort
				}
				
				component BodyCluster {
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
				}
		'''.parse
		
		var issues = model.components.get(1).prototypes.get(0).validate
		issues.forEach[Assert.assertEquals(it.message, DUPLICATE_CONTAINMENT_FOR_SINGLETON.format('WindowLifter'))]
		Assert.assertEquals(2, issues.size)
		
	}
	
	@Test
	def void TestUniquePortNames()
	{
		var model = '''
		package org.example 
		import org.example.* from "testfidls/WindowLifter.fidl"
		
		component BaseLifter {
			requires WindowLifter as BPort
		}
						
		service component WindowLifter extends BaseLifter {
			requires WindowLifter as BPort
			provides WindowLifter as PPort
			provides WindowLifter as PPort
		}'''.parse
		
		model.assertError(FcompPackage.Literals.FC_REQUIRED_PORT, null, PORT_EXISTS_ALREADY.format('org.example.BaseLifter.BPort'))	
		model.assertError(FcompPackage.Literals.FC_PROVIDED_PORT, null, PORT_EXISTS_ALREADY.format('org.example.WindowLifter.PPort'))
	}
	
	@Test
	def void TestUniquePrototypeNames()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				component BaseLifter
				component PrimeLifter
				
				component BodyBase {
					contains BaseLifter
				}
				
				service component BodyPrime extends BodyBase {
					contains PrimeLifter
					contains PrimeLifter
					contains BaseLifter
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null,	PROTOTYPE_EXISTS_ALREADY.format('org.example.BodyPrime.PrimeLifter'))
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null,	PROTOTYPE_EXISTS_ALREADY.format('org.example.BodyBase.BaseLifter'))
	}
	
	@Test
	def void TestUniqueComponentNames()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter{
				provides WindowLifter as PPort
				}
				
				component WindowLifter{
				provides WindowLifter as PPort
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_COMPONENT, null,	COMPONENT_NAME_MUST_BE_UNIQUE.format(model.components.get(0).name))
	}
	
	@Test
	def void TestSimplePortNames()
	{
		var model = '''
		package org.example
		import org.example from "testfidls/WindowLifter.fidl"
						
		service component WindowLifter{
		provides org.example.WindowLifter
		}
		'''.parse
		model.validate
		model.assertError(FcompPackage.Literals.FC_PROVIDED_PORT, null,	NO_NAMESPACE_SEPARATORS_ALLOWED_IN.format(model.components.get(0).providedPorts.get(0).name))
	}

	@Test
	def void TestForSelfContainment()
	{
		var model = '''
		package org.example
						
		service component WindowLifter {
			contains WindowLifter		
		}

		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null, COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_COMPONENT.format(model.components.get(0).prototypes.get(0).component.name))
	}


	@Test
	def void TestForSelfContainmentWithSuperTypePrototype()
	{
		var model = '''
		package org.example
				
		service component WindowLifterMaster{}
				
		service component WindowLifter extends WindowLifterMaster{
			contains WindowLifterMaster	
		}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null, 
			COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_PARENT_COMPONENT.format(model.components.get(1).name, model.components.get(1).superType.name))
	}
	
	@Test
	def void TestForSelfContainmentWithExtendedSuperTypePrototype()
	{
		var model = '''
		package org.example
				
		service component WindowLifterMaster{}
		
		service component WindowLifterSlave extends WindowLifterMaster{}
				
		service component WindowLifter extends WindowLifterSlave{
			contains WindowLifterMaster	
		}

		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null,
			COMPONENT_MUST_NOT_CONTAIN_PROTOTYPE_OF_PARENT_COMPONENT.format(model.components.get(2).name, model.components.get(2).superType.superType.name))

	}
	
	@Test
	def void TestForConnectedRequiredPorts(){
		
		var model = '''
			package org.example
			import org.example.* from "testfidls/WindowLifter.fidl"
							
			service component WindowLifter {
				requires WindowLifter as RPort	
			}
			
			component WindowLifterMaster {
				contains WindowLifter as MyWindowLifterComponent
				
			}
			
		'''.parse
		
		
		model.assertError(FcompPackage::eINSTANCE.FCGenericPrototype, null,			
			REQUIRED_PORT_IS_NEITHER_CONNECTED_NOR_DELEGATED.format(model.components.get(1).prototypes.get(0).name, 
			model.components.get(0).requiredPorts.get(0).name))
		
		/**
		 * Unconnected optional (required) ports shouldn't cause a warning, therefore the next model should be valid
		 */
		
		model = '''
			package org.example
			import org.example.* from "testfidls/WindowLifter.fidl"
							
			service component WindowLifter {
				optional requires WindowLifter as RPort	
			}
			
			component WindowLifterMaster {
				contains WindowLifter as MyWindowLifterComponent
				
			}
			
		'''.parse
		
		Assert::assertTrue("Unconnected optional (required) ports shouldn't cause a warning, therefore the model should be valid", model.validate.size == 0)
	}
	
	/**
	 * The following model is used to verify that if mandatory required port are properly connected (ASSEMBLY CONNECTOR).
	 * An error for the missing connect for InternalComfortCluster.RDriverPort is expected.
	 */
	
	@Test
	def void TestForConnectedPorts(){
		val model = '''
			package org.example
			
			import model "classpath:/Tags.fcdl"
			import org.example.* from "testfidls/WindowLifter.fidl"
			
			<** @description: Steuert Motor fuer Fenster **>
			service component WindowLifter {
				
				provides WindowLifter as PPort
			}
			
			service component WindowLifterMaster {
				requires WindowLifter as RDriverPort
				requires WindowLifter as RCoDriverPort
			}
			
			
			<** @framework **>
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
			
			<** @cluster **>
			component ComfortCluster {
				requires WindowLifter as RDriverPort
				requires WindowLifter as RCoDriverPort
				
				contains WindowLifterMaster as WindowLifterClient
				
				delegate required RDriverPort to WindowLifterClient.RDriverPort
				delegate required RCoDriverPort to WindowLifterClient.RCoDriverPort	
			}
			
			<** @cluster **>
			component SuperComfortCluster {
				requires WindowLifter as RDriverPort
				requires WindowLifter as RCoDriverPort
				
				contains ComfortCluster as InternalComfortCluster
				
				delegate required RCoDriverPort to InternalComfortCluster.RCoDriverPort	
			}
			
			<** @framework **>
			component BodyFramework {
				contains BodyCluster
				contains SuperComfortCluster
				
				connect SuperComfortCluster.RDriverPort to BodyCluster.PDriverPort	
				connect SuperComfortCluster.RCoDriverPort to BodyCluster.PCoDriverPort
			}
		'''.parse
		
		model.assertError(FcompPackage::eINSTANCE.FCGenericPrototype, null,
			REQUIRED_PORT_IS_NEITHER_CONNECTED_NOR_DELEGATED.format('InternalComfortCluster', 'RDriverPort'))		
	}
	
	@Test
	def void TestDelegateAndAssemblyATheSameTime(){
		val model = '''
			package org.example
			
			import org.example.* from "testfidls/HelloWorld.fidl"
			
			
			component HelloWorldServer {
				provides HelloWorld as AskMePort
			}
			
			component HelloWorldClient {
				requires HelloWorld as AnswerMePort
			}
			
			component MeetingPoint {
				requires HelloWorld as HalloGalaxy
				
				contains HelloWorldServer as Service
				
				contains HelloWorldClient as Client1
				contains HelloWorldClient as Client2 
				
				connect Client1.AnswerMePort to Service.AskMePort
				connect Client2.AnswerMePort to Service.AskMePort
				
				delegate required HalloGalaxy to Client2.AnswerMePort
			}
		'''.parse
		
		model.assertError(FcompPackage::eINSTANCE.FCFrom, null,
			ASSEMBLY_AND_DELEGATE_CONNECTOR_IS_NOT_ALLOWED.format('Client2', 'AnswerMePort'))		
		model.assertError(FcompPackage::eINSTANCE.FCInner, null,
			ASSEMBLY_AND_DELEGATE_CONNECTOR_IS_NOT_ALLOWED.format('Client2', 'AnswerMePort'))		
	}
}	