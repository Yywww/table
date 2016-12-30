/********************************************************************************************************************
Macro name: varexist

Written by: Yiwen Luo

Creation date: Wednesday, July 22, 2015 17:44:37

As of date: 

SAS version: 9.4

Purpose: find out whether a variable is within a dataset

Parameters(required):ds,vr
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: Source:https://communities.sas.com/message/154973

Sample Macro call: %varexist(label,label)

*************************************************************************************************************/
%macro varexist(ds,vr);

%local dsid rc ;
%let dsid = %sysfunc(open(&ds)); 
%if (&dsid) %then %do;
  %if %sysfunc(varnum(&dsid,&vr)) %then 1;
  %else 0 ;
  %let rc = %sysfunc(close(&dsid));
%end;
%else 0;
 
%mend varexist;
