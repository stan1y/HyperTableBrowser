//
//  HyperTable.h
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 9/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Hadoop.h>
#import <HyperThriftWrapper.h>
#import <HyperThriftHql.h>

@interface HyperTable : Hadoop {
	NSString * hypertableConfContent;
	
	HTHRIFT thriftClient;
	HTHRIFT_HQL hqlClient;
	
	NSMutableArray * tables;
	
	NSLock * connectionLock;
}

@property (nonatomic, retain) NSLock * connectionLock;
@property (nonatomic, retain) NSArray * tables;

@property (assign) HTHRIFT thriftClient;
@property (assign) HTHRIFT_HQL hqlClient;

//initialization
+ (NSEntityDescription *) hypertableDescription;
+ (NSEntityDescription *) tableSchemaDescription;

//enumeration
+ (NSArray *) allHypertables;

//sync operation
- (void) disconnect;
- (BOOL) isConnected;

//async operations
- (void) reconnect:(void (^)(void)) codeBlock;
- (void) refresh:(void (^)(void)) codeBlock;

//table schemas
+ (NSArray *)listSchemes;
+ (NSManagedObject *)getSchemaByName:(NSString *)name;
- (NSArray *) describeColumns:(NSManagedObject *)schema;

//error code to error message
+ (NSString *)errorFromCode:(int)code;
@end
