/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * based on work of Klaus Birken (klaus.birken@itemis.de
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
 package org.franca.compdeploymodel.dsl.generator.internal

import org.franca.compdeploymodel.dsl.fDeploy.FDDeclaration
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumType
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.compdeploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.compdeploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.compdeploymodel.dsl.generator.internal.HostLogic.*
import com.google.inject.Inject

class ComponentAccessorGenerator {

	@Inject extension ImportManager
	@Inject CommonAccessorMethodGenerator helper

	def generate(FDSpecification spec) {
		val context = new CodeContext
		val methods =
			'''
				«FOR d : spec.declarations»
					«d.genProperties(context)»
				«ENDFOR»
			'''

		'''
			/**
			 * Accessor for deployment properties for Component and port instances
			 * according to the '«spec.name»' specification.
			 */
			public static class ComponentPropertyAccessor
				«IF spec.base!==null»extends «spec.base.qualifiedClassname».ComponentPropertyAccessor«ENDIF»
				implements Enums
			{
				«IF context.targetNeeded»
				final private FDeployedComponent target;
				«ENDIF»				
			
				«addNeededFrancaType("FDeployedComponent")»
				public ComponentPropertyAccessor(FDeployedComponent target) {
					«IF spec.base!==null»
					super(target);
					«ENDIF»
					«IF context.targetNeeded»
					this.target = target;
					«ENDIF»
				}
				
				«methods»
			}
		'''
	}
	
	def private genProperties(FDDeclaration decl, ICodeContext context) '''
		«IF decl.properties.size > 0 && decl.host.isComponentHost»
			// host '«decl.host.getName»'
			«FOR p : decl.properties»
			«p.genProperty(decl.host, context)»
			«ENDFOR»
			
		«ENDIF»
	'''
	
	def private genProperty(FDPropertyDecl it, FDPropertyHost host, ICodeContext context) {
		val francaType = host.francaTypeComponent
		addNeededFrancaType(francaType)
		if (francaType!==null) {
			context.requireTargetMember
			if (isEnum) {
				val enumType = name.toFirstUpper
				val retType =
					if (type.array===null) {
						enumType
					} else {
						enumType.genListType.toString
					}
				val enumerator = type.complex as FDEnumType
				helper.generateEnumMethod(it, francaType, enumType, retType, enumerator)
			} else {
				helper.generateMethod(it, francaType)
			}
		} else
			""
	}
}

