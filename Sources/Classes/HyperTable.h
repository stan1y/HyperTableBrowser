//
//  HyperTable.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 16/2/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface HyperTable : NSManagedObject {
	
}

+ (HyperTable *)tableWithDefaultContext;
+ (NSEntityDescription *) entityDescription;
@end