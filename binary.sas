/********************************************************************************************************************
Macro name: In addition to the file name, include the full path of the
directory in which it resides.

Written by: Yiwen Luo

Creation date: Jun01 2015

As of date:

SAS version: 

Purpose: give a statistics table for a binary grouped by another binary variable

Parameters(required): dataset=, var=, groupvar=, vari=
 
Parameters(optional):

Sub-macros called: %binary_freq, %binary_rrrdp

Data sets created: a dataset which name is the variable of interest

Limitations: 

Notes: 

History: 

Sample Macro call: %binary(dataset=abc,var=a,groupvar=b,vari=1)

*************************************************************************************************************/


%macro binary(dataset=,var=,groupvar=,vari=,out=);

proc sort data=&dataset;
	by descending &var descending &groupvar;
run;

%freq(dataset=&dataset,var=&var,groupvar=&groupvar,out=freq)

%if &Zero=1 %then %do;
	data rrrdp;
		length variable $30;
		length rrci $20;
		length rdci $20;
		length Pvalue $6;
		variable="&var";
		rdci="N/A";
		rrci="N/A";
		Pvalue="N/A";
	run;
%end;
%else %do;
%binary_rrrdp(dataset=&dataset,var=&var,groupvar=&groupvar,vari=&vari,out=rrrdp);
%end;

proc sql;
	create table &out as
	select t1.firstgroup,t1.secondgroup,t1.total, t2.*
	from freq as t1, rrrdp as t2
	where t1.variable=t2.variable;
quit;

proc datasets library=work;
	delete freq rrrdp;
run;
%mend;

