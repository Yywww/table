/********************************************************************************************************************
Macro name: report

Written by: Yiwen Luo

Creation date: Tuesday, June 09, 2015 13:12:09

As of date: 

SAS version: 9.4

Purpose: build a fantacy report for a given table

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/

%INCLUDE "P:\DataAnalysis\ADAPT DES\Macros\ADAPTMacro Rewrites\new macro\IncludeCCLMacroCatAutoCalls_ADAPT.sas";
ods html close;
ods listing;


libname tables1 'P:\DataAnalysis\PARTNERII\AnalysisDatasets' access=readonly;

data analysis;
	set tables1.AT_adjev_km365;
run;

data InpFile;
   set analysis;
   by subject;
   if AT=1;
  if TRTC="NR5 - Inoperable TF" then groupvar=1;
   else if TRTC="NR6 - Inoperable TA" then groupvar=0;
   if groupvar in (1,0);
run;

%tabletable(dataset=InpFile,groupvar=groupvar,table=table)

%detectvariabletype(dataset=InpFile)

data Result;
	set Result;
	variable=Tablevar;
	drop Tablevar;
run;

proc sort data=table;
by variable;
run;

proc sort data=Result;
by variable;
run;

data temp;
	length rrci $30 rdci $30;
	merge Result table(in=A);
	by variable;
	if A;
run;



ods listing close;
ods html;

ods html file="P:\DataAnalysis\ADAPT DES\Macros\ADAPTMacro Rewrites\new macro\table2.xls";
proc report data=temp COLWIDTH=50;
	column variable category statistics firstgroup secondgroup total rrci rdci pvalue hazardratio;
	define variable/ group "Variable";
	define statistics/ display " ";
	define rrci / display "Risk Ratio";
	define rdci / display "Risk Difference";
	define pvalue / display "P-value";
	define firstgroup / display "NR5";
	define secondgroup / display "NR6";
run;
ods html close;

%contents(table)
%contents(tables1.AT_adjev_km365)

%macro test;
data input;
input a b;
cards;
1 2
3 4
;
run;
%mend;

%test
