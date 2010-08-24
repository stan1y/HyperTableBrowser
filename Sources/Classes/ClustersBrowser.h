//
//  ClustersBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Cluster.h>
#import <Server.h>
#import <TablesBrowserSettings.h>
#import <ClustersBrowserSettings.h>
#import <UpdateSettings.h>

@interface ClustersBrowser : NSWindowController {

	NSTextField * statusMessageField;
	NSProgressIndicator * statusIndicator;
	
	NSMenuItem * newClusterMenuItem;
	NSPanel * newClusterPanel;
	
	NSTableView * membersTable;
	NSPopUpButton * clustersSelector;

	int selectedClusterIndex;
	Cluster * selectedCluster;
	
	int selectedServerIndex;
	Server * selectedServer;
}

// Selection properties

@property (readonly) int selectedServerIndex;
@property (nonatomic, retain) Server * selectedServer;
@property (readonly) int selectedClusterIndex;
@property (nonatomic, retain) Cluster * selectedCluster;

// UI Outlets

@property (nonatomic, retain) IBOutlet NSPopUpButton * clustersSelector;
@property (nonatomic, retain) IBOutlet NSTableView * membersTable;

@property (nonatomic, retain) IBOutlet NSTextField * statusMessageField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * statusIndicator;

@property (nonatomic, retain) IBOutlet NSMenuItem * newClusterMenuItem;
@property (nonatomic, retain) IBOutlet NSPanel * newClusterPanel;

// Activity indication

- (void) setMessage:(NSString*)message;
- (void) indicateBusy;
- (void) indicateDone;

// Clusters Windows Callbacks

- (BOOL) windowShouldClose:(id)sender;
- (void) windowWillClose:(NSNotification *)notification;

// Toolbar Callbacks

- (IBAction) refresh:(id)sender;
- (IBAction) showInspector:(id)sender;
- (IBAction) addServer:(id)sender;

// Servers table callbacks

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification;

@end
