/*!
 * label the current dataset
 *
 * @author Yiwen Luo
 * @created Tuesday, August 11, 2015 14:58:05
 */
/********************************************************************************************************************
Macro name: %label_dataset

Written by: Yiwen Luo

Creation date: Tuesday, August 11, 2015 14:58:07

As of date: 

SAS version: 9.4

Purpose: label the current dataset

Parameters(required): None
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description:label the current dataset
 *
 */ 

%MACRO label_dataset;
submit '
	%let filepath = %sysget(sas_execfilepath);
	%let _libname=%scan(%str(&syslast),1,.);
	%let _dsname=%scan(%str(&syslast),2,.);
    %let open_data = %sysfunc(open(&syslast,i));
	%let nobs=%sysfunc(attrn(&open_data,nobs)) ;  
	%let nvar=%sysfunc(attrn(&open_data,nvars));
	%let rc = %sysfunc(close(&open_data));
	%let label = %upcase(&syslast): N=%str(&nobs) | Var=%str(&nvar) | Created in (%str(&filepath)) by YLuo on &sysdate.;

	proc datasets library = &_libname NOLIST FORCE;
		modify &_dsname (label = "&label.");
		run;
	quit;';
%MEND;


/* TESTSET: N=8582 | Var=13 */
