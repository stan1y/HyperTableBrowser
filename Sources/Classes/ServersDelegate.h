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
	NSString * selectedTable;
	ConnectionSheetController * connectionController;
}

@property(nonatomic, retain) IBOutlet ObjectsPageSource * objectsPageSource;
@property(nonatomic, retain) IBOutlet ConnectionSheetController * connectionController;
@property(nonatomic, retain) NSString * selectedServer;
@property(nonatomic, retain) NSString * selectedTable;

@end
