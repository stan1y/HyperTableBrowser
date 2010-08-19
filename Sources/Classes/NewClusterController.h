//
//  NewClusterController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 10/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ClustersBrowser.h>
#import <GetStatusOperation.h>

@interface NewClusterController : NSViewController {
	NSTextField * errorMessage;
	
	NSTextField * clusterName;
	NSTextField * masterAddress;
	NSTextField * sshPort;
	NSTextField * userName;
	NSTextField * privateKeyPath;
	
	NSTextField * hypertableBroker;
	NSTextField * hadoopBroker;
}
@property (nonatomic, retain) IBOutlet NSTextField * errorMessage;

@property (nonatomic, retain) IBOutlet NSTextField * clusterName;
@property (nonatomic, retain) IBOutlet NSTextField * masterAddress;
@property (nonatomic, retain) IBOutlet NSTextField * sshPort;
@property (nonatomic, retain) IBOutlet NSTextField * userName;
@property (nonatomic, retain) IBOutlet NSTextField * privateKeyPath;

@property (nonatomic, retain) IBOutlet NSTextField * hypertableBroker;
@property (nonatomic, retain) IBOutlet NSTextField * hadoopBroker;

- (IBAction) saveCluster:(id)sender;
- (IBAction) cancel:(id)sender;

@end
