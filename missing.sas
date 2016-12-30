/********************************************************************************************************************
Macro name: missing

Written by: Yiwen Luo

Creation date: Jun03 2015

As of date: 

SAS version: 9.4

Purpose: detect all variable in a dataset whether have missing values or not

Parameters(required):dataset
 
Parameters(optional):out=missing

Sub-macros called: 

Data sets created: work.level

Limitations: 

Notes: 

Sample Macro call: missing(analysis,out=missing)

*************************************************************************************************************/
%macro missing(dataset,out=missing);

proc freq data=&dataset NLEVELS;
	ods output Nlevels=level;
run;

data &out;
	set level;
	length status $30;
	if NMissLevels=0 then status="No Missing Value";
	else status="Have Missing Value";
	drop NLevels NMissLevels NNonMissLevels;
run;

proc report data=&out;
	title 'number of missing value in &dataset'
run;

proc datasets library=work;
	delete level;
run;
quit;

%mend missing;
