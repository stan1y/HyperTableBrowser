//
//  SettingsManager.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreDataManager.h>

@interface SettingsManager : CoreDataManager {

}

- (id) getSettingsByName:(NSString *)name;
- (SettingsManager *) init;

@end
