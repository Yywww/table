/********************************************************************************************************************
Macro name: logrank

Written by: Yiwen Luo

Creation date: Friday, June 05, 2015 15:13:37

As of date: 

SAS version: 9.4

Purpose: give all statistics of one pair variable

Parameters(required):dataset=,var=,groupvar=
 
Parameters(optional):vari=1,groupvari=1

Sub-macros called: %binary_freq, %logrank_hrcip

Data sets created: out1 out2 out3 hrcip group1 group2

Limitations: 

Notes: 

Sample Macro call: %logrank(dataset=analysis,var=dth,groupvar=pru_208g)


*************************************************************************************************************/

%macro logrank(dataset=,var=,groupvar=,vari=1,groupvari=1);

proc sort data=&dataset;
	by descending &var descending &groupvar;
run;

%freq(dataset=&dataset,var=&var,groupvar=&groupvar,out=nullfreq)
%logrank_freq(dataset=&dataset,var=&var,groupvar=&groupvar,out=freq)

%put &Zero;

%if &Zero=1 %then %do;
data hrcip;
length hazardci $20;
length Pvalue $6;
variable="&var";
hazardci="N/A";
Pvalue="N/A";
run;
%end;
%else %do;
%logrank_hrcip(dataset=&dataset,var=&var,timevar=&var.Days,groupvar=&groupvar,out=hrcip);
%end;

proc sql;
	create table &var as
	select freq.*, hrcip.hazardci, hrcip.pvalue
	from freq, hrcip
	where freq.variable=hrcip.variable;
quit;

proc datasets library=work;
	delete freq hrcip nullfreq;
run;
%mend;

/* **** End of Macro **** */
/* **** by Yiwen Luo **** */
/*Friday, June 05, 2015 15:13:40*/
