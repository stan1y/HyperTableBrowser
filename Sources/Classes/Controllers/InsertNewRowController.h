//
//  InsertNewRowController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTableOperationController.h>

@interface InsertNewRowController : HyperTableOperationController {
	NSPopUpButton * tableSelector;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton * tableSelector;

- (IBAction)updateConnections:(id)sender;
- (IBAction)serverSelectionChanged:(id)sender;

@end
