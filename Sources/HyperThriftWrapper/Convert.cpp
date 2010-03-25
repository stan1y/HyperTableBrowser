/*
 *  Convert.cpp
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/15/09.
 *  Copyright 2009 K7 Computing. All rights reserved.
 *
 */

#include "Convert.h"
#include <stdio.h>
#include <stdlib.h>

void convert_row(DataPage * page, std::vector<Cell> cells)
{
	if (cells.size() <= 0) {
		return;
	}
	
	DataRow * row = row_new(cells[0].row_key.c_str());
	
	//add revision cell
	char str_revision[255];
	snprintf(str_revision, 255, "%d\0", cells[0].revision);
	DataCell * cell = cell_new(NULL, NULL);
	cell_set(cell, "app", "revision", str_revision);
	row_append(row, cell);
	
	std::vector<Hypertable::ThriftGen::Cell>::iterator it = cells.begin();
	int index = 1;
	for (; it != cells.end(); it++) {
		DataCell * cell = cell_new(NULL, NULL);
		cell_set(cell, it->column_family.c_str(),
				 it->column_qualifier.c_str(),
				 it->value.c_str());
		row_append(row, cell);
		index++;
	}
	
	//add row
	page_append(page, row);
}

void convert_lines(DataRow * row, std::vector<std::string> lines)
{
	std::vector<std::string>::iterator it = lines.begin();
	for (; it != lines.end(); it++) {
		DataCell * cell = cell_new(NULL, NULL);
		cell_set(cell, "", "", it->c_str());
		row_append(row, cell);
	}
}
