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
#import <ConnectOperation.h>
#import <FetchTablesOperation.h>

@interface ConnectionSheetController : NSObject {
	
	IBOutlet id connectionSheet;
	
	IBOutlet id connectButton;
	IBOutlet id cancelButton;
	
	IBOutlet id indicator;
	IBOutlet id statusField;
	IBOutlet id addressField;
	IBOutlet id portField;
}

- (IBAction)showSheet:(id)sender 
			 modalFor:(id)modalWindow;

- (IBAction)showSheet:(id)sender 
			 modalFor:(id)modalWindow
			   toHost:(NSString *)host 
			  andPort:(int)port;

- (IBAction)performConnect:(id)sender;

- (IBAction)cancelConnect:(id)sender;

@end
