/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.linker

import java.io.IOException
import java.util.HashSet
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer
import org.eclipse.xtext.linking.lazy.LazyLinker
import org.franca.compmodel.dsl.fcomp.FCInstance

public class FCompLinker extends LazyLinker {
	
	override void beforeModelLinked(EObject model, IDiagnosticConsumer diagnosticsConsumer) {
		super.beforeModelLinked(model, diagnosticsConsumer)
			
		var HashSet<Resource> toBeDeleted = newHashSet()
		// println("FCompLinker running on model: " + model)
		var rset = model.eResource.resourceSet

		var instances = rset.allContents.filter(FCInstance)
		
		while (instances.hasNext) {
			val instance = instances.next 
			val URI uri = URI.createURI(instance.name + FCompLinkingService.DOMAIN)
			var resource = rset.getResource(uri, false)
			if (resource != null) {
				for (EObject obj : resource.getContents()) {
					// println("FCompLinker has resource for obj: " + obj)
					if (obj != null) {
						// println("Checking local resource contains uri: " 
						//	+ (obj.eResource === resource ?: "yes" ?: "no"))
						toBeDeleted.add(obj.eResource)
					}
				}
				for(Resource r : toBeDeleted) {
					try {
						r.delete(null);
					} catch (IOException e) {
						println("FCompLinker ERROR deleting resource")
						e.printStackTrace();
					}
				}
			}
		}
	}
}
		
