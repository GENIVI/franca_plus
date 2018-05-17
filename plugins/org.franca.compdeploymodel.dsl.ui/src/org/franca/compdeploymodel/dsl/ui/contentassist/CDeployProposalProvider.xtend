/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compdeploymodel.dsl.ui.contentassist

import com.google.common.base.Joiner
import com.google.inject.Inject
import java.net.URL
import java.util.ArrayList
import java.util.Collections
import java.util.Iterator
import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtend2.lib.StringConcatenation
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.ui.IImageHelper
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier
import org.franca.core.utils.FrancaIDLUtils
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.Import
import org.osgi.framework.Bundle

/** 
 * see
 * http://www.eclipse.org/Xtext/documentation/latest/xtext.html#contentAssist on
 * how to customize content assistant
 */
class CDeployProposalProvider extends AbstractCDeployProposalProvider {
	@Inject 
	package ContainerUtil localContainerUtil
	
	@Inject 
	package IImageHelper imageHelper
		
	final val String[] localExtensionsForImportURIScope = (#["cdepl", "fcdl", "fdepl", "fidl" ] as String[])
	/** 
	 * Configure the available deployment specification by setting this parameter as 
	 * JVM argument pointing to a plugin with the depl-files containing the specifications.
	 * Multiple plugins can be given, separated by a comma.
	 */
	final static String deploymentBundles = "deploymentBundles"

	/** 
	 * Proposes both all fidl, fcdl, fdepl and cdepl files in the current workspace (to be
	 * precise: the files residing in visible containers) as well as the
	 * fdepl-files contributed by means of
	 * <code> &lt;extension point="org.franca.compdeploymodel.dsl.deploySpecProvider"> </code>
	 */
	override void completeImport_ImportURI(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
			
		val URI fromURI = model.eResource().getURI()
		val List<URI> proposedURIs = new ArrayList<URI>()
		var FDModel fdmodel = null
		val List<IContainer> visibleContainers = localContainerUtil.getVisibleContainers(model.eResource())
		
		if (model instanceof FDModel) {
			fdmodel = model as FDModel
		} else if (model instanceof Import) {
			fdmodel = model.eContainer() as FDModel
		}
		val EList<Import> imports = fdmodel.getImports()
		val List<String> importedUris = new ArrayList<String>()
		for (Import import1 : imports) {
			importedUris.add(import1.getImportURI())
		}
		for (IContainer iContainer : visibleContainers) {
			val Iterable<IResourceDescription> resourceDescriptions = iContainer.getResourceDescriptions()
			for (val Iterator<IResourceDescription> iterator = resourceDescriptions.iterator(); iterator.hasNext();) {
				val IResourceDescription desc = iterator.next()
				val URI uri = desc.getURI()
				if (!uri.equals(fromURI) &&
					localExtensionsForImportURIScope.contains(uri.fileExtension)) {
					proposedURIs.add(desc.getURI())
				}
			}
		}
		if ("platform".startsWith(context.getPrefix())) {
			createPlatformProposals(context, acceptor, fromURI, importedUris)
		} else if ("classpath".startsWith(context.getPrefix())) {
			createClasspathProposals(context, acceptor, proposedURIs, fromURI, importedUris)
		}
		createFileProposals(context, acceptor, proposedURIs, fromURI, importedUris)
		super.completeImport_ImportURI(model, assignment, context, acceptor)
	}

	def private void createPlatformProposals(ContentAssistContext context, ICompletionProposalAcceptor acceptor,
		URI fromURI, List<String> importedUris) {
		var String specificationBundleNames = System::getProperty(deploymentBundles, "org.franca.architecture")
		var String[] bundles = specificationBundleNames.split(",")
		for (String bundleName : bundles) {
			val trimmedBundleName = bundleName.trim()
			var Bundle plugin = Platform::getBundle(trimmedBundleName)
			try {
				val List<URL> urls = Collections.list(plugin.findEntries("/", "*.*depl", true))
				urls.forEach[
					var String specName = '''platform:/plugin/«trimmedBundleName»«it.getPath()»'''.toString
					if (!importedUris.contains(specName)) {
						var String[] segments = specName.split("/")
						var String displayString = '''«{val _rdIndx_segments=segments.length - 1 segments.get(_rdIndx_segments)}» - «specName»'''.
							toString
						createProposal(specName, displayString, context, acceptor)
					}
				]
			} catch (Exception e) {
				System::err.println(
					'''cannot set specification plugin '«»«trimmedBundleName»':«e.getMessage()»'''.toString)
			}

		}
	}

	def private void createClasspathProposals(ContentAssistContext context, ICompletionProposalAcceptor acceptor,
		List<URI> proposedURIs, URI fromURI, List<String> importedUris) {
		for (URI path : proposedURIs) {
			var String result = toClassPathString(path)
			if (!importedUris.contains(result)) {
				var String displayString = '''«path.lastSegment()» - «result»'''.toString
				createProposal(result, displayString, context, acceptor)
			}
		}
	}

	def private void createFileProposals(ContentAssistContext context, ICompletionProposalAcceptor acceptor,
		List<URI> proposedURIs, URI fromURI, List<String> importedUris) {
		for (URI uri : proposedURIs) {
			var String result = FrancaIDLUtils::relativeURIString(fromURI, uri)
			if (!importedUris.contains(result)) {
				var String displayString = '''«uri.lastSegment()» - «result»'''.toString
				createProposal(result, displayString, context, acceptor)
			}
		}
	}

	private def String toClassPathString(URI uri) {
		val List<String> _segmentsList = uri.segmentsList()
		val List<String> segments = this.classPathSegments(_segmentsList)
		val StringConcatenation _builder = new StringConcatenation()
		_builder.append("classpath:/")
		val Joiner _on = Joiner::on("/")
		val String _join = _on.join(segments)
		_builder.append(_join, "")
		return _builder.toString()

	}

	private def List<String> classPathSegments(List<String> list) {
		val int _size = list.size()
		val List<String> sublist = list.subList(3, _size)
		return sublist
	}

	private def void createProposal(String name, String substring, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
			var StringConcatenation _builder = new StringConcatenation()
			var String _string = name.toString()
			_builder.append(_string, "")
			var ICompletionProposal proposal = this.createCompletionProposal(_builder.toString(), substring, null, context)
			if ((proposal instanceof ConfigurableCompletionProposal)) {
	
				proposal.setTextApplier(([ ConfigurableCompletionProposal _proposal |
					_proposal.setReplacementLength(_proposal.getReplaceContextLength())
					return ("\"" + name + "\"\r\n")
				] as ReplacementTextApplier))
		}
		acceptor.accept(proposal)
	}
}
