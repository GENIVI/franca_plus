/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl;

import java.util.List;
import java.util.Map;

import org.franca.compdeploymodel.core.PropertyMappings;
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyHost;
import org.franca.compdeploymodel.dsl.fDeploy.FDSpecification;

import com.google.common.collect.Maps;

/**
 * This class provides some additional functionality for Franca deployment
 * specifications. When used, it computes detail information about properties
 * defined in this specification and caches the results for later usage.
 * 
 * This classes uses the deployment mappings as defined by the PropertyMappings
 * class and caches the results.
 * 
 * @see PropertyMappings
 */
public class FDSpecificationExtender {

	private FDSpecification spec = null;
	
	private Map<FDPropertyHost, List<FDPropertyDecl>> declarations = Maps.newHashMap();
	private Map<FDPropertyHost, Boolean> hasMandatoryProps = Maps.newHashMap();
	
	/**
	 * Construct a FDSpecificationExtender object from a FDSpecification.
	 * 
	 * @param spec  the specification for this extender 
	 */
	public FDSpecificationExtender (FDSpecification spec) {
		this.spec = spec;
	}

	/**
	 * Check if a property host has mandatory properties in this specification.
	 * 
	 * @param host  the property host which should be checked
	 */
	public boolean isMandatory (FDPropertyHost host) {
		if (! hasMandatoryProps.containsKey(host)) {
			createEntry(host);
		}
		return hasMandatoryProps.get(host);
	}

	/**
	 * Get all property declarations for a property host.
	 * 
	 * @param host  the property host
	 * @return the list of property declarations
	 */
	public List<FDPropertyDecl> getDecls (FDPropertyHost host) {
		if (! declarations.containsKey(host)) {
			createEntry(host);
		}
		return declarations.get(host);
	}
	
	
	private void createEntry (FDPropertyHost host) {
		final List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(spec, host);
		declarations.put(host, decls);
		
		hasMandatoryProps.put(host, PropertyMappings.hasMandatoryProperties(decls));
	}
}
