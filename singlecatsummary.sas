/*!
 * This file collects demographic information from end users.
 * Whenever the user deletes a record from the demographic database,
 * this program will notify the administrator by email.
 *
 * @author Yiwen Luo	
 * @created Monday, September 28, 2015 15:20:02
 */
/********************************************************************************************************************
Macro name: singlecatsummary

Written by: Yiwen Luo

Creation date: Monday, September 28, 2015 15:19:51

As of date: 

SAS version: 9.4

Purpose: give statistics of one categorical variable(can used for varloop)

Parameters(required):dataset=, var=, out=
 
Parameters(optional):outvar=result

Sub-macros called: %singlebinsummary %getlevel %count %range

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %singlecatsummary(dataset=teset.adapt_learning_ds,var=male cauc, out=test, outvar=notresult)

*************************************************************************************************************/
/**
 * Description:
 *
 * @param dataset input dataset name
 * @param var variable to be analyzed
 * @param out output dataset name
 * @param outvar variable name of the result
 */ 


%macro singlecatsummary(dataset=, var=, out=,outvar=result);

	%getlevel(&dataset, out=catevarinfo, factor=&var)

	%count(catevarinfo, macroout=Nlevelofcate)

    /* Loops over levels of categorical variable to get summaries */
	%DO catei=1 %TO &Nlevelofcate;

        data _null_;
    		set catevarinfo(firstobs=&catei obs=&catei);
    		call symput('currentcatefac', factorvalue);
    	run;

    	data dummy;
    		set &dataset;
    		if &var = &currentcatefac then dummy=1;
    		else dummy=0;
    		keep dummy;
    	run;

    	%singlebinsummary(dataset=dummy, var=dummy, out=out,outvar=&outvar)

    	data cate&catei;
    		set out;
    		length variable $30;
    		variable="&var";
    		category="&currentcatefac";
    	run;
	%END;


	data &out;
		set %range(to=&Nlevelofcate, opre=cate);
	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&Nlevelofcate, opre=cate) out dummy catevarinfo;
	quit;

    %symdel Nlevelofcate / nowarn;

%MEND;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, September 28, 2015 15:23:43*/
