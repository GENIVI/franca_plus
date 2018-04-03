/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.external.validator;

import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.compmodel.dsl.fcomp.FCAnnotation;
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock;
import org.franca.compmodel.dsl.fcomp.FCComponent;
import org.franca.compmodel.dsl.fcomp.FCModel;
import org.franca.compmodel.dsl.fcomp.FcompPackage;
import org.franca.compmodel.dsl.validation.IFCompExternalValidator;

public class ExternalTestValidator implements IFCompExternalValidator 
{

	@Override
	public void validateModel(FCModel arg0, ValidationMessageAcceptor arg1) 
	{
		
		EList<FCComponent> list = arg0.getComponents();
		
		for(FCComponent comp : list) {
			if(comp.getComment() == null) {
				arg1.acceptError("A comment section is required", comp,
						FcompPackage.Literals.FC_COMPONENT__NAME, ValidationMessageAcceptor.INSIGNIFICANT_INDEX, null);
			}
			else {
				 FCAnnotationBlock annotation = comp.getComment();
				 EList<FCAnnotation>annotationsFragments = annotation.getElements();
				if(annotationsFragments.isEmpty()) {
					arg1.acceptError("A Tag is required inside the comment section", annotation,
							FcompPackage.Literals.FC_ANNOTATION_BLOCK__ELEMENTS, ValidationMessageAcceptor.INSIGNIFICANT_INDEX, null);
				}
			}			
		}
	}
}
