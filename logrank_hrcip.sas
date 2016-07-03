/********************************************************************************************************************
Macro name: logrank_hrcip

Written by: Yiwen Luo

Creation date: Friday, June 05, 2015 14:11:02

As of date: 

SAS version: 9.4

Purpose: give hazard ratio, its CI and P value of one pair survival variable

Parameters(required):dataset=,var=,timevar=,groupvar=
 
Parameters(optional):out=hazrad_ratio_out

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %logrank_hrcip(dataset=analysis,var=dth,timevar=dthdays,groupvar=pru_208g,out=hout)

*************************************************************************************************************/


%macro logrank_hrcip(dataset=,dependentvar=,groupvar=,out=hazrad_ratio_out,outputfmt=);

proc phreg data=&dataset;
	class &groupvar/ param=ref desc;
	model &dependentvar.days*&dependentvar(0)= &groupvar / ties=efron type3(score);
	hazardratio &groupvar;
	ods output ParameterEstimates=hazardp HazardRatios=hazardci;
run;

data hp;
	set hazardp;
	Pvalue=put(ProbChiSq,pvalue6.4);
	variable="&dependentvar";
	keep variable Pvalue;
run;

data hci;
	set hazardci;
	length hazardci $20;
	hazardci=cats(put(HazardRatio,best4.),"[",put(WaldLower,best4.),",",put(WaldUpper,best4.),"]");
	variable="&dependentvar";
	keep variable hazardci;
run;
	 
data &out;
	merge hp hci;
	by variable;
	if index(hazardci,'0[0,]') ge 1 then hazardci='N/A';
run;

proc datasets library=work;
	delete hp hci hazardp hazardci;
run;
quit;
%mend logrank_hrcip;



/* **** End of Macro **** */
/* **** by Yiwen Luo **** */
/*Friday, June 05, 2015 15:00:31*/
