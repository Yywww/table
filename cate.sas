/********************************************************************************************************************
Macro name: cate

Written by: Yiwen Luo

Creation date: Wednesday, June 17, 2015 11:26:13

As of date: 

SAS version: 9.4

Purpose: give all statistics result about one categorcial variable by one group variable.(to replace %categorical)

Parameters(required):dataset=,cate=,groupvar=
 
Parameters(optional):

Sub-macros called: %count,%binary

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %cate(dataset=analysis,cate=crp_cat,groupvar=pru_208g)

*************************************************************************************************************/

%macro cate(dataset=,cate=,groupvar=);
proc freq data=&dataset;
	table &cate;
	ods output OneWayFreqs=factor;
run;

%count(factor)

data _null_;
	set factor(firstobs=1 obs=1);
	call symput('currentfac',&cate);
run;

data dummy;
	set &dataset;
	if &cate=&currentfac then dummy=1;
	else dummy=0;
	keep &groupvar dummy;
run;

proc sort data=dummy;
	by descending dummy desending &groupvar;
run;

%binary(dataset=dummy,var=dummy,groupvar=&groupvar,out=out)
data out;
	set out;
	length variable $30;
	variable="&cate";
	category="&currentfac";
run;

data &cate;
	set out;
run;

%do i=2 %to &N;

data _null_;
	set factor(firstobs=&i obs=&i);
	call symput('currentfac',&cate);
run;

data dummy;
	set &dataset;
	if &cate=&currentfac then dummy=1;
	else dummy=0;
	keep &groupvar dummy;
run;

proc sort data=dummy;
	by descending dummy desending &groupvar;
run;

%binary(dataset=dummy,var=dummy,groupvar=&groupvar,out=out)
data out;
	set out;
	variable="&cate";
	category="&currentfac";
run;

data &cate;
	set &cate out;
run;

%end;

proc datasets library=work;
	delete out factor dummy;
run;
%mend;
