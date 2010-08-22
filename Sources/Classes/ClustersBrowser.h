//
//  ClustersBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TablesBrowserSettings.h>
#import <ClustersBrowserSettings.h>
#import <UpdateSettings.h>

@interface ClustersBrowser : NSWindowController {

	NSTextField * statusMessageField;
	NSProgressIndicator * statusIndicator;
	
	NSMenuItem * newClusterMenuItem;
	NSPanel * newClusterPanel;
	
	NSTableView * membersTable;
}

@property (nonatomic, retain) IBOutlet NSTableView * membersTable;

@property (nonatomic, retain) IBOutlet NSTextField * statusMessageField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * statusIndicator;

@property (nonatomic, retain) IBOutlet NSMenuItem * newClusterMenuItem;
@property (nonatomic, retain) IBOutlet NSPanel * newClusterPanel;

//show status message on the bottom
- (void) setMessage:(NSString*)message;
//start operation indicator
- (void) indicateBusy;
//stop operation indicator
- (void) indicateDone;
//called when objects browser windows is about to close
- (void)windowWillClose:(NSNotification *)notification;
//show new cluster definion dialog
- (IBAction)showNewClusterDialog:(id)sender;
//update memebers when cluster is selected
- (IBAction)refresh:(id)sender;
- (IBAction)showTablesBrowser:(id)sender;
- (IBAction)showHqlInterpreter:(id)sender;
- (IBAction)showInspector:(id)sender;
- (IBAction)showUserGroupManager:(id)sender;
//show prefs window
- (IBAction)showPreferences:(id)sender;
- (IBAction)addServer:(id)sender;

@end
