//
//  ClustersBrowser.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cluster.h"
#import "Server.h"
#import "ModalDialog.h"
#import "Inspector.h"

@interface ClustersBrowser : NSWindowController {
	ModalDialog * newServerOrClusterDialog;
	Inspector * inspector;

	NSTableView * membersTable;
	NSPopUpButton * clustersSelector;
	
	int selectedServerIndex;
}

@property (nonatomic, retain) IBOutlet Inspector * inspector;

// New Cluster or Server dialog

@property (nonatomic, retain) IBOutlet ModalDialog * newServerOrClusterDialog;

// UI Outlets

@property (nonatomic, retain) IBOutlet NSPopUpButton * clustersSelector;
@property (nonatomic, retain) IBOutlet NSTableView * membersTable;

@property (nonatomic, retain) IBOutlet NSTextField * statusMessageField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * statusIndicator;

// Selections

- (Server<ClusterMember> *) selectedServer;
- (Cluster *) selectedCluster;
- (IBAction) clusterSelectionChanged:(id)sender;

- (void) refreshClustersList;
- (void) refreshMembersList;

// Singleton

+ (ClustersBrowser *) sharedInstance;

// Toolbar Callbacks

- (IBAction) updateCluster:(id)sender;
- (IBAction) updateCurrentServer:(id)sender;

- (IBAction) addServer:(id)sender;
- (IBAction) defineNewCluster:(id)sender;


@end
