//
//  TablesListDelegate.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "TablesListDelegate.h"

@implementation TablesListDelegate 

- (id)ruleEditor:(NSRuleEditor *)editor child:(NSInteger)index forCriterion:(id)criterion withRowType:(NSRuleEditorRowType)rowType
{
	NSLog(@"child at %d with crit:%s type:%d", index, [criterion UTF8String], rowType);
	return nil;
}

- (id)ruleEditor:(NSRuleEditor *)editor displayValueForCriterion:(id)criterion inRow:(NSInteger)row
{
	NSLog(@"value for crit:%s at row:%d", index, [criterion UTF8String], row);
	return nil;
}

- (NSInteger)ruleEditor:(NSRuleEditor *)editor numberOfChildrenForCriterion:(id)criterion withRowType:(NSRuleEditorRowType)rowType
{
	NSLog(@"num of children for crit:%s type:%d", index, [criterion UTF8String], rowType);
	return [[[[[NSApp delegate] tablesBrowser] getSelectedConnection] tables] count];
}

@end
