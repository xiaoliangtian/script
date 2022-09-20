#!/usr/bin/env python
#coding = utf-8

import openpyxl,sys

workbook = openpyxl.load_workbook(sys.argv[1])
rmsheet = ["MitoVars","LOH"]
sheetName = workbook.get_sheet_names()
for i in rmsheet:
    # sheetName = workbook.get_sheet_names()
    # print (sheetName)
    if i in sheetName:
        workbook.remove(workbook.get_sheet_by_name(i))


workbook.save(sys.argv[1])
print(sys.argv[1]+ "\t"+"done!")