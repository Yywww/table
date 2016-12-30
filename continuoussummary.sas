/*!
 * Give summary information of one continuous variable by group.
*   <br>
 * <b> Macro Location: </b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros  
 *
 * @author Yiwen Luo	
 * @created Monday, August 10, 2015 16:22:15
 */
/********************************************************************************************************************
Macro name: continuoussummary
Written by: Yiwen Luo
Creation date: Monday, August 10, 2015 15:42:02
As of date: Friday, August 14, 2015 13:33:35
SAS version: 9.4

Purpose: Give summary information of one continuous variable over 

Parameters(required):dataset=,var=,groupvar=,out=
Parameters(optional):

Sub-macros called: % getlevel % STAT

Data sets created: 
Limitations: 
Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Gives summary information for one continuous variable over the levels of a grouping variable.
 *
 * @param dataset       Input dataset
 * @param var           Variable to be analyzed
 * @param groupvar      Group variable - must have at least 2 levels
 * @param out           Name of output dataset
 */ 
%macro continuoussummary(dataset=, var=, groupvar=, out=);
    %getlevel(&dataset, out=&groupvar._info, factor=&groupvar);
	%count(&groupvar._info,macroout=n_level);
    %DO noflevel=1 %TO &n_level; /*no i*/
        data _null_;
            set &groupvar._info(firstobs=&noflevel obs=&noflevel);
            call symput('currentfac', strip(factorvalue));
        run;

    	data data&noflevel;
        	set &dataset;
        	if &groupvar="&currentfac" then output;
        run;
	%STAT(dataset=data&noflevel, var=&var, outdata=var_&noflevel, outvar=&groupvar._&currentfac);
	%END;

	%STAT(dataset=&dataset, var=&var, outdata=total, outvar=total);

	data &out;
    	merge %range(to=&n_level., opre=var_) total;
    	by statc;
    	length variable $30;
    	variable="&var";
    	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level., opre=var_) %range(to=&n_level., opre=data) new total &groupvar._info;
	quit;
%mend continuoussummary;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 16:20:54*/
