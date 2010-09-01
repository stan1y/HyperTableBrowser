/*
 *  HyperThriftHql.h
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/15/09.
 *  Copyright 2009 Stanislav Yudin. All rights reserved.
 *
 */

#ifndef HYPER_THRIFT_HQL_WRAPPER_H
#define HYPER_THRIFT_HQL_WRAPPER_H

#include "HyperThriftWrapper.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef void* HTHRIFT_HQL;

//initialize connection to thrift
int create_hql_client(HTHRIFT_HQL * client,
						 const char* host,
						 const int port);	
//close connection
void destroy_hql_client(HTHRIFT_HQL client);

//returns page resulted in hql query execution
int hql_query(HTHRIFT_HQL hThrift, DataPage * page, const char * query);

#ifdef __cplusplus
}
#endif
	
#endif