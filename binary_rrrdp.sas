/********************************************************************************************************************
Macro name: binary_rrrdp

Written by: Yiwen Luo

Creation date: Jun01 2015

As of date: Monday, June 15, 2015 10:05:36

SAS version: The version and platform used to write the macro.

Purpose: produce relative risk and risk difference with their CI, along with p_value

Parameters(required):dataset=,var=,groupvar=
 
Parameters(optional):vari=1,out=rrrdp

Sub-macros called: none

Data sets created: 

Limitations: 

Notes: haven't write commment yet

History: 

Sample Macro call:  %binary_rrrdp(dataset=abc,var=a,groupvar=b,vari=1,out=out1);
					%binary_rrrdp(dataset=abc,var=a,groupvar=b,vari=0,out=out2);

*************************************************************************************************************/



%macro binary_rrrdp(dataset=,var=,groupvar=,vari=,out=rrrdp);

proc sort data=&dataset;
by descending &groupvar descending &var;
run;


proc freq data=&dataset order=data;
	tables &groupvar*&var/relrisk riskdiff chisq fisher;
	ods output CrossTabFreqs=CT RiskDiffCol1=rd ChiSq=chi RelativeRisks=rr FishersExact=fish;
run;

data rr_string;
	set rr;
	length variable $30;
	length rrci $50;
	if Statistic="Relative Risk (Column 1)";
	rrci=cats(put(Value,best4.),"[",put(LowerCL,best4.),",",put(UpperCL,best4.),"]");
	variable="&var";
	keep variable rrci;
run;


data rd_string;
	set rd;
	if Row="Difference";
	length variable $30;
	length rdci $50;
	rdci=cats(put(Risk,percentn10.2),"[",put(LowerCL,percentn10.2),",",put(UpperCL,percentn10.2),"]");
	variable="&var";
	keep variable rdci;
run;

data _null_;
	set _fisher_;
	call symput('fisher',fisher);
run;


%if &fisher=1 %then %do;

data p_string;
	set fish;
	if name1='XP2_FISH';
	variable="&var";
	Pvalue=put(nValue1,pvalue6.4);
	keep variable Pvalue;
run;

%end;

%else %do;

data p_string;
	set chi;
	if Statistic="Chi-Square";
	length variable $30;
	variable="&var";
	Pvalue=put(Prob,pvalue6.4);
	keep variable Pvalue;
run;

%end;

data &out;
	merge rr_string rd_string p_string;
	by variable;
run;

proc datasets library=work;
	delete rr rd chi rr_string rd_string p_string ct fish _fisher_;
run;

%mend binary_rrrdp;


