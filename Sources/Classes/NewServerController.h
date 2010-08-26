//
//  NewServerController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cluster.h"

@interface NewServerController : NSViewController {
	//UI properties
	NSTextField * dialogTitle;
	NSTextField * errorMessage;
	
	//Server properties
	NSTextField * name;
	NSTextField * ipAddress;
	NSTextField * sshPort;
	NSTextField * userName;
	NSTextField * privateKeyPath;
	
	Cluster * cluster;
}

@property (nonatomic, retain) Cluster * cluster;

@property (nonatomic, retain) IBOutlet NSTextField * errorMessage;
@property (nonatomic, retain) IBOutlet NSTextField * dialogTitle;

@property (nonatomic, retain) IBOutlet NSTextField * name;
@property (nonatomic, retain) IBOutlet NSTextField * ipAddress;
@property (nonatomic, retain) IBOutlet NSTextField * sshPort;
@property (nonatomic, retain) IBOutlet NSTextField * userName;
@property (nonatomic, retain) IBOutlet NSTextField * privateKeyPath;


- (IBAction) saveServer:(id)sender;
- (IBAction) cancel:(id)sender;

- (void) modeAddToCluser:(Cluster *)cluster;
- (void) modeCreateNewCluser;

@end
