/* CCL Note [01SEPTEMBER2015]: I don't think this is the appropriate macro for this - logranktest should conduct a logrank test... not get HR. */

/*!
 * This file collects demographic information from end users.
 * Whenever the user deletes a record from the demographic database,
 * this program will notify the administrator by email.
 *
 * @author 
 * @created 
 */

/********************************************************************************************************************
Macro name: logranktest

Written by: Yiwen Luo

Creation date: Wednesday, August 12, 2015 11:26:01

As of date: 

SAS version: 9.4

Purpose: Give test for logrank variable

Parameters(required): dataset=,var=,timevar=,groupvar=,groupvar_refindex=,out=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %logranktest(dataset=testset,var=mace,timevar=macedays,groupvar=vessel_disease,groupvar_refindex=1,out=macetest)

*************************************************************************************************************/
/**
 * Description: Give test for logrank variable
 *
 * @param dataset input dataset
 * @param var variable to be analyzed
 * @param timevar time to event
 * @param groupvar group variable
 * @param groupvar_refindex index for group variable reference
 * @param out output dataset
 */ 

%macro logranktest(dataset=,var=,timevar=,groupvar=,groupvar_refindex=,out=);

%getlevel(&dataset, out=groupvar_info, factor=&groupvar);

data groupvar_info_withoutref;
    set groupvar_info;
	if factorValue^=&groupvar_refindex;
run;

%let nminusone_level = %nobs(groupvar_info_withoutref);

%do npair=1 %to &nminusone_level;
data _null_;
	set groupvar_info_withoutref(firstobs=&npair obs=&npair);
	call symput('currentpair', strip(factorvalue));
run;

data pairdat;
	set &dataset;
	if &groupvar=&currentpair | &groupvar=&groupvar_refindex;
run;

proc phreg data=pairdat;
	class &groupvar/ param=ref desc;
	model &timevar*&var(0)= &groupvar / ties=efron type3(score);
	hazardratio &groupvar;
	ods output HazardRatios=hazardci;
run;

data hci&npair;
	set hazardci;
	length hazardci $20;
	length variable $30;
	hazardci_&currentpair.vs&groupvar_refindex=cats(put(HazardRatio,best4.),"[",put(WaldLower,best4.),",",put(WaldUpper,best4.),"]");
	variable="&var";
	keep variable hazardci_&currentpair.vs&groupvar_refindex;
run;

%end;

proc phreg data=&dataset;
	class &groupvar/ param=ref desc;
	model &timevar*&var(0)= &groupvar / ties=efron type3(score);
	hazardratio &groupvar;
	ods output Type3=hazardp;
run;

data hp;
	set hazardp;
	length test $20;
	length variable $30;
	Pvalue=put(ProbScoreChiSq,pvalue6.4);
	variable="&var";
	test='Type3 Chi-Square';
	keep variable Pvalue test;
run;

data &out;
	merge %range(to=&nminusone_level,opre=hci) hp;
	by variable;
run;

proc datasets library=work nolist nodetails;
	delete hazardci hazardp pairdat groupvar_info groupvar_info_withoutref %range(to=&nminusone_level,opre=hci) hp;
quit;

%mend logranktest;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, August 12, 2015 11:22:06*/
