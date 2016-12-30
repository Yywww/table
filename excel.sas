/********************************************************************************************************************
Macro name: excel

Written by: Yiwen Luo

Creation date: Monday, June 22, 2015 11:23:10

As of date: 

SAS version: 9.4

Purpose: create multiple table into one excel file

Parameters(required):datapath=,outputpath=,filename=,groupvar=
 
Parameters(optional):

Sub-macros called: %tabletable,%count

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %excel(datapath=P:\DataAnalysis\ADAPT DES\2 Year FU\AnalysisDatasets,outputpath=P:\DataAnalysis\ADAPT DES\Macros\ADAPTMacro Rewrites\new macro,filename=thisone,groupvar=Cauc)

*************************************************************************************************************/

%macro excel(datapath=,outputpath=,filename=,groupvar=);

libname &filename excel "&outputpath.\&filename..xls";
libname datasets "&datapath";

ods output Members=memout;
proc datasets lib=datasets;
run;
quit;

%count(memout,macroout=nmem)

%do i=1 %to &nmem;

	data _null_;
		set memout(firstobs=&i obs=&i);
		call symput('dataset',name);
	run;

	%put &dataset;

	%tabletable(data=datasets.&dataset,groupvar=&groupvar,table=&filename..&dataset)

%end;

libname &filename CLEAR;

proc datasets lib=work;
	delete memout;
quit;

%mend excel;


/* **** End of Macro **** */
/* **** by Yiwen Luo **** */

/*Monday, June 22, 2015 15:12:40*/
