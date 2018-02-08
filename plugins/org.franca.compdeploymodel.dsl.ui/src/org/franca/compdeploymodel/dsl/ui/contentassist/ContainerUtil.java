/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compdeploymodel.dsl.ui.contentassist;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.resource.IContainer;
import org.eclipse.xtext.resource.IContainer.Manager;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider;
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider;
import org.eclipse.xtext.util.OnChangeEvictingCache;

import com.google.inject.Inject;
/** 
 * Util-Class providing the visible containers for a resource.
 * This code has been "strongly inspired" by Xtext's {@link DefaultGlobalScopeProvider} 
 * - I tried to resue the code, but it is <code>protected</code>. 
 * Just in case: The Xtext-docs explain containers in detail, you might want to search for "About the Index, Containers and Their Manager". 
 */
public class ContainerUtil {

	@Inject
	private IResourceDescription.Manager descriptionManager;
	@Inject
	private Manager containerManager;
	@Inject
	private ResourceDescriptionsProvider provider;
	
	
	public IResourceDescriptions getResourceDescriptions(Resource resource) {
		return provider.getResourceDescriptions(resource);
	}

	public List<IContainer> getVisibleContainers(Resource resource) {
		IResourceDescription description = descriptionManager.getResourceDescription(resource);
		IResourceDescriptions resourceDescriptions = getResourceDescriptions(resource);
		String cacheKey = getCacheKey("VisibleContainers", resource.getResourceSet());
		OnChangeEvictingCache.CacheAdapter cache = new OnChangeEvictingCache().getOrCreate(resource);
		List<IContainer> result = null;
		result = cache.get(cacheKey);
		if (result == null) {
			result = containerManager.getVisibleContainers(description, resourceDescriptions);
			cache.set(cacheKey, result);
		}
		return result;
	}

	protected String getCacheKey(String base, ResourceSet context) {
		Map<Object, Object> loadOptions = context.getLoadOptions();
		if (loadOptions.containsKey(ResourceDescriptionsProvider.NAMED_BUILDER_SCOPE)) {
			return base + "@" + ResourceDescriptionsProvider.NAMED_BUILDER_SCOPE;
		}
		return base + "@DEFAULT_SCOPE";
	}
}
