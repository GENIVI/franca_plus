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
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner) 
@InjectWith(CDeployTestsInjectorProvider) 
class CDeployValidatorBug256 extends XtextTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FDModel>
	
	@Test
	def void testClashingPropertyNamesBug256() 
	{
		// as workaround for bug https://github.com/franca/franca/issues/256
		// clashing property names are not marked as errors
		var model = '''
			package org.example
			
			specification clash {
				for attributes {
					X : String [] ( optional ) ;
				}
				for arguments {
					X : String [] ( optional ) ;
				}
				for struct_fields {
					X : String [] ( optional ) ;
				}
				for union_fields {
					X : String [] ( optional ) ;
				}
				for enumerators {
					X : String [] ( optional ) ;
				}
				for typedefs {
					X : String [] ( optional ) ;
				}
				for arrays {
					X : String [] ( optional ) ;
				}
			}
			
		'''.parse
		model.assertNoErrors		
	}
}
	