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
	
}

- (NSString *)identifier;
- (NSImage *)image;

@end
