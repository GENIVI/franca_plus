/*
 * generated by Xtext
 */
package org.franca.compdeploymodel.dsl.ui.contentassist;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jdt.internal.core.JavaProject;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.GrammarUtil;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.resource.IContainer;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext;
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;
import org.franca.compdeploymodel.core.FDModelUtils;
import org.franca.compdeploymodel.dsl.fDeploy.FDModel;
import org.franca.compdeploymodel.dsl.fDeploy.FDOverwriteElement;
import org.franca.compdeploymodel.dsl.fDeploy.FDeployPackage;
import org.franca.compdeploymodel.dsl.fDeploy.Import;
import org.franca.compdeploymodel.dsl.scoping.DeploySpecProvider;
import org.franca.compdeploymodel.dsl.scoping.DeploySpecProvider.DeploySpecEntry;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FUnionType;
import org.franca.core.utils.FrancaIDLUtils;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

/**
 * see
 * http://www.eclipse.org/Xtext/documentation/latest/xtext.html#contentAssist on
 * how to customize content assistant
 */
@SuppressWarnings({ "restriction" })
public class FDeployProposalProvider extends AbstractFDeployProposalProvider {
	@Inject
	DeploySpecProvider deploySpecProvider;
	@Inject
	ContainerUtil containerUtil;

	protected final static String[] extensionsForImportURIScope = new String[] {
			"fidl", "fdepl", "fcdl" };

	static {
		Arrays.sort(extensionsForImportURIScope);
	}

	/** Avoid generic proposal "importURI". */
	@Override
	public void complete_STRING(EObject model, RuleCall ruleCall,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		Assignment ass = GrammarUtil.containingAssignment(ruleCall);
		if (ass == null || !"importURI".equals(ass.getFeature())) {
			super.complete_STRING(model, ruleCall, context, acceptor);
		}
	}

	@Override
	public void completeFDTypes_Target(EObject model, Assignment assignment,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		IScope scope = this.getScopeProvider().getScope(model,
				FDeployPackage.Literals.FD_TYPES__TARGET);
		for (IEObjectDescription description : scope.getAllElements()) {
			// only FTypeCollection instances will be in the scope
			FTypeCollection collection = (FTypeCollection) description
					.getEObjectOrProxy();
			String qualifiedName = description.getQualifiedName().toString();
			String uri = collection.eResource().getURI().toString();
			if (collection.getName() == null || collection.getName().isEmpty()) {
				acceptor.accept(this.createCompletionProposal(qualifiedName,
						qualifiedName + " (anonymous) - " + uri, null, context));
			} else {
				acceptor.accept(this.createCompletionProposal(qualifiedName,
						qualifiedName + " - " + uri, null, context));
			}
		}
	}

	/**
	 * Proposes both all fidl, fcdl and fdepl files in the current workspace (to be
	 * precise: the files residing in visible containers) as well as the
	 * fdepl-files contributed by means of
	 * <code> &lt;extension point="org.franca.compdeploymodel.dsl.deploySpecProvider"> </code>
	 */
	@Override
	public void completeImport_ImportURI(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		List<IContainer> visibleContainers = containerUtil.getVisibleContainers(model.eResource());
		URI fromURI = model.eResource().getURI();
		List<URI> proposedURIs = new ArrayList<URI>();
		FDModel fdmodel = null;
		if (model instanceof FDModel) {
			fdmodel = (FDModel) model;
		} else if (model instanceof Import) {
			fdmodel = (FDModel)model.eContainer();
		}
		EList<Import> imports = fdmodel.getImports();
		List<String> importedUris = Lists.newArrayList();
		for (Import import1 : imports) {
			importedUris.add(import1.getImportURI());	
		}
		for (IContainer iContainer : visibleContainers) {
			Iterable<IResourceDescription> resourceDescriptions = iContainer.getResourceDescriptions();
			for (Iterator<IResourceDescription> iterator = resourceDescriptions.iterator(); iterator.hasNext();) {
				IResourceDescription desc = iterator.next();
				URI uri = desc.getURI();
				if (!uri.equals(fromURI) && Arrays.binarySearch(extensionsForImportURIScope, uri.fileExtension()) > -1) {
					proposedURIs.add(desc.getURI());
				}
			}
		}
		for (URI uri : proposedURIs) {
			String result = FrancaIDLUtils.relativeURIString(fromURI, uri);
			if(!importedUris.contains(result)){
				String displayString = uri.lastSegment() + " - " + result;
				acceptor.accept(createCompletionProposal("\"" + result + "\"", displayString, null, context));
			}
		}
		List<URI> classpathResources = Lists.newArrayList();
		XtextResourceSet resourceSet = (XtextResourceSet)model.eResource().getResourceSet();
		Object classpathURIContext = resourceSet.getClasspathURIContext();
		if (classpathURIContext instanceof JavaProject) {
			for (IContainer iContainer : visibleContainers) {
				Iterable<IResourceDescription> resourceDescriptions = iContainer.getResourceDescriptions();
				for (IResourceDescription iResourceDescription : resourceDescriptions) {
					if(iResourceDescription.getURI().toString()!=model.eResource().getURI().toString() && (Arrays.binarySearch(extensionsForImportURIScope, iResourceDescription.getURI().fileExtension()) > -1)){
						classpathResources.add(iResourceDescription.getURI());
					}
				}
			}
		}
		if (context.getPrefix()=="\"classpath:") {
			createProposals(context, acceptor, classpathResources,fromURI,importedUris);
		}
		else {
			createProposals(context, acceptor, classpathResources,fromURI,importedUris);
		}		
		super.completeImport_ImportURI(model, assignment, context, acceptor);
	}

	private void createProposals(ContentAssistContext context,ICompletionProposalAcceptor acceptor,List<URI> classpathResources,URI fromURI, List<String> importedUris) {
		for (URI path : classpathResources) {
			String result = toClassPathString(path);
			if(!importedUris.contains(result)){
				String displayString = path.lastSegment() + " - " + result;
				createProposal(result,displayString, context, acceptor);
			}
		}
	}

	@Override
	public void completeImport_ImportedSpec(EObject model,
			Assignment assignment, ContentAssistContext context,
			ICompletionProposalAcceptor acceptor) {
		Collection<DeploySpecEntry> entries = deploySpecProvider.getEntries();
		for (Iterator<DeploySpecEntry> iterator = entries.iterator(); iterator
				.hasNext();) {
			DeploySpecEntry dse = iterator.next();
			acceptor.accept(createCompletionProposal(dse.alias, dse.alias
					+ " - " + dse.resourceId, null, context));
		}
	}

	public String toClassPathString(final URI uri) {
		String _xblockexpression = null;
		{
			List<String> _segmentsList = uri.segmentsList();
			final List<String> segments = this.classPathSegments(_segmentsList);
			StringConcatenation _builder = new StringConcatenation();
			_builder.append("classpath:/");
			Joiner _on = Joiner.on("/");
			String _join = _on.join(segments);
			_builder.append(_join, "");
			_xblockexpression = _builder.toString();
		}
		return _xblockexpression;
	}

	public List<String> classPathSegments(final List<String> list) {
		List<String> _xblockexpression = null;
		{
			int _size = list.size();
			List<String> sublist = list.subList(3, _size);
			_xblockexpression = sublist;
		}
		return _xblockexpression;
	}

	public void createProposal(final String name,
			String substring, final ContentAssistContext context,
			final ICompletionProposalAcceptor acceptor) {
		StringConcatenation _builder = new StringConcatenation();
		String _string = name.toString();
		_builder.append(_string, "");
		ICompletionProposal proposal = this.createCompletionProposal(
				_builder.toString(),substring,null, context);
		if ((proposal instanceof ConfigurableCompletionProposal)) {
			ConfigurableCompletionProposal c = ((ConfigurableCompletionProposal) proposal);
			c.setTextApplier(new ReplacementTextApplier() {
				@Override
				public String getActualReplacementString(
						final ConfigurableCompletionProposal proposal) {
					String _xblockexpression = null;
					{
						int _replaceContextLength = proposal
								.getReplaceContextLength();
						proposal.setReplacementLength(_replaceContextLength);
						StringConcatenation _builder = new StringConcatenation();
						_builder.append("\"");
						String _string = name.toString();
						_builder.append(_string, "");
						_builder.append("\"");
						_xblockexpression = _builder.toString();
					}
					return _xblockexpression;
				}
			});
		}
		acceptor.accept(proposal);
	}

	/**
	 * A set of keywords which will be filtered from the proposals list.
	 */
	private Set<String> filteredKeywords = Sets.newHashSet();

	@Override
	public void completeKeyword(Keyword keyword,
			ContentAssistContext contentAssistContext,
			ICompletionProposalAcceptor acceptor) {
		if (filteredKeywords.contains(keyword.getValue()))
			return;

		super.completeKeyword(keyword, contentAssistContext, acceptor);
	}

	@Override
	public void complete_FDTypeOverwrites(EObject elem, RuleCall ruleCall,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		FType targetType = null;
		if (elem instanceof FDOverwriteElement) {
			targetType = FDModelUtils
					.getOverwriteTargetType((FDOverwriteElement) elem);
		}

		if (targetType == null) {
			showKeywords(false, false, false, false);
		} else {
			if (targetType instanceof FEnumerationType) {
				showKeywords(true, true, false, false);
			} else if (targetType instanceof FStructType) {
				showKeywords(true, false, true, false);
			} else if (targetType instanceof FUnionType) {
				showKeywords(true, false, false, true);
			} else {
				showKeywords(true, false, false, false);
			}
		}
	}

	private void showKeywords(boolean plain, boolean enumeration,
			boolean struct, boolean union) {
		final String p = "#";
		final String e = "#enumeration";
		final String s = "#struct";
		final String u = "#union";

		if (plain)
			filteredKeywords.remove(p);
		else
			filteredKeywords.add(p);

		if (enumeration)
			filteredKeywords.remove(e);
		else
			filteredKeywords.add(e);

		if (struct)
			filteredKeywords.remove(s);
		else
			filteredKeywords.add(s);

		if (union)
			filteredKeywords.remove(u);
		else
			filteredKeywords.add(u);
	}
}