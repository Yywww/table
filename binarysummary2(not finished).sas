/*!
 * This file collects demographic information from end users.
 * Whenever the user deletes a record from the demographic database,
 * this program will notify the administrator by email.
 *
 * @author 
 * @created 
 */
/********************************************************************************************************************
Macro name: 

Written by: Yiwen Luo

Creation date: 

As of date: 

SAS version: 9.4

Purpose: 

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description:
 *
 * @param <param-name> <param-description>
 * @param 
 * @param 
 * @param 
 * @return 
 */ 

%macro binarysummary2();
    %getlevel(&ds, out=&groupvar._info, factor=&groupvar);
	%let n_level = %nobs(&groupvar._info);
    %do noflevel=1 %to &n_level;/*no i*/
    data _null_;
        set &groupvar._info(firstobs=&noflevel obs=&noflevel);
        call symput('currentfac', factorvalue);
    run;

	%freqgroup(ds=&ds,var=&var,groupvar=&groupvar,index=&currentfac,out=var_&noflevel);
	data new;
		set &ds;
		where &groupvar=&currentfac;
		keep &var;
	run;
	
	proc freq data=new;
		tables &var/binomial(wilson);
	run;


	%end;

	data new;
		set &ds;
		keep &var;
	run;

	%count(new,macroout=N)

	data _count;
		set new;
		where &var=1;
	run;
	%count(_count,macroout=Nm)
	data total;
		length variable $30 statistics $50;
		Variable="&var";
		Statistics="n/N(%)";
		Total=cats("&Nm/&N(",put(&Nm/&N,percent7.1),")");
	run;

	data &out;
	merge %range(to=&n_level., opre=var_) total;
	by variable;
	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level., opre=var_) new total &groupvar._info _count;
	quit;
%mend binarysummary2();








