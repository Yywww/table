/********************************************************************************************************************
Macro name: check_line_cross

Written by: Yiwen Luo

Creation date: Monday, November 09, 2015 01:12:38

As of date: 

SAS version: 9.4

Purpose: check the survival curve of different strata across or not

Parameters(required):data=,time=,event=,strata=
 
Parameters(optional):

Sub-macros called: %getlevel, %range, %count

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %check_line_cross(data=rely861.rely861_cancer_predictors,time=develop_cancerdays,event=develop_cancer,strata=tpatt)


*************************************************************************************************************/

/********************************************************************************************************************
This is an example of how to use this macro:


%INCLUDE "P:\DataAnalysis\MACRO_LIB\CRF Macro Library\UtilityMacros\CRFAssignMacroLibraries.SAS";

libname rely861 "P:\DataAnalysis\RELY\Queries\RELY_861 Cancer";

%check_line_cross(data=rely861.rely861_cancer_predictors,time=develop_cancerdays,event=develop_cancer,strata=tpatt)

End of the Example Program

*************************************************************************************************************/



%macro check_line_cross(data=,time=,event=,strata=);

ods output productlimitestimates = devcan_km;
proc lifetest data = &data;
    time &time * develop_cancer(0);
    strata &strata;
    run;
 
data futime;
    do develop_cancerdays = 0 to 1132;
    output;
    end;
    run;
 
proc sort data = devcan_km;
    by &strata &time;
    run;
 

%getlevel(&data, out=&strata._info, factor=&strata);
%count(&strata._info,macroout=n_level)
%do i=1 %to &n_level;
	data _null_;
		set &strata._info(firstobs=&i obs=&i);
		call symput ('curlevel',factorValue);
	run;
	data &strata.&i;
		set devcan_km;
		if &strata="&curlevel";
		if survival^=.;
		survival_&curlevel=log(-log(survival));
	run;
%end;
data futime;
    merge %range(to=&n_level, opre=&strata);
    by &time;
	drop survival;
run;

data futime;
	set futime(firstobs=2);
run;

%do i=1 %to &n_level;
data _null_;
	set &strata._info(firstobs=&i obs=&i);
	call symput ('curlevel',factorValue);
run;
data futime;
	set futime;
	retain cursurv;
	if survival_&curlevel^=. then cursurv=survival_&curlevel;
	else survival_&curlevel=cursurv;
run;
%end;



/*  **********************************************test****************************************************************  */
%do i=1 %to &n_level;
data _null_;
	set &strata._info(firstobs=&i obs=&i);
	call symput ('curlevel',factorValue);
run;
%do subi=%eval(&i+1) %to &n_level;
data _null_;
	set &strata._info(firstobs=&subi obs=&subi);
	call symput ('curvslevel',factorValue);
run;
data test;
	set futime;
	diff=survival_&curlevel-survival_&curvslevel;
	if diff>0 then sign=1;
	if diff<0 then sign=0;
	if diff=0 then sign=2;
	if sign^=2;
run;
proc means data=test;
var sign;
output out=_testsum max=max min=min;
run;

data _null_;
	set _testsum;
	call symput('max',max);
	call symput('min',min);
run;

%if &min=&max %then %put there is no cross between &strata.&curlevel and &strata.&curvslevel;
%else %put there is a cross between &strata.&curlevel and &strata.&curvslevel;

%end;
%end;

%mend;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, November 09, 2015 03:01:39*/


data futime;
    merge tpatt1 tpatt2 tpatt3;
    by develop_cancerdays;
	drop survival;
run;
