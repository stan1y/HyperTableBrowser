//
//  ServersDelegate.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjectsPageSource.h>
#import <HyperTableServer.h>
#import <ConnectionSheetController.h>
#import <ToolBarController.h>

@interface ServersDelegate : NSObject {
	ObjectsPageSource * objectsPageSource;
	NSString * selectedServer;
	ConnectionSheetController * connectionController;
}

@property(assign) IBOutlet ObjectsPageSource * objectsPageSource;
@property(assign) IBOutlet ConnectionSheetController * connectionController;
@property(readonly) NSString * selectedServer;

@end
