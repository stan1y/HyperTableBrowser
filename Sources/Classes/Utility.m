//
//  Utility.m
//  HyperTableBrowser
//
//  Created by Stanislav Yudin on 22/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import "Utility.h"

@implementation StatusValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value 
{
	int intStatus = [value intValue];
	NSString * status;
	
	switch (intStatus) {
		case 0:
			status = @"Operational";
			break;
		case 1:
			status = @"Error";
			break;
		default:
			status = @"Pending...";
			break;
	}
	
	return status;
}

@end

