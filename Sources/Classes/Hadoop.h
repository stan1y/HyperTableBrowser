//
//  Hadoop.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 23/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"

// Hadoop services controller supposed to be 
// a base class for HyperTable. But its not
// implemented at all. Still some day...
@interface Hadoop : Server {

}

+ (NSEntityDescription *) hadoopDescription;

@end
