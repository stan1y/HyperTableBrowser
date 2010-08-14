//
//  ClustersBrowserToolbarController.h
//  Ore Foundry
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MBPreferencesController.h>
#import <ClustersBrowser.h>

@interface ClustersBrowserToolbarController : NSObject {
	ClustersBrowser * clustersBrowser;
}

@property (nonatomic, retain) IBOutlet ClustersBrowser * clustersBrowser;

- (IBAction)showTablesBrowser:(id)sender;
- (IBAction)showHqlInterpreter:(id)sender;
- (IBAction)showInspector:(id)sender;
- (IBAction)showUserGroupManager:(id)sender;

- (IBAction)showPreferences:(id)sender;

- (IBAction)refresh:(id)sender;
- (IBAction)addServer:(id)sender;

@end
