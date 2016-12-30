/********************************************************************************************************************
Macro name: make_dict_list

Written by: Yiwen Luo

Creation date: Thursday, November 05, 2015 10:38:03

As of date: 

SAS version: 9.4

Purpose: create a varlist using dictionary

Parameters(required): dictionary=, type=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %let a=%make_dict_list(dictionary=,type=)

*************************************************************************************************************/

%macro make_dict_list(dictionary=,type=);
%let dsid=%sysfunc(open(&dictionary(where=(SasType=upcase("&type"))),i));
%let varlist= ;
%do i=1 %to %sysfunc(attrn(&dsid,NOBS));
%let rc=%sysfunc(fetchobs(&dsid,&i));
%let style=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,variablename))));
%put &style;
%let varlist=&varlist &style;
%end;
&varlist;
%mend;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, November 05, 2015 10:37:34*/
