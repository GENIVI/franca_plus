/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.outline

import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInstance
import org.franca.compmodel.dsl.fcomp.FCAnnotation

/**
 * Customization of the default outline structure.
 *
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#outline
 */
class FCompOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	protected def boolean _isLeaf(FCPrototypeInstance feature) {
	    true
	}
	
	protected def boolean _isLeaf(FCAnnotation feature) {
	    true
	}
	
	/**
	 * Provide a navigable tree structure with components and prototypes 
	 */
	protected def void _createNode(IOutlineNode parentNode, FCPrototype proto) {
		if (proto.component !== proto.eContainer as FCComponent) {
			val protoNode = createEObjectNode(parentNode, proto)
			if (proto.comment !== null)
				_createNode(protoNode, proto.comment)
			_createNode(protoNode, proto.component)
		}
	}	
}
