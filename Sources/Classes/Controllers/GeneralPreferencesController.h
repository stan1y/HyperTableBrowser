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

@property (nonatomic, retain) IBOutlet NSButton * autoReconnectServer;
@property (nonatomic, retain) IBOutlet NSButton * skipMetadata;
@property (nonatomic, retain) IBOutlet NSButton * showTablesCount;

- (IBAction)switchCheckBox:(id)sender;
- (NSString *)identifier;
- (NSImage *)image;

@end
