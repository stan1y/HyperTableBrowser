//
//  Service.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Service : NSManagedObject {
	
}

+ (NSEntityDescription *) serviceDescription;
- (id) runsOnServer;

@end
