/********************************************************************************************************************
Macro name: adjustHR

Written by: Yiwen Luo

Creation date: Tuesday, July 28, 2015 13:55:03

As of date: 

SAS version: 9.4

Purpose: 

Parameters(required):dataset=,var=,timevar=,groupvar=,out=,cate=,adj=
 
Parameters(optional):

Sub-macros called: %logrank_freq %logrank_hrcip %logrank_hrcip_adjus

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %adjustHR(dataset=tabledata3,var=dth,timevar=dthdays,groupvar=complex_pci,out=dth,cate=male,adj=age male)

*************************************************************************************************************/


%macro adjustHR(dataset=,var=,timevar=,groupvar=,out=,cate=,adj=);
proc sort data=&dataset;
	by descending &var descending &groupvar;
run;

%logrank_freq(dataset=&dataset,var=&var,groupvar=&groupvar,out=freq)
%logrank_hrcip(dataset=&dataset,var=&var,timevar=&timevar,groupvar=&groupvar,out=hrcip);
%logrank_hrcip_adjust(dataset=&dataset,var=&var,timevar=&timevar,groupvar=&groupvar,out=adjhr_out,cate=&cate,adjustvar=&adj);

proc sql;
	create table &out as
	select freq.*, hrcip.hazardci, hrcip.pvalue,adjhr_out.adjpvalue,adjhr_out.adjhazardci
	from freq, hrcip, adjhr_out
	where freq.variable=hrcip.variable=adjhr_out.variable;
quit;

proc datasets library=work;
	delete freq hrcip nullfreq;
run;

%mend adjustHR;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */

/*Tuesday, July 28, 2015 14:11:24*/
