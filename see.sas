/*!
 * see dataset
 *
 * @author Yiwen Luo
 * @created Friday, August 14, 2015 10:07:45
 */
/********************************************************************************************************************
Macro name: see

Written by: Yiwen Luo

Creation date: Friday, August 14, 2015 10:07:36

As of date: 

SAS version: 9.4

Purpose: see dataset

Parameters(required): ds,obs=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %see()

*************************************************************************************************************/
/**
 * Description: see dataset
 *
 * ds input dataset if not given use the last dataset created
 * obs number of observations want to see, if not given then all
 * 
 */ 

%macro see(ds,obs=);
%if %length(&ds)=0 %then %do;
%if %length(&obs)=0 %then %do;
proc sql;
	select *
	from &syslast;
quit;
%end;
%else %do;
proc sql outobs=&obs;
	select *
	from &syslast;
quit;
%end;
%end;
%else %do;
%if %length(&obs)=0 %then %do;
proc sql;
	select *
	from &ds;
quit;
%end;
%else %do;
proc sql outobs=&obs;
	select *
	from &ds;
quit;
%end;
%end;


%mend;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Friday, August 14, 2015 10:06:02*/
