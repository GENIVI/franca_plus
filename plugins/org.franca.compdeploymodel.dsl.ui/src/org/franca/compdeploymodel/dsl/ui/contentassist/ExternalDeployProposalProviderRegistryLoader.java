package org.franca.compdeploymodel.dsl.ui.contentassist;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;

public class ExternalDeployProposalProviderRegistryLoader
{
	private static final String EXTENSION_POINT_ID = "org.franca.compdeploymodel.dsl.ui.DeployProposalProvider";
	
	public static Object externalProposalProviderLoader()
	{
		Object result = null;
		
		IExtensionRegistry extRegistry = Platform.getExtensionRegistry();

		IExtensionPoint extPoint = extRegistry.getExtensionPoint(EXTENSION_POINT_ID);
		
		IConfigurationElement [] elements = extPoint.getConfigurationElements();
		try 
		{
			if(elements.length == 1)
			{
						result = elements[0].createExecutableExtension("class");
			} else 
				{
					if(elements.length > 1)
					{	
						throw new Exception("Too many Arguments. Only one Extension allowed!");
					}
				}
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		
		return result;
	}
}
