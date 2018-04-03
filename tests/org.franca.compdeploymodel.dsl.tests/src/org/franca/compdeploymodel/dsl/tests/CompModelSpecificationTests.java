/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compdeploymodel.dsl.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.franca.compdeploymodel.dsl.FDeployTestsInjectorProvider;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(FDeployTestsInjectorProvider.class)

public class CompModelSpecificationTests extends XtextTest{

	 @Ignore
	 @Test
	 public void TestArchitectureSpec()
	 {
	 	testFile("platform/architecture_deployment_spec.fdepl");
	 }
	
	 @Ignore
	 @Test
	 public void TestCommonAPISpec()
	 {
	 	testFile("platform/CommonAPI_deployment_spec.fdepl");
	 }
	
	 @Ignore
	 @Test
	 public void TestCommonAPISOMEIPSpec()
	 {
	 	testFile("platform/CommonAPI-SOMEIP_deployment_spec.fdepl");
	 }
	
	 @Ignore
	 @Test
	 public void TestNetworkCanSpec()
	 {
	 	testFile("platform/network_CAN_deployment_spec.fdepl");
	 }
	
	 @Ignore
	 @Test
	 public void TestNetworkSomeIPSpec()
	 {
	 	testFile("platform/network_SOMEIP_deployment_spec.fdepl");
	 }
	
	 @Ignore
	 @Test
	 public void fullSpec()
	 {
	 	testFile("platform/full_property_hosts_spec.fdepl");
	 }
	
}
