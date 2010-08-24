//
//  Inspector.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Inspector : NSWindowController {
	NSTextField * objectTitle;
	NSTextField * healthPercentage;
	NSTextField * remoteShell;
	NSTextField * hostname;
	NSLevelIndicator * healthBar; 
	NSTextField * comments;
	
	int selectedServiceIndex;
	NSArray * serviceRunningValues;
	NSArray * serviceStoppedValues;
}

@property (nonatomic, retain) IBOutlet NSTextField * remoteShell;
@property (nonatomic, retain) IBOutlet NSTextField * objectTitle;
@property (nonatomic, retain) IBOutlet NSTextField * healthPercentage;
@property (nonatomic, retain) IBOutlet NSLevelIndicator * healthBar;
@property (nonatomic, retain) IBOutlet NSTextField * hostname;
@property (nonatomic, retain) IBOutlet NSTextField * comments;

- (IBAction) operateService:(id)sender;
- (IBAction) closeInspector:(id)sender;
- (IBAction) refresh:(id)sender;


@end
