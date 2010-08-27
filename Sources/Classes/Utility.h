//
//  Utility.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
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
- (void) updateBrokers:(id)sender withCompletionBlock:(void (^)(void)) codeBlock;
- (void) addAndReconnect:(id)hypertable withCompletionBlock:(void (^)(void)) codeBlock;
													   
- (HyperTable *) selectedBroker;

@end
