/*
 *  HyperThriftHql.cpp
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/15/09.
 *  Copyright 2009 K7 Computing. All rights reserved.
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
		int rowIndex = 0;
		if (r.cells.size() > 0) {
			std::string current_row_key = r.cells[0].row_key;
			std::vector<Cell> cells_row;
			int index = 0;
			//append first cell
			cells_row.push_back(r.cells[index]);
			while (true) {
				index++;
				//results end reached
				if (index == r.cells.size()) {
					if (cells_row.size()) {
						//first row is the last
						convert_row(page, cells_row);
						rowIndex++;
					}
					break;
				}
				//next row reached
				if (r.cells[index].row_key != current_row_key) {
					convert_row(page, cells_row);
					current_row_key = r.cells[index].row_key;
					rowIndex++;
					cells_row.clear();
					//append as first cell of new row
					cells_row.push_back(r.cells[index]);
				}
				else {
					//append cell to row
					cells_row.push_back(r.cells[index]);
				}
			}
			
			if (page->rowsCount > 0) {
				return T_OK;
			}else {
				printf("failed to convert? cells.size() > 0!\n");
				return T_ERR_NODATA;
			}
		}
		else {
			return T_ERR_NODATA;
		}

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
		printf("hql_query: client exception: %s\n", cl.what());
		return T_ERR_CLIENT;
	}
}