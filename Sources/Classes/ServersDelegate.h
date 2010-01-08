//
//  ServersDelegate.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjectsPageSource.h>

@interface ServersDelegate : NSObject {
	ObjectsPageSource * objectsPageSource;
	NSArrayController * knownServersController;
	NSString * selectedServer;
}

@property(assign) IBOutlet NSArrayController * knownServersController;
@property(assign) IBOutlet ObjectsPageSource * objectsPageSource;
@property(readonly) NSString * selectedServer;

@end
