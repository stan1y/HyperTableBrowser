/*
 *  Convert.h
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/15/09.
 *  Copyright 2009 K7 Computing. All rights reserved.
 *
 */

#include <string>
#include <vector>
#include <DataPage.h>
#include "Hql_types.h"
#include "Client.h"

using namespace Hypertable::Thrift;
using namespace Hypertable::ThriftGen;

//utility functions
void convert_row(DataPage * page, std::vector<Cell> cells);
void convert_lines(DataRow * row, std::vector<std::string> lines);