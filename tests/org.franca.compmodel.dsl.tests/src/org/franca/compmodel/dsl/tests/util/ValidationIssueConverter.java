package org.franca.compmodel.dsl.tests.util;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.eclipse.xtext.validation.Issue;

import com.google.common.collect.Lists;

public class ValidationIssueConverter {
	private static final String LINE_SEPARATOR = System.getProperty("line.separator");
	
	public static String getIssuesAsString (List<Issue> issues) {
		Comparator<Issue> comparator = new Comparator<Issue>() {
			@Override
			public int compare(Issue i1, Issue i2) {
				return i1.getLineNumber() - i2.getLineNumber();
			}
		};
		
		List<Issue> issuesSorted = Lists.newArrayList(issues);
		Collections.sort(issuesSorted, comparator);
		StringBuilder sb = new StringBuilder();
		for(Issue i : issuesSorted) {
			sb.append(i.getLineNumber());
			sb.append(':');
			sb.append(i.getMessage());
			sb.append(LINE_SEPARATOR);
		}
		
		return sb.toString();
	}

}

