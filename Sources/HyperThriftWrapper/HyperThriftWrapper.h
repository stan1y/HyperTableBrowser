/*
 *  HyperThriftWrapper.h
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/08/09.
 *  Copyright 2009 Stanislav Yudin. All rights reserved.
 *
 */

#ifndef HYPER_THRIFT_WRAPPER_H
#define HYPER_THRIFT_WRAPPER_H

//thrift connection client
typedef void* HTHRIFT;

#include "DataPage.h"

#define T_OK 0
#define T_ERR_NODATA -1
#define T_ERR_TRANSPORT -2
#define T_ERR_CLIENT -3
#define T_ERR_TIMEOUT -4
#define T_ERR_APPLICATION -5

#ifdef __cplusplus
extern "C" {
#endif

	/* Initialization */
		
	//initialize connection to thrift
	int create_thrift_client(HTHRIFT * client,
							  const char* host,
							  const int port);	
	//close connection
	void destroy_thrift_client(HTHRIFT client);

	//returns list of objects tables
	int get_tables_list(HTHRIFT hThrift, DataRow * row);

	/* Get data */
		
	//returns list of all keys in objects, used to build paging information
	int get_keys(HTHRIFT hThrift, DataRow * keys, const char * tableName);
		
	//returns page(from firstKey to lastKey) of objects from table.
	int get_page(HTHRIFT hThrift, DataPage * page, const char * tableName,
					const char * startKey,
					const char * endKey);
	
	//returns row with specified key
	int get_row(HTHRIFT hThrift, DataRow * row, const char * tableName,
				const char * rowKey);

	/* Set Data */
	
	//writes cells/rows from page according to row's keys and cells' family & qualified
	int set_page(HTHRIFT hThrift, DataPage * page, const char * tableName);
	
	//writes cells from row
	int set_row(HTHRIFT hThrift, DataRow * row, const char * tableName);
	
	//fetches cells with rowKey and drops delete them
	int delete_row_by_key(HTHRIFT hThrift, const char * rowKey, const char * tableName);
	
	//drops all cells in row
	int delete_row(HTHRIFT hThrift, DataRow * row, const char * tableName);
	
	//creates new table with specified name and schema
	int new_table(HTHRIFT hThrift, const char * name, const char * schema);

	//drops table by name
	int drop_table(HTHRIFT hThrift, const char * name);
	
#ifdef __cplusplus
}
#endif

#endif //THRIFT_WRAPPER_H
