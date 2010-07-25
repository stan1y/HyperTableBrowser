/*
 *  TestThriftGen.cpp
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/12/09.
 *  Copyright 2009 AwesomeStanlyLabs. All rights reserved.
 *
 */

#include "Client.h"
#include "Hql_types.h"
#include <transport/TTransportException.h>

using namespace Hypertable::Thrift;
using namespace Hypertable::ThriftGen;
using namespace apache::thrift::transport;

int main(int argc, char *argv[])
{
	try {
		//printf("table: %s\n", argv[1]);
		
		//std::string table = std::string(argv[1]);
		std::string table = std::string("rms_app_RmsUser");
		
		Client * client = new Client("localhost", 38080);
		
		//first get keys
		ScanSpec keysSpec;
		keysSpec.keys_only = true;
		keysSpec.__isset.keys_only = true;
		
		Scanner scaner = client->open_scanner(table, keysSpec, false);
		std::vector<std::string> keys;
		std::vector<Cell> cells;
		do {
			client->next_row(cells, scaner);
			//convert row to wrapped types
			if ( cells.size() > 0 ) {
				keys.push_back(cells[0].row_key);
			}
			
		} while (cells.size() > 0);
		client->close_scanner(scaner);
		
		if (keys.size() < 15) {
			printf("too small table.\n");
			return 1;
		}
		
		//now get from 5 till 15 object
		ScanSpec spec;
		RowInterval r;
		
		r.start_row = keys[4];
		r.start_inclusive = true;
		r.__isset.start_row = true;
		r.__isset.start_inclusive = true;
		
		r.end_row = keys[14];
		r.end_inclusive = true;
		r.__isset.end_row = true;
		r.__isset.end_inclusive = true;
		
		spec.row_intervals.push_back(r);
		spec.__isset.row_intervals = true;
		
		Scanner scaner1 = client->open_scanner(table, spec, false);
		std::vector<Cell> newCells;
		do {
			cells.clear();
			client->next_row(cells, scaner1);
			
			if ( cells.size() > 0 ) {
				for (int i=0; i<cells.size(); i++) {
					printf("[%d] - (%s)\t%s:%s\t\"%s\"\n",
						   i, 
						   cells[i].row_key.c_str(),
						   cells[i].column_family.c_str(),
						   cells[i].column_qualifier.c_str(),
						   cells[i].value.c_str());
					
					Cell c;
					c.column_family = cells[i].column_family;
					c.column_qualifier = cells[i].column_qualifier;
					c.value = "TestValue";
					c.row_key = cells[i].row_key;
					printf("row %s\n", c.row_key.c_str());
					newCells.push_back(c);
					
				}
			}
			
		} while (cells.size() > 0);
		client->close_scanner(scaner1);
		
		
		Mutator m = client->open_mutator(table, 0, 0);
		client->set_cells(m, newCells);
		client->close_mutator(m, true);

		return 0;
	}
	catch (ClientException & ex) {
		printf("client exception: %s\n", ex.message.c_str());
		return 1;
	}
	catch (TTransportException & ex) {
		printf("exception: %s\n", ex.what());
		return 1;
	}
}
