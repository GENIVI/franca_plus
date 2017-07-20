package org.franca.compdeploymodel.dsl;

import org.eclipse.xtext.util.Modules2;
import org.franca.compdeploymodel.dsl.FDeployRuntimeModule;
import org.franca.compdeploymodel.dsl.FDeployStandaloneSetup;
import org.franca.core.dsl.FrancaIDLRuntimeModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class FDeployTestsStandaloneSetup extends FDeployStandaloneSetup {
    @Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(
        		new FrancaIDLRuntimeModule(),
        		new FDeployRuntimeModule(),
        		new FDeployTestsModule()));
    }
}
