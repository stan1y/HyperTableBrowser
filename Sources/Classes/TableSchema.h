//
//  TableSchema.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 25/7/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableSchema : NSManagedObject {
}

+ (NSArray *)listSchemes;
+ (TableSchema *)getSchemaByName:(NSString *)name;

- (NSArray *) describeColumns;

@end