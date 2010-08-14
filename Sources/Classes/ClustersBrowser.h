//
//  ClustersBrowser.h
//  Ore Foundry
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
}

@property (nonatomic, retain) IBOutlet NSTextField * statusMessageField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator * statusIndicator;

@property (nonatomic, retain) IBOutlet NSMenuItem * newClusterMenuItem;
@property (nonatomic, retain) IBOutlet NSPanel * newClusterPanel;

//show status message on the bottom
- (void)setMessage:(NSString*)message;

//start operation indicator
- (void) indicateBusy;

//stop operation indicator
- (void) indicateDone;

//called when objects browser windows is about to close
- (void)windowWillClose:(NSNotification *)notification;

//show new cluster definion dialog
- (IBAction)showNewClusterDialog:(id)sender;

@end
