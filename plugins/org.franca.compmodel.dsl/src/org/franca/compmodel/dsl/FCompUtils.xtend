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
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection

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
	
	/** 
	 * Collection of all ports of a component depending on the type of the port.
	 * Inherited Ports are included.
	 */	
	public def static void collectInheritedPorts(FCComponent comp, FCPortKind pt, List<FCPort> ports) {
		if (comp !== null) {
			if (pt == FCPortKind.PROVIDED)
				ports += comp.providedPorts
			else 
				ports += comp.requiredPorts
				
			if (comp.superType !== null)
				collectInheritedPorts(comp.superType, pt, ports)
		}	
	}
	
	/** 
	 * Collection of all prototypes of a component.
	 * Inherited prototypes are included. 
	 * 
	 */	
	public def static void collectInheritedPrototypes(FCComponent comp, List<FCGenericPrototype> prots) {
		if (comp !== null) {
			prots += comp.prototypes
			prots += comp.injections			
			if (comp.superType !== null)
				collectInheritedPrototypes(comp.superType, prots)
		}	
	}
	
	/** 
	 * Collection of all injects of a component.
	 * Inherited injects are included. 
	 */	
	public def static void collectInheritedInjects(FCComponent comp, List<FCPrototypeInjection> injects) {
		if (comp !== null) {
			injects += comp.injections.filter(FCPrototypeInjection)			
			if (comp.superType !== null)
				collectInheritedInjects(comp.superType, injects)
		}	
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
	
	
}
