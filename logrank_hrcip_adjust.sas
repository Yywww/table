/********************************************************************************************************************
Macro name: logrank_hrcip_adjust

Written by: Yiwen Luo

Creation date: Tuesday, July 28, 2015 13:50:25

As of date: 

SAS version: 9.4

Purpose: 

Parameters(required):dataset=,var=,timevar=,groupvar=,out=adjhr_out,cate=,adjustvar=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %logrank_hrcip_adjust(dataset=tabledata3,var=mace,timevar=macedays,groupvar=complex_pci,out=mace,adjustvar=age male BMI ACS DIABETES PAD CHF Prev_MI Prev_CABG One_Ves Two_ves Thr_ves LM_Ves
		Hyperten   HYPERLIP  CURR_SMK   One_Ves Two_ves Thr_ves LM_Ves 
		EJECT_FR  HGB_BASE CREACL WBC_BASE PLT_BASE pru_208g complex_pci LAD RCA LCX IVUS_USD  TIMIPRE01  TIMIPRE2 TIMIPRE3 THRGRD0
		THRGRD1 THRGRD2 THRGRD3 THRGRD4 THRGRD5)

*************************************************************************************************************/

%macro logrank_hrcip_adjust(dataset=,var=,timevar=,groupvar=,out=adjhr_out,cate=,adjustvar=);

%if %symexist(cate) %then %do;
proc phreg data=&dataset;
	class &cate/ param=ref desc;
	model &timevar*&var(0)= &groupvar &adjustvar / ties=efron type3(score);
	hazardratio &groupvar;
	ods output ParameterEstimates=hazardp HazardRatios=hazardci;
run;

%end;
%else %do;
proc phreg data=&dataset;
	model &timevar*&var(0)= &groupvar &adjustvar / ties=efron type3(score);
	hazardratio &groupvar;
	ods output ParameterEstimates=hazardp HazardRatios=hazardci;
run;
%end;

data hp;
	set hazardp(firstobs=1 obs=1);
	adjPvalue=put(ProbChiSq,pvalue6.4);
	variable="&var";
	keep variable adjPvalue;
run;

data hci;
	set hazardci;
	length adjhazardci $20;
	adjhazardci=cats(put(HazardRatio,best4.),"[",put(WaldLower,best4.),",",put(WaldUpper,best4.),"]");
	variable="&var";
	keep variable adjhazardci;
run;
	 
data &out;
	merge hp hci;
	by variable;
run;

proc datasets library=work;
	delete hp hci hazardp hazardci;
run;
quit;
%mend logrank_hrcip_adjust;

