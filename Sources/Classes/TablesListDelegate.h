//
//  TablesListDelegate.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TablesListDelegate : NSObject  {

}

- (id)ruleEditor:(NSRuleEditor *)editor 
		   child:(NSInteger)index 
	forCriterion:(id)criterion 
	 withRowType:(NSRuleEditorRowType)rowType;

- (id)ruleEditor:(NSRuleEditor *)editor 
displayValueForCriterion:(id)criterion 
		   inRow:(NSInteger)row;

- (NSInteger)ruleEditor:(NSRuleEditor *)editor 
numberOfChildrenForCriterion:(id)criterion 
			withRowType:(NSRuleEditorRowType)rowType;

@end
