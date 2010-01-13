//
//  CoreDataObjects.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 12/23/09.
//  Copyright 2009 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define SRV_CLASS "Server"
#define TBL_CLASS "Table"

@interface Server : NSManagedObject {

}

+ (Server *)serverWithDefaultContext;
+ (NSEntityDescription *) entityDescription;
@end

@interface Table : NSManagedObject {
	
}

+ (Table *)tableWithDefaultContext;
+ (NSEntityDescription *) entityDescription;
@end