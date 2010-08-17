//
//  ClustersBrowserSettings.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 11/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface ClustersBrowserSettings : NSViewController <MBPreferencesModule> {
	
}

- (NSString *)identifier;
- (NSImage *)image;

@end
