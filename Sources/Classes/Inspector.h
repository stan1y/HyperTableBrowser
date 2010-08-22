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
	NSTextField * hostname;
	NSLevelIndicator * healthBar; 
	NSTextField * comments;
	
	int selectedServiceIndex;
	
	NSImage * runningImage;
	NSImage * stoppedImage;
}

@property (nonatomic, retain) IBOutlet NSTextField * objectTitle;
@property (nonatomic, retain) IBOutlet NSTextField * healthPercentage;
@property (nonatomic, retain) IBOutlet NSLevelIndicator * healthBar;
@property (nonatomic, retain) IBOutlet NSTextField * hostname;
@property (nonatomic, retain) IBOutlet NSTextField * comments;


- (IBAction) operateService:(id)sender;
- (IBAction) closeInspector:(id)sender;
- (IBAction) refresh:(id)sender;

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context;

// tableview datasource for services list
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex;

// tableview delegate selection of service in table
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end
