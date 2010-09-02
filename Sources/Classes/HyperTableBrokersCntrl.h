//
//  HyperTableBrokersCntrl.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 Stanislav Yudin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HyperTable.h"
/*
	Class provides listing and selection of available HyperTable
	brokers in NSPopUpButton.
 */

@interface HyperTableBrokersCntrl : NSWindowController
{
	NSPopUpButton * brokerSelector;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton * brokerSelector;

- (IBAction) updateBrokers:(id)sender;
- (void) updateBrokersWithCompletionBlock:(void (^)(BOOL)) codeBlock;
- (void) addAndUpdate:(id)hypertable withCompletionBlock:(void (^)(BOOL)) codeBlock;
													   
- (HyperTable *) selectedBroker;

@end
