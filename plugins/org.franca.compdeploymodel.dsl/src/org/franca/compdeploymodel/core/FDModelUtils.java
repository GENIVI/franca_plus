/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.core;

import org.eclipse.emf.ecore.EObject;
import org.franca.compdeploymodel.dsl.fDeploy.FDArgument;
import org.franca.compdeploymodel.dsl.fDeploy.FDArray;
import org.franca.compdeploymodel.dsl.fDeploy.FDAttribute;
import org.franca.compdeploymodel.dsl.fDeploy.FDComponentInstance;
import org.franca.compdeploymodel.dsl.fDeploy.FDElement;
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumerator;
import org.franca.compdeploymodel.dsl.fDeploy.FDField;
import org.franca.compdeploymodel.dsl.fDeploy.FDGeneric;
import org.franca.compdeploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.compdeploymodel.dsl.fDeploy.FDModel;
import org.franca.compdeploymodel.dsl.fDeploy.FDOverwriteElement;
import org.franca.compdeploymodel.dsl.fDeploy.FDRootElement;
import org.franca.compdeploymodel.dsl.fDeploy.FDSpecification;
import org.franca.compdeploymodel.dsl.fDeploy.FDValue;
import org.franca.compmodel.dsl.fcomp.FCComponent;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeRef;

/**
 * Helper functions for navigation in deployment models.
 * 
 * @author Klaus Birken (itemis AG)
 *
 */
public class FDModelUtils {

	public static FDModel getModel(EObject obj) {
		EObject x = obj;
		while (x != null) {
			if (x instanceof FDModel)
				return (FDModel) x;
			x = x.eContainer();
		};
		return null;
	}

	public static FDRootElement getRootElement(FDElement obj) {
		EObject x = obj;
		while (x != null) {
			if (x instanceof FDRootElement)
				return (FDRootElement) x;
			x = x.eContainer();
		};
		return null;
	}
	
	/**
	 * Check if a property value is of type FDInterfaceInstance.
	 * 
	 * @param val the property value
	 * @return true if the value is of type FDInterfaceInstance, false otherwise
	 */
	public static boolean isInstanceRef(FDValue val) {
		if (val instanceof FDGeneric) {
			return getInstanceRef(val) != null;
		}
		return false;
	}

	/**
	 * Get the FDInterfaceInstance value of a property value.
	 * 
	 * This will return null if the property has a different type.
	 * 
	 * @param val the property value
	 * @return the property value (if it is a FDInterfaceInstance) or null
	 */
	public static FDInterfaceInstance getInstanceRef(FDValue val) {
		if (val instanceof FDGeneric) {
			EObject vgen = ((FDGeneric)val).getValue();
			if (vgen!=null && (vgen instanceof FDInterfaceInstance)) {
				return (FDInterfaceInstance)vgen;
			}
		}
		return null;
	}

	/**
	 * Check if a property value is of type FDEnumerator.
	 * 
	 * @param val the property value
	 * @return true if the value is of type FDEnumerator, false otherwise
	 */
	public static boolean isEnumerator(FDValue val) {
		if (val instanceof FDGeneric) {
			return getEnumerator(val) != null;
		}
		return false;
	}

	/**
	 * Get the FDEnumerator value of a property value.
	 * 
	 * This will return null if the property has a different type.
	 * 
	 * @param val the property value
	 * @return the property value (if it is a FDEnumerator) or null
	 */
	public static FDEnumerator getEnumerator(FDValue val) {
		if (val instanceof FDGeneric) {
			EObject vgen = ((FDGeneric)val).getValue();
			if (vgen!=null && (vgen instanceof FDEnumerator)) {
				return (FDEnumerator)vgen;
			}
		}
		return null;
	}
	
	/**
	 * Get the target type of an overwrites element.
	 */
	public static FType getOverwriteTargetType(FDOverwriteElement elem) {
		// get Franca type reference depending on type of elem element 
		FTypeRef typeref = null;
		if (elem instanceof FDAttribute) {
			typeref = ((FDAttribute)elem).getTarget().getType();
		} else if (elem instanceof FDArgument) {
			typeref = ((FDArgument)elem).getTarget().getType();
		} else if (elem instanceof FDField) {
			typeref = ((FDField)elem).getTarget().getType();
		} else if (elem instanceof FDArray) {
			typeref = ((FDArray)elem).getTarget().getElementType();
		} 		
		
		// get type from type reference
		if (typeref==null)
			return null;
		else
			return typeref.getDerived();
	}
	
	/**
	 * Get the first segment for a component instance, the so called root. 
	 */
	public static FCComponent getRootOfComponentInstance(FDComponentInstance instance) {
		FDComponentInstance temp = instance;
		while (temp.getParent() != null)
			temp = temp.getParent();
		return temp.getTarget();
	}
	
	/**
	 * Delivers the specification of a deploymodel element.
	 * If element's root element has a specification, the specification property from the containing root element is given back.
	 * If the root element has no specification and is not contained by an other root element NULL is returned.
	 *  
	 * @param element
	 * @return specification
	 */
	public static FDSpecification getSpecification(FDElement element) {
		FDRootElement root = getRootElement(element);
		if (root != null) {
			FDSpecification spec = root.getSpec();
			if (spec != null)
				return spec;
			if (root.eContainer() instanceof FDElement) {
				return getSpecification( (FDElement) (root.eContainer()) );
			}
		}
		return null;
	}
}

