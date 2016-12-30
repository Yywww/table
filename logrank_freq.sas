/********************************************************************************************************************
Macro name: logrank_freq

Written by: Yiwen Luo

Creation date: Monday, June 22, 2015 17:12:04

As of date: 

SAS version: 9.4

Purpose: create frenquency table for a logrank variable

Parameters(required):dataset=,var=,groupvar=,out=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %logrank_freq(dataset=analysis,var=cdth,groupvar=pru_208g,out=freq)

*************************************************************************************************************/
%INCLUDE "P:\DataAnalysis\ADAPT DES\Macros\ADAPTMacro Rewrites\new macro\IncludeCCLMacroCatAutoCalls_ADAPT.sas";

%macro logrank_freq(dataset=,var=,groupvar=,out=);

proc lifetest data=&dataset method=km;
	time &var.Days*&var(0);
	strata &groupvar;
	ods output ProductLimitEstimates=lrfreqg;
run;

proc lifetest data=&dataset method=km;
	time &var.Days*&var(0);
	ods output ProductLimitEstimates=lrfreqt;
run;


data freq_string1;
	set lrfreqg(where=(Failure^=. and &groupvar=1)) end=lastobs;
	if lastobs;
	firstgroup=cats(put(Failure,percent10.1),'(',Failed,')');
	variable="&var";
	keep firstgroup variable;
run;

data freq_string2;
	set lrfreqg(where=(Failure^=. and &groupvar=0)) end=lastobs;
	if lastobs;
	secondgroup=cats(put(Failure,percent10.1),'(',Failed,')');
	variable="&var";
	keep secondgroup variable;
run;

data freq_string3;
	set lrfreqt(where=(Failure^=.)) end=lastobs;
	if lastobs;
	total=cats(put(Failure,percent10.1),'(',Failed,')');
	variable="&var";
	keep total variable;
run;

data &out;
	merge freq_string1 freq_string2 freq_string3;
	by variable;
run;

proc datasets lib=work;
	delete freq_string1 freq_string2 freq_string3 lrfreqg lrfreqt;
quit;

%mend logrank_freq;


