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
	
	NSProgressIndicator * progressIndicator;
	NSButton * topActivityTitle;
}

@property (nonatomic, retain) IBOutlet NSProgressIndicator * progressIndicator;
@property (nonatomic, retain) IBOutlet NSButton * topActivityTitle;

@property (nonatomic, retain) NSOperationQueue * operationsQueue;
@property (nonatomic, retain) NSMutableArray * operations;
@property (nonatomic, retain) IBOutlet NSTableView * activitiesTable;

// Singleton
+ (Activities *) sharedInstance;


- (IBAction) terminateSelected:(id)sender;
- (NSDictionary *) selectedActivity;
- (void) appendOperation:(NSOperation *)anOperation 
			   withTitle:(NSString *)title;



@end
