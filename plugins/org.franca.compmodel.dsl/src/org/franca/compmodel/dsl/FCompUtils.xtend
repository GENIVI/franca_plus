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
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection

class FCompUtils {

	/**
	 * Get the component which contains the object.
	 * @param	object
	 * @returns	component or null, if no container of type FCComponent is found
	 */
	public def static getComponentForObject(EObject object) {
		var EObject o = object
		while (o.eContainer !== null) {
			if (o.eContainer instanceof FCComponent)
				return o.eContainer as FCComponent
			o = o.eContainer 
		}
		return null
	} 
	
	/**
	 * Check if two objects have the same parent of type FCComponent.
	 */
	public def static inSameComponent(EObject o1, EObject o2) {
		val c1 = getComponentForObject(o1)
		if (c1 === null)
			false
		else 
			c1 === getComponentForObject(o2)
	}
	
	/** 
	 * Collection of all ports of a component depending on the type of the port.
	 * Inherited Ports are included.
	 * @param	component
	 * @param	kind of the requested ports: required or provided
	 * @returns list of ports 
	 */	
	public def static void collectInheritedPorts(FCComponent comp, FCPortKind pt, List<FCPort> ports) {
		if (comp !== null) {
			if (pt == FCPortKind.PROVIDED)
				ports += comp.providedPorts
			else 
				ports += comp.requiredPorts
			
			// Since Xtext follows the rule of lazy instantiation,
			// it happens that the port names are null because the Interfaces aren't instantiated yet.
			// The following call triggers this so the name value for the ports won't be null anymore
			// ports.forEach[it.interface]
		
			ports.forEach[
				if (interface.eIsProxy)
					EcoreUtil.resolve(interface, it)
			]
			
			if (comp.superType !== null)
				collectInheritedPorts(comp.superType, pt, ports)
		}	
	}
	
	/** 
	 * Collection of all prototypes of a component.
	 * Inherited prototypes and injections are included. 
	 * @param component
	 * @returns list of prototypes
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
	
	/**
	 * Check if Component a is derived from component b.
	 * Deliver true is a i derived from b or a equals b. Else false
	 */
	 public def static boolean isDerivedFrom(FCComponent a, FCComponent b) {
	 	if (a === b)
	 		return true
	 	var parent = a.superType
	 	while (parent !== null) {
	 		if (parent === b)
	 			return true
	 		else parent = parent.superType
		}
	 	return false
	 }	
}
