//
//  SSHTool.m
//  Ore Foundry
//
//  Created by Stanislav Yudin on 15/8/2010.
//  Copyright 2010 AwesomeStanly Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSHClient.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString * hostname = nil;
	NSString * username = nil;
	NSString * cmd = nil;
	
	if (argc < 4) {
		char hostnameRaw[255];
		char usernameRaw[255];
		char cmdRaw[255];
		
		printf("Hostname:");
		scanf("%s", &hostnameRaw);
		printf("Username:");
		scanf("%s", &usernameRaw);
		printf("Command:");
		scanf("%s", &cmdRaw);
		
		hostname = [NSString stringWithCString:hostnameRaw];
		username = [NSString stringWithCString:usernameRaw];
		cmd = [NSString stringWithCString:cmdRaw];
	}
	else {
		NSLog(@"Hostname: %s", argv[1]);
		NSLog(@"Username: %s", argv[2]);
		NSLog(@"Command: \"%s\"", argv[3]);
		
		hostname = [NSString stringWithCString:argv[1]];
		username = [NSString stringWithCString:argv[2]];
		cmd = [NSString stringWithCString:argv[3]];
	}
	
	SSHClient * client = [[SSHClient alloc] initClientTo:hostname 
												  onPort:22 
												  asUser:username];
	int rc = [client runCommand:cmd];
	NSLog(@"Code: %d", rc);
	
	if (rc) {
		NSLog(@"Error:\n%s", [[client error] UTF8String]);
	}
	else {
		NSLog(@"Output:\n%s", [[client output] UTF8String]);
	}
	
	[client release];
	[pool release];

	return rc;
}
