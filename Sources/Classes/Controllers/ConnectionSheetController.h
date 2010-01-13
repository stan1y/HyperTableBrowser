//
//  ConnectionSheetController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/10/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThriftConnection.h>
#import <ThriftConnectionInfo.h>
#import <CoreDataObjects.h>

@interface ConnectionSheetController : NSObject {
	
	IBOutlet id connectionSheet;
	
	IBOutlet id connectButton;
	IBOutlet id cancelButton;
	
	IBOutlet id indicator;
	IBOutlet id statusField;
	IBOutlet id addressField;
	IBOutlet id portField;
	
	NSOutlineView * serversView;
}

@property (assign) IBOutlet NSOutlineView * serversView;

- (IBAction)showConnectionSheet:(id)sender;
- (IBAction)performConnect:(id)sender;
- (IBAction)cancelConnect:(id)sender;

@end
