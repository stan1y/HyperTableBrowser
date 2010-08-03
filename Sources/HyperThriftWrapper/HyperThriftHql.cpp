/*
 *  HyperThriftHql.cpp
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/15/09.
 *  Copyright 2009 AwesomeStanlyLabs. All rights reserved.
 *
 */

#include "HyperThriftHql.h"
#include "Hql_types.h"
#include "Client.h"
#include "Convert.h"

using namespace Hypertable::Thrift;
using namespace Hypertable::ThriftGen;

int create_hql_client(HTHRIFT_HQL * client,
					 const char* host,
					 const int port)
{
	try {
		HqlClient *pClient = new HqlClient(host, port);
		*client = pClient;
		return T_OK;
	}
	catch (TTransportException & ex) {
		printf("create_hql_client: exception: %s\n", ex.what());
		return T_ERR_TRANSPORT;
	}
}

void destroy_hql_client(HTHRIFT_HQL hThrift) 
{
	HqlClient *client = (HqlClient *)hThrift;
	delete client;
	client = NULL;
}

int hql_query(HTHRIFT_HQL hThrift, DataPage * page, const char * query)
{
	HqlClient *client = (HqlClient *)hThrift;
	try {
		HqlResult r;
		client->hql_query(r, std::string(query));
		
		std::vector<Cell>::iterator it = r.cells.begin();
		for (; it != r.cells.end(); it++) {
			DataRow * row = row_new(it->key.row.c_str());
			
			DataCell * cell_row = cell_new(NULL, NULL);
			DataCell * cell_family = cell_new(NULL, NULL);
			DataCell * cell_qualifier = cell_new(NULL, NULL);
			DataCell * cell_value = cell_new(NULL, NULL);
			DataCell * cell_revision = cell_new(NULL, NULL);
			
			char revisionValue[255];
			snprintf(revisionValue, 255, "%lld", it->key.revision);
			
			cell_set(cell_row, "row", "key", it->key.row.c_str(), it->key.revision);
			cell_set(cell_family, "column", "family", it->key.column_family.c_str(), it->key.revision);
			cell_set(cell_qualifier, "column", "qualifier", it->key.column_qualifier.c_str(), it->key.revision);
			cell_set(cell_value, "cell", "value", it->value.c_str(), it->key.revision);
			cell_set(cell_revision, "cell", "revision", revisionValue, it->key.revision);
			
			row_append(row, cell_row);
			row_append(row, cell_family);
			row_append(row, cell_qualifier);
			row_append(row, cell_value);
			row_append(row, cell_revision);
			page_append(page, row);
		}
		
		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("hql_query: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;
			
		}
		else {
			printf("hql_query: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & cl) {
		printf("hql_query: client exception: %s. %s\n", cl.what(), cl.message.c_str());
		return T_ERR_CLIENT;
	}
}
