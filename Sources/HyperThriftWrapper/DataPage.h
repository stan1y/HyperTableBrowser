/*
 *  DataPage.h
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/17/09.
 *  Copyright 2009 K7 Computing. All rights reserved.
 *
 */

#ifndef HYPER_THRIFT_WRAPPER_DATA_PAGE_H
#define HYPER_THRIFT_WRAPPER_DATA_PAGE_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif	

typedef struct _DataCell {
	//cell data
	char * cellColumnFamily;
	int cellColumnFamilySize;
	char * cellColumnQualifier;
	int cellColumnQualifierSize;
	char * cellValue;
	int cellValueSize;
	
	//cells list
	void * nextCell;
	void * prevCell;
} DataCell;

typedef struct _DataRow {
	//row key
	char * rowKey;
	int rowKeySize;
	
	//cells list head & tail
	DataCell * cellsHead;
	DataCell * cellsTail;
	int cellsCount;
	
	//rows list
	void * prevRow;
	void * nextRow;
} DataRow;

typedef struct {
	DataRow * row;
	DataCell * currentCell;
} DataCellIterator;

typedef struct {
	//rows list head & tail
	DataRow * rowsHead;
	DataRow * rowsTail;
	int rowsCount;
} DataPage;

typedef struct {
	DataPage * page;
	DataRow * currentRow;
} DataRowIterator;
		
//DataCell

//create new data cell
DataCell * cell_new(DataCell * prev, DataCell * next);
//set cell values
void cell_set(DataCell * cell,
			  const char * family, 
			  const char * qualifier,
			  const char * value);
//removes and destroys all data from cell
void cell_clear(DataCell * cell);

//DataRow

//create row with key
DataRow * row_new(const char * row_key);
//put cell into row
void row_append(DataRow * row, DataCell * putCell);
//removes and destroys all cells
void row_clear(DataRow * row);
//get cell at index
DataCell * row_cell_at_index(DataRow * row, int getIndex);
	
	
//DataCellIterator

//create new iterator over row
DataCellIterator * cell_iter_new(DataRow * row);
//gets next cell from row
DataCell * cell_iter_next_cell(DataCellIterator * iter);
//gets prev cell from row
DataCell * cell_iter_prev_cell(DataCellIterator * iter);
//moves iterator back to first cell
void iter_rewind(DataCellIterator * iter);

//DataPage

//create new page
DataPage * page_new();
//put cell into row
void page_append(DataPage * page, DataRow * putRow);
//removes and destroys all cells
void page_clear(DataPage * page);
//get row at index
DataRow * page_row_at_index(DataPage * page, int getIndex);

//DataRowIterator

//create new iterator over row
DataRowIterator * row_iter_new(DataPage * page);
//gets next cell from row
DataRow * row_iter_next_row(DataRowIterator * iter);
//gets prev cell from row
DataRow * row_iter_prev_row(DataRowIterator * iter);
//moves iterator back to first cell
void row_iter_rewind(DataRowIterator * iter);

#ifdef __cplusplus
}
#endif

#endif
