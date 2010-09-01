//
//  Inspector.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 21/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Inspector : NSWindowController {
	
	// Editable
	NSTextField * objectTitle;
	NSTextField * sshUserName;
	NSTextField * ipAddressAndSshPort;
	NSTextField * comments;
	
	// Static
	NSTextField * status;
	NSTextField * healthPercentage;
	NSTextField * hostname;
	NSTextField * dfsProvider;
	NSLevelIndicator * healthBar; 
	
	int selectedServiceIndex;
	
	// Static values for combos
	NSArray * serviceRunningValues;
	NSArray * serviceStoppedValues;
	
	// Services in pending mode cache
	NSLock * pendingServicesLock;
	NSMutableArray * pendingServiceIndexes;
	
	// Service list 
	NSTableView * servicesTable;
}
@property (nonatomic, retain) IBOutlet NSTextField * objectTitle;
@property (nonatomic, retain) IBOutlet NSTextField * sshUserName;
@property (nonatomic, retain) IBOutlet NSTextField * ipAddressAndSshPort;
@property (nonatomic, retain) IBOutlet NSTextField * comments;

@property (nonatomic, retain) IBOutlet NSTextField * status;
@property (nonatomic, retain) IBOutlet NSTextField * dfsProvider;
@property (nonatomic, retain) IBOutlet NSTextField * hostname;
@property (nonatomic, retain) IBOutlet NSTextField * healthPercentage;
@property (nonatomic, retain) IBOutlet NSLevelIndicator * healthBar;

@property (nonatomic, retain) IBOutlet NSTableView * servicesTable;

- (IBAction) operateService:(id)sender;
- (IBAction) closeInspector:(id)sender;
- (IBAction) refresh:(id)sender;

// modification of properties of current server
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;

@end
