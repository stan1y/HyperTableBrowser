/*
 *  DataPage.cpp
 *  HyperTableBrowser
 *
 *  Created by Stanislav Yudin on 12/17/09.
 *  Copyright 2009 AwesomeStanlyLabs. All rights reserved.
 *
 */

#include "DataPage.h"

//create new data cell
DataCell * cell_new(DataCell * prev, DataCell * next)
{
	DataCell * c = (DataCell *)malloc(sizeof(DataCell));
	c->nextCell = next;
	c->prevCell = prev;
	
	c->cellColumnFamilySize = 0;
	c->cellColumnQualifierSize = 0;
	c->cellValueSize = 0;
	
	return c;
}

//set cell values
void cell_set(DataCell * cell,
			  const char * family, 
			  const char * qualifier,
			  const char * value)
{
	int familyLen = strlen(family);
	int qualifierLen = strlen(qualifier);
	int valueLen = strlen(value);
	//family
	if (familyLen > 0) {
		cell->cellColumnFamily = (char*)malloc( (familyLen + 1) * sizeof(char));
		strncpy(cell->cellColumnFamily, family, familyLen + 1);
		cell->cellColumnFamilySize = familyLen;
		
	}
		
	//qualifier
	if (qualifierLen > 0) {
		cell->cellColumnQualifier = (char*)malloc( (qualifierLen + 1) * sizeof(char));
		strncpy(cell->cellColumnQualifier, qualifier, qualifierLen + 1);
		cell->cellColumnQualifierSize = qualifierLen;
	}
	 
	//value
	if (valueLen > 0) {
		cell->cellValue = (char*)malloc((valueLen + 1) * sizeof(char));
		strncpy(cell->cellValue, value, valueLen + 1);
		cell->cellValueSize = valueLen;
	}
}
//removes and destroys all data from cell
void cell_clear(DataCell * cell)
{
	if (cell->cellColumnFamily && cell->cellColumnFamilySize > 0 ) {
		free(cell->cellColumnFamily);
		cell->cellColumnFamilySize = 0;
		cell->cellColumnFamily = NULL;
	}
	
	if (cell->cellColumnQualifier && cell->cellColumnQualifierSize > 0) {
		free(cell->cellColumnQualifier);
		cell->cellColumnQualifierSize = 0;
		cell->cellColumnQualifier = NULL;
	}
	
	if (cell->cellValue && cell->cellValueSize > 0 ) {
		free(cell->cellValue);
		cell->cellValueSize = 0;
		cell->cellValue = NULL;
	}
	
	cell->prevCell = NULL;
	cell->nextCell = NULL;
}

//create row with number of cells
DataRow * row_new(const char * row_key)
{
	DataRow * row = (DataRow *)malloc(sizeof(DataRow));
	row->cellsCount = 0;
	row->cellsHead = NULL;
	row->cellsTail = NULL;
	
	int keyLen = strlen(row_key);
	row->rowKey = (char *)malloc( (keyLen + 1) * sizeof(char));
	strncpy(row->rowKey, row_key, (keyLen + 1));
	row->rowKeySize = keyLen;
	
	return row;
}
//put cell into row
void row_append(DataRow * row, DataCell * putCell)
{
	if (row->cellsTail) {
		putCell->prevCell = row->cellsTail;
		row->cellsTail->nextCell = putCell;
	}
	
	//set tail
	row->cellsTail = putCell;
	row->cellsTail->nextCell = NULL;
	
	//set head if first
	if (!row->cellsHead) {
		row->cellsHead = putCell;
		row->cellsHead->prevCell = NULL;
	}
	
	row->cellsCount += 1;
}

//removes and destroys all cells
void row_clear(DataRow * row)
{
	DataCellIterator * i = cell_iter_new(row);
	DataCell * cell;
	do {
		cell = cell_iter_next_cell(i);
		if (cell) {
			cell_clear(cell);
			free(cell);
		}
		else {
			break;
		}

	} while (true);
	free(i);
	
	if (row->rowKey && row->rowKeySize > 0 ) {
		free(row->rowKey);
	}
}

DataCell * row_cell_at_index(DataRow * row, int getIndex)
{
	DataCellIterator * i = cell_iter_new(row);
	DataCell * cell;
	int index = 0;
	do {
		cell = cell_iter_next_cell(i);
		if (index == getIndex) {
			free(i);
			return cell;
		}
		index++;
	} while (cell);
	free(i);
	
	return NULL;
}

//create new iterator over row
DataCellIterator * cell_iter_new(DataRow * row)
{
	DataCellIterator * iter = (DataCellIterator *)malloc(sizeof(DataCellIterator));
	iter->row = row;
	iter->currentCell = row->cellsHead;
	return iter;
}

//gets next cell from row
DataCell * cell_iter_next_cell(DataCellIterator * iter)
{
	DataCell * cell = iter->currentCell;
	//move forward
	if (cell) {
		iter->currentCell =  (DataCell *)cell->nextCell;
	}
	return cell;
}
//gets prev cell from row
DataCell * cell_iter_prev_cell(DataCellIterator * iter)
{
	DataCell * cell = iter->currentCell;
	//move back
	if (cell) {
		iter->currentCell =  (DataCell *)cell->prevCell;
	}
	
	return cell;
}
//moves iterator back to first cell
void iter_rewind(DataCellIterator * iter)
{
	iter->currentCell = iter->row->cellsHead;
}

//DataPage

//create new page
DataPage * page_new()
{
	DataPage * page = (DataPage *)malloc(sizeof(DataPage));
	page->rowsHead = NULL;
	page->rowsTail = NULL;
	page->rowsCount = 0;
	return page;
}
//put cell into row
void page_append(DataPage * page, DataRow * putRow)
{
	if (page->rowsTail) {
		putRow->prevRow = page->rowsTail;
		page->rowsTail->nextRow = putRow;
	}
	
	//set tail
	page->rowsTail = putRow;
	page->rowsTail->nextRow = NULL;
	
	//set head if first
	if (!page->rowsHead) {
		page->rowsHead = putRow;
		page->rowsHead->prevRow = NULL;
	}
	
	page->rowsCount += 1;
	
}
//removes and destroys all cells
void page_clear(DataPage * page)
{
	DataRowIterator * i = row_iter_new(page);
	DataRow * row;
	do {
		row = row_iter_next_row(i);
		if (row) {
			row_clear(row);
			free(row);
		}
		else {
			break;
		}

	} while (true);
	free(i);
}

DataRow * page_row_at_index(DataPage * page, int getIndex)
{
	DataRowIterator * i = row_iter_new(page);
	DataRow * row;
	int index = 0;
	do {
		row = row_iter_next_row(i);
		if (index == getIndex) {
			free(i);
			return row;
		}
		index++;
	} while (row);
	free(i);
	return NULL;
}

//DataRowIterator

//create new iterator over row
DataRowIterator * row_iter_new(DataPage * page)
{
	DataRowIterator * iter = (DataRowIterator *)malloc(sizeof(DataRowIterator));
	iter->page = page;
	iter->currentRow = page->rowsHead;
	
	return iter;
}
//gets next cell from row
DataRow * row_iter_next_row(DataRowIterator * iter)
{
	DataRow * row = iter->currentRow;
	if (row && row->nextRow) {
		iter->currentRow = (DataRow *)row->nextRow;
	}
	else {
		iter->currentRow = NULL;
	}

	return row;
}
//gets prev cell from row
DataRow * row_iter_prev_row(DataRowIterator * iter)
{
	DataRow * row = iter->currentRow;
	if (row) {
		iter->currentRow = (DataRow *)row->prevRow;
	}
	
	return row;
}
//moves iterator back to first cell
void row_iter_rewind(DataRowIterator * iter)
{
	iter->currentRow = iter->page->rowsHead;
}