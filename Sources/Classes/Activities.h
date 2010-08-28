//
//  Activities.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 28/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Activities : NSWindowController {
	NSTableView * activitiesTable;
	NSMutableArray * operations;
	NSOperationQueue * operationsQueue;
}

@property (nonatomic, retain) NSOperationQueue * operationsQueue;
@property (nonatomic, retain) NSMutableArray * operations;
@property (nonatomic, retain) IBOutlet NSTableView * activitiesTable;

- (IBAction) terminateSelected:(id)sender;
- (NSDictionary *) selectedActivity;

@end