/*
 *  HyperThriftWrapper.c
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/08/09.
 *  Copyright 2009 K7 Computing. All rights reserved.
 *
 */


#include "HyperThriftWrapper.h"
#include "Hql_types.h"
#include "Client.h"
#include "Convert.h"

using namespace Hypertable::Thrift;
using namespace Hypertable::ThriftGen;

int create_thrift_client(HTHRIFT * client,
						 const char* host,
						 const int port)
{
	try {
		Client *pClient = new Client(host, port);
		*client = pClient;
		return T_OK;
	}
	catch (TTransportException & ex) {
		printf("create_thrift_client: exception: %s\n", ex.what());
		return T_ERR_TRANSPORT;
	}
}

void destroy_thrift_client(HTHRIFT hThrift)
{
	Client *client = (Client *)hThrift;
	delete client;
	client = NULL;
}

int get_tables_list(HTHRIFT hThrift, DataRow * row)
{
	try {		
		Client *client = (Client*)hThrift;
		ScanSpec spec;
		
		std::vector<std::string> tables;
		client->get_tables(tables);
		
		if (tables.size() > 0) {
			convert_lines(row, tables);
			return T_OK;
		}
		else {
			printf("get_tables_list: error: tables list can't be empty. METADATA missing.");
			return T_ERR_NODATA;
		}

	}
	catch (TTransportException & ex) {
		printf("get_tables_list: exception: %s\n", ex.what());
		return T_ERR_TRANSPORT;
	}
	catch (ClientException & ex) {
		printf("get_tables_list: client exception: %s\n", ex.what());
		return T_ERR_CLIENT;
	}
}

int get_keys(HTHRIFT hThrift, DataRow * keys, const char * objectTypeId)
{
	try {
		Client *client = (Client*)hThrift;
		ScanSpec spec;
		
		//set empty columns and mark specified
		spec.keys_only = true;
		spec.__isset.keys_only = true;
		
		Scanner scaner = client->open_scanner(std::string(objectTypeId), spec, false);
		
		//read rows
		std::vector<Cell> cells;
		do {
			
			cells.clear();
			client->next_row(cells, scaner);
			//convert row to wrapped types
			if ( cells.size() > 0 ) {
				DataCell * newKey = cell_new(NULL, NULL);
				cell_set(newKey, "", "", cells[0].row_key.c_str());
				row_append(keys, newKey);
			}
			
		} while (cells.size() > 0);
		client->close_scanner(scaner);
		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("get_keys: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;

		}
		else {
			printf("get_keys: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & ex) {
		printf("get_keys: client exception: %s\n", ex.what());
		return T_ERR_CLIENT;
	}
	
}

int get_page(HTHRIFT hThrift, DataPage * page, const char * objectTypeId,
				const char * startKey,
				const char * endKey)
{
	try {
		Client *client = (Client*)hThrift;
		ScanSpec spec;
		
		if (endKey != NULL && strlen(endKey)) {
			RowInterval r;
			//finish scan by lastRow
			r.end_row = std::string(endKey);
			r.end_inclusive = true;
			r.__isset.end_row = true;
			r.__isset.end_inclusive = true;
			//start scan by firstRow if specified
			if (startKey != NULL && strlen(startKey)) {
				r.start_row = std::string(startKey);
				r.start_inclusive = true;
				r.__isset.start_row = true;
				r.__isset.start_inclusive = true;
			}
			spec.row_intervals.push_back(r);
			spec.__isset.row_intervals = true;
		}
		
		spec.revs = 1;
		spec.__isset.revs = true;
		
		Scanner scaner = client->open_scanner(std::string(objectTypeId), spec, false);
		
		//read rows
		int index = 0;
		std::vector<Cell> cells;
		do {
			
			cells.clear();
			client->next_row(cells, scaner);
			//convert row to wrapped types
			if ( cells.size() > 0 ) {
				convert_row(page, cells);
				index++;
			}
			
		} while (cells.size() > 0);		
		client->close_scanner(scaner);

		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("get_objects: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;
			
		}
		else {
			printf("get_objects: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & ex) {
		printf("get_objects: client exception: %s\n", ex.what());
		return T_ERR_CLIENT;
	}
}

//returns row with specified key
int get_row(HTHRIFT hThrift, DataRow * row, const char * objectTypeId,
			const char * rowKey)
{
	try {
		Client *client = (Client*)hThrift;
		std::vector<Cell> cells;
		//void get_row(std::vector<Cell> & _return, const std::string& name, const std::string& row);
		client->get_row(cells, std::string(objectTypeId), std::string(rowKey));
		row = row_new(rowKey);
		if (cells.size() > 0) {
			for (int i=0; i<cells.size(); i++) {
				DataCell * dcell = cell_new(NULL, NULL);
				cell_set(dcell, cells[i].column_family.c_str(), 
						 cells[i].column_qualifier.c_str(),
						 cells[i].value.c_str());
				row_append(row, dcell);
			}
		}
		
		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("get_objects: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;
			
		}
		else {
			printf("get_objects: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & ex) {
		printf("get_objects: client exception: %s\n", ex.what());
		return T_ERR_CLIENT;
	}
}


/* Set Data */

//writes cells/rows from page according to row's keys and cells' family & qualified
int set_page(HTHRIFT hThrift, DataPage * page, const char * objectTypeId)
{
	try {
		Client *client = (Client*)hThrift;		
		Mutator m = client->open_mutator(objectTypeId, 0, 0);
		std::vector<Cell> cells;
		
		//populating cells vector row by row
		DataRowIterator * i = row_iter_new(page);
		DataRow * row = NULL;
		do {
			row = row_iter_next_row(i);
			if (row) {
				//populate with row
				DataCellIterator * ci = cell_iter_new(row);
				DataCell * cell = NULL;
				do {
					cell = cell_iter_next_cell(ci);
					if (cell) {
						Cell c;
						//set values
						c.column_family = std::string(cell->cellColumnFamily);
						c.column_qualifier = std::string(cell->cellColumnQualifier);
						c.value = std::string(cell->cellValue);
						c.row_key = std::string(row->rowKey);
						//set flags
						c.__isset.column_family = true;
						c.__isset.column_qualifier = true;
						c.__isset.value = true;
						c.__isset.row_key = true;					
					}
				} while (cell);
				free(ci);
			}
		} while (row);
		free(i);
		//submit
		client->set_cells(m, cells);
		client->close_mutator(m, true);
		
		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("set_page: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;
			
		}
		else {
			printf("set_page: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & ex) {
		printf("set_page: client exception: %s\n", ex.what());
		return T_ERR_CLIENT;
	}
}

//writes cells from row
int set_row(HTHRIFT hThrift, DataRow * row, const char * objectTypeId)
{
	try {
		Client *client = (Client*)hThrift;
		std::string id = std::string(objectTypeId);
		Mutator m = client->open_mutator(id, 0, 0);
		std::vector<Cell> cells;
		
		//populating cells vector
		//populate with row
		DataCellIterator * ci = cell_iter_new(row);
		DataCell * cell = NULL;
		do {
			cell = cell_iter_next_cell(ci);
			if (cell) {
				Cell c;
				//set values
				c.column_family = std::string(cell->cellColumnFamily);
				c.column_qualifier = std::string(cell->cellColumnQualifier);
				c.value = std::string(cell->cellValue);
				c.row_key = std::string(row->rowKey);
				//set flags
				c.__isset.column_family = true;
				c.__isset.column_qualifier = true;
				c.__isset.value = true;
				c.__isset.row_key = true;
				
				cells.push_back(c);
			}
		} while (cell);
		free(ci);
		
		client->set_cells(m, cells);
		client->close_mutator(m, true);
		
		return T_OK;
	}
	catch (TTransportException & ex) {
		if (strstr(ex.what(), "EAGAIN")) {
			printf("set_row: timeout: %s\n", ex.what());
			return T_ERR_TIMEOUT;
			
		}
		else {
			printf("set_row: exception: %s\n", ex.what());
			return T_ERR_TRANSPORT;
		}
	}
	catch (ClientException & ex) {
		printf("set_row: client exception: %s\n", ex.message.c_str());
		return T_ERR_CLIENT;
	}
}

