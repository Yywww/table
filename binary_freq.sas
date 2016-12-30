/********************************************************************************************************************
Macro name: binary_freq

Written by: Yiwen Luo

Creation date: Jun01 2015

As of date: 

SAS version: 9.4

Purpose: generate Confidenc Interval and frequency of a binary variable 

Parameters(required):dataset,var,out
 
Parameters(optional):index=1(the outcome of interest)

Sub-macros called: none

Data sets created: work.binary_output

Limitations: did not write code to detect error yet

Notes: 

History: 

Sample Macro call: %binary_freq(dataset=Group1,var=Approach,index=TA,out=Out1)

*************************************************************************************************************/

%macro binary_freq(dataset=,var=,index=1,out=,Zeroindex=all);

%count(&dataset,macroout=Noftotal)

data count;
	set &dataset;
	if &var="&index";
run;

%count(count,macroout=Nofindex)
%global Zero&Zeroindex;
%if &Nofindex=0 %then %let Zero&Zeroindex=0;
%else %let Zero&Zeroindex=1;
data &out;
	freq=cat(put(&Nofindex*100/&Noftotal,best4.),'%(',&Nofindex,'/',&Noftotal,')');
	variable="&var";
run;

proc datasets library=work;
	delete count;
run;
quit;
%mend;

/* **** End of Macro **** */
/* **** by Yiwen Luo **** */

/*Monday, June 15, 2015 13:04:52*/


