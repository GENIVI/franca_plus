/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.scoping

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.franca.compdeploymodel.dsl.fDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.fDeploy.FDService
import org.franca.compdeploymodel.dsl.fDeploy.FDDevice

class FDeployDeclarativeNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	
	 def QualifiedName qualifiedName(FDComponentInstance i) {	
    	if (i.name == null) {
	    	val node = NodeModelUtils.getNode(i)
			i.name = NodeModelUtils.getTokenText(node)
		}
		val fqn = converter.toQualifiedName(i.name)
		fqn	
    }
    
    /**
	 * Provide the service deployment name as qualified name for a service if no explicit name is given by the user.
	 */
	def QualifiedName qualifiedName(FDService s) {
        if (s.name !== null && s.name.length > 0) 
        	return super.qualifiedName(s)
		
		val node = NodeModelUtils.getNode(s)
		val segments = NodeModelUtils.getTokenText(node).split("\\s")
		if (segments.length >= 4)
			s.name = segments.get(4)
		val fqn = converter.toQualifiedName( s.name )
		fqn
    }
    
    /**
	 * Provide the device deployment name as qualified name for a device if no explicit name is given by the user.
	 */
	def QualifiedName qualifiedName(FDDevice d) {
        if (d.name !== null && d.name.length > 0) 
        	return super.qualifiedName(d)
		
		val node = NodeModelUtils.getNode(d)
		val segments = NodeModelUtils.getTokenText(node).split("\\s")
		if (segments.length >= 4)
			d.name = segments.get(4)
		val fqn = converter.toQualifiedName( d.name )
		fqn
    }
}
