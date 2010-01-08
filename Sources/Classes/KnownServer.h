//
//  KnownServer.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KnownServer : NSManagedObject {

}

+ (KnownServer *)knownServerWithDefaultContext;

@end
