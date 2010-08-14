//
//  InsertNewRowController.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 4/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HyperTableOperationController.h>
#import <HyperTable.h>

@interface InsertNewRowController : NSViewController {
	NSPopUpButton * tableSelector;
	HyperTable * connection;
}

@property (nonatomic, retain) HyperTable * connection;
@property (nonatomic, retain) IBOutlet NSPopUpButton * tableSelector;

- (IBAction)updateTables:(id)sender;

@end
