/* Copyright (C) 2018 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.franca.compdeploymodel.dsl.fDeploy.FDComponent
import org.franca.compdeploymodel.dsl.fDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.fDeploy.FDDevice
import org.franca.compdeploymodel.dsl.fDeploy.FDInterface
import org.franca.compdeploymodel.dsl.fDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.fDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.fDeploy.FDService
import org.franca.compdeploymodel.dsl.fDeploy.FDTypes

class FDeployDeclarativeNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	
	override getFullyQualifiedName(EObject obj) {
		switch (obj) {
			// provide a port name in the scope of the current deployment package
			FDProvidedPort,
			FDRequiredPort: {
				val node = NodeModelUtils.getNode(obj)
				val segments = NodeModelUtils.getTokenText(node).split("\\s")
				if (segments.length >= 2) 
					obj.name = segments.get(1)
			}
			// default name provisioning for anonymous deployments:
			// <current deployment package>.<short name of deployed entity>_depl
			FDService,
			FDComponent,
			FDDevice,
			FDInterface,
			FDTypes: {
				if (obj.name === null) {
					val node = NodeModelUtils.getNode(obj)
					val segments = NodeModelUtils.getTokenText(node).split("\\s")
					if (segments.length >= 5) {
						val name = segments.get(4).split("\\.").last
						obj.name = name + "_depl"
					}
				}
			}
		}
		return super.getFullyQualifiedName(obj)
	}
	
	 def QualifiedName qualifiedName(FDComponentInstance i) {	
    	if (i.name === null) {
	    	val node = NodeModelUtils.getNode(i)
			i.name = NodeModelUtils.getTokenText(node)
		}
		val qn = converter.toQualifiedName(i.name)
		qn	
    }
}
