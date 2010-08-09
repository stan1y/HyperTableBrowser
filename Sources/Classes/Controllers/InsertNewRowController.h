//
//  InsertNewRowController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTableOperationController.h>
#import <ThriftConnection.h>

@interface InsertNewRowController : NSViewController {
	NSPopUpButton * tableSelector;
	ThriftConnection * connection;
}

@property (nonatomic, retain) ThriftConnection * connection;
@property (nonatomic, retain) IBOutlet NSPopUpButton * tableSelector;

- (IBAction)updateTables:(id)sender;

@end
