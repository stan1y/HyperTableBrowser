//
//  GeneralPreferencesController.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 30/3/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface GeneralPreferencesController : NSViewController <MBPreferencesModule> {
	NSButton * autoReconnectServer;
	NSButton * skipMetadata;
	NSButton * showTablesCount;
}

@property (assign) IBOutlet NSButton * autoReconnectServer;
@property (assign) IBOutlet NSButton * skipMetadata;
@property (assign) IBOutlet NSButton * showTablesCount;

- (IBAction)switchCheckBox:(id)sender;
- (NSString *)identifier;
- (NSImage *)image;

@end
