/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCLabelKind
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototype

class FCompUtils {

	public def static getComponentForObject(EObject obj) {
		var EObject o = obj
		while (o.eContainer !== null) {
			if (o.eContainer instanceof FCComponent)
				return o.eContainer as FCComponent
			o = o.eContainer 
		}
		return null
	} 
	
	public def static inSameComponent(EObject o1, EObject o2) {
		val c1 = getComponentForObject(o1)
		if (c1 === null)
			return false
		else 
			return c1 === getComponentForObject(o2)
	}
	
	/** Collection of all ports of a component depending on the type of the port.
	 * Inherited Ports are included.
	 */	
	public def static void collectInheritedPorts(FCComponent comp, FCPortKind pt, List<FCPort> ports) {
		if (pt == FCPortKind.PROVIDED)
			ports += comp.providedPorts
		else 
			ports += comp.requiredPorts
			
		if (comp.superType !== null)
			collectInheritedPorts(comp.superType, pt, ports)	
	}
	
	public def static FCModel getFCModel(EObject o) {
		var EObject obj = o
		while(obj !== null) {
			if (!(obj instanceof FCModel)) {
				return obj as FCModel
			} else {
				obj = o.eContainer
			}
		}
		return null
	}
	
	/*
	 * get all component prototypes that refer to the component provided as argument
	 */
	public def static List<FCPrototype> findParentComponentRefs(FCPrototype proto) {
		val FCComponent currentComp = FCompUtils.getComponentForObject(proto)
		if(currentComp === null)
			return #[]
		
		val root = EcoreUtil2.getRootContainer(currentComp)
		if(root === null)
			return #[]
		EcoreUtil2.getAllContentsOfType(root, FCPrototype).filter[
			if(it === null)
				return false
			it.component === currentComp
		].toList
	}
	
	// return the toplevel component marked with annotation @root
	public def static FCComponent getSystemRootComponent(FCPrototype prototype) {
		val root = EcoreUtil2.getRootContainer(prototype)
		if(root === null)
			return null

		val allPrototypes = EcoreUtil2.getAllContentsOfType(root, FCPrototype)
		var FCComponent currentcomp = prototype.eContainer as FCComponent
		while(currentcomp !== null) {
			if(currentcomp.labels.map[kind].contains(FCLabelKind.ROOT))
				return currentcomp
			else {
				val FCComponent comp = currentcomp
				val superprototypes = allPrototypes.filter[
					it.component === comp
				].toList
				if(superprototypes.length > 0)
					currentcomp = superprototypes.head.eContainer as FCComponent
				else
					return null
			}
		}
		return null;
	}
}
