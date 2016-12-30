/********************************************************************************************************************
Macro name: return_dataset_info

Written by: Yiwen Luo and Claire Litherland

Creation date: Wednesday, July 01, 2015 10:38:02

As of date: Tuesday, August 11, 2015 15:31:39Tuesday, August 11, 2015 15:09:10

SAS version: 9.4

Purpose: write a note to clipboard with info of last dataset

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: Really Really exhausting

Sample Macro call: 

*************************************************************************************************************/
%macro return_dataset_info;
submit "
filename _cb clipbrd;
%let ds_name=%scan(%str(&syslast),2,.);
%let open_data = %sysfunc(open(&syslast,i));
%let nobs=%sysfunc(attrn(&open_data,nobs)) ;  
%let nvar=%sysfunc(attrn(&open_data,nvars));
%let rc = %sysfunc(close(&open_data));
data _null_;
file _cb;	
d='/* '||'&ds_name'||': N='||strip(%str(&nobs))||' | Var='||strip(%str(&nvar))||' */';
put d; 
run; 
filename _cb clear;
dm editor 'WPASTE;' editor;
";
%mend return_dataset_info;


/* **** End of Macro **** */
/* **** by Yiwen Luo **** */

/*Wednesday, July 01, 2015 10:39:24*/
