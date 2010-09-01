/*
 *  TestWrapper.c
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/12/09.
 *  Copyright 2009 Stanislav Yudin. All rights reserved.
 *
 */

#include <stdio.h>
#include "HyperThriftWrapper.h"
#include "HyperThriftHql.h"

int main(int argc, char *argv[])
{
    HTHRIFT th;
	int rc = create_thrift_client(&th, "localhost", 38080);
	if (rc != 0 || th == 0){
		printf("error! not connected! rc=%d\n", rc);
		return 1;
	}
	
	HTHRIFT_HQL th_hql;
	rc = create_hql_client(&th_hql, "localhost", 38080);
	if (rc != 0 || th_hql == 0){
		printf("error! not connected! rc=%d\n", rc);
		return 1;
	}
	
	struct WrappedPage * page = (struct WrappedPage*)malloc(sizeof(struct WrappedPage));
	struct WrappedKeys * keys = (struct WrappedKeys*)malloc(sizeof(struct WrappedKeys));
	struct WrappedStringList * tables = (struct WrappedStringList*)malloc(sizeof(struct WrappedStringList));
	
	//get tables
	rc = get_tables_list(th, tables);
	
	if (rc != T_OK) {
		printf("failed to get tables\n");
		return 1;
	}
	
	//get keys of table (not first one - METADATA)
	if (tables->clinesCount > 1) {
		rc = get_keys(th, keys, tables->clines[1]);
		if (rc != T_OK) {
			printf("failed to get keys of table %s\n", tables->clines[1]);
			return 1;
		}
		
		if (keys->keysCount < 5) {
			printf("only %d < 5 keys found for table %s\n", keys->keysCount, tables->clines[1]);
			return 1;
		}
		
		//get page with keys
		memset(page->firstRowId, 0, MAX_KEY);
		memset(page->lastRowId, 0, MAX_KEY);
		
		//get first 5 items
		strncpy(page->lastRowId, keys->keysArray[4], MAX_KEY);
		
		rc = get_objects(th, page, tables->clines[1]);
		if (rc != T_OK) {
			printf("failed to get objects.\n");
			return 1;
		}
		
		printf("returned %d rows.\n", page->rowsCount);
		return 0;
	}
	else {
		printf("only one table in server.\n");
		return 0;
	}
}