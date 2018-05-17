/* Copyright (C) 2018 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
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
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(MultiInjectorProvider)
class ComponentExtendedTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	@Test
	def void ConnectToPortWithInheritedInterface()
	{
		
		val model = '''
			package org.example
			
			import org.example.* from "classpath:/HelloWorld.fidl"
			import org.example.* from "classpath:/HelloWorld.fcdl"
			
			/*
			 * Server Component for Hello World Extension.
			 * Derived from HelloWorldServer.
			 */
			service component HelloWorldServerExtension extends HelloWorldServer {
				provides HelloWorld as AskMePortExt
			}
			
			/*
			 * Client Component for Hello World Extension.
			 * Derived from HelloWorldClient.
			 */
			service component HelloWorldClientExtension extends HelloWorldClient {
				requires HelloWorld as AnswerMePortExt
			}
			
			root component WorldApart {
				contains HelloWorldServerExtension
				contains HelloWorldClientExtension
				
				// connect derived interface to derived interface 
				connect HelloWorldClientExtension.AnswerMePort to HelloWorldServerExtension.AskMePort
				// connect base interface to derived interface 
				connect HelloWorldClientExtension.AnswerMePortExt to HelloWorldServerExtension.AskMePort
			}
		'''.parse
		
		model.assertNoErrors
		
	}
	
}