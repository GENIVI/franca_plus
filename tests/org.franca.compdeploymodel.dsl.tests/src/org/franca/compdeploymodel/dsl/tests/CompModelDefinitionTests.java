/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compdeploymodel.dsl.tests;

import org.eclipse.xtext.testing.XtextRunner;
import org.franca.compdeploymodel.dsl.FDeployTestsInjectorProvider;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(FDeployTestsInjectorProvider.class)

public class CompModelDefinitionTests extends XtextTest {
	
    @Before
    public void before() {
        suppressSerialization();
    }  
    
    @Test
    public void TestInterfaceDeployment()
    {
    	testFile("testcases/comp/702_Interface.fdepl", "fidl/70-HelloWorld.fidl");
    }   

    @Test
    public void TestComponentDeployment()
    {
    	testFile("testcases/comp/703_Component.fdepl", "fcdl/70-HelloWorld.fcdl");
    }

    @Test
    public void TestClientDeployment()
    {
    	testFile("testcases/comp/704_Client.fdepl", "fcdl/70-HelloWorld.fcdl");
    }

    @Test
    public void TestServiceDeployment()
    {
    	testFile("testcases/comp/705_Service.fdepl", "fcdl/70-HelloWorld.fcdl");
    }

    @Test
    public void TestClientECUDeployment()
    {
    	testFile("testcases/comp/706_ClientECU.fdepl", "testcases/comp/705_Service.fdepl", "testcases/comp/704_Client.fdepl");
    }

    @Test
    public void TestServerECUDeployment()
    {
    	testFile("testcases/comp/707_ServerECU.fdepl", "testcases/comp/705_Service.fdepl");
    }

    @Test
    public void TestVariant()
    {
    	testFile("testcases/comp/708_Variant.fdepl", "testcases/comp/707_ServerECU.fdepl", "testcases/comp/706_ClientECU.fdepl");
    }

    @Test
    public void TestVariantAlternatives()
    {
    	testFile("testcases/comp/710_Variant_Alternatives.fdepl", "testcases/comp/704_Client.fdepl");
    }

    @Test
    public void TestHelloWorldAllInOneDeployment()
    {
    	testFile("testcases/comp/709_HelloWorldAllInOne.fdepl" , "fcdl/70-HelloWorld.fcdl");
    }

    @Test
    public void TestSignalsOnComponents()
    {
    	testFile("testcases/comp/720_SignalOnComp.fdepl", "platform/bus_signal_spec.fdepl");
    }
}
