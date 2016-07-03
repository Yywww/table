/*!
 * Give summary information of one continuous variable by group.
*   <br>
 * <b> Macro Location: </b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros  
 *
 * @author Yiwen Luo	
 * @created August 10, 2015 
 */
/********************************************************************************************************************
Macro name: continuoussummary
Written by: Yiwen Luo
Creation date: Monday, August 10, 2015 15:42:02
SAS version: 9.4

File Location: P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
Validated By:
Date Validated:

Purpose: Give summary information of one continuous variable over 
Parameters(required):dataset=,var=,groupvar=,out=
Parameters(optional):outputfmt=
Sub-macros called: % getlevel % STAT %range

Data sets created: 
Notes: 
Sample Macro call: 

*************************************************************************************************************/
/**
 * Gives summary information for one continuous variable over the levels of a grouping variable.
 *
 * @param dataset       Input dataset
 * @param dependentvar           Variable to be analyzed
 * @param groupvar      Group variable - must have at least 2 levels
 * @param out           Name of output dataset
 * @param outputfmt           Name of output dataset
 */ 
%macro continuoussummary(dataset=, dependentvar=, groupvar=, out=, outputfmt=);
%MacroNoteToLog; 

  ods select NONE;
/*  ==============================================================================================================  */
/* @section Error checks                                                                                            */
/*  ==============================================================================================================  */
    %if %superq(DATASET)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DATASET.;
        %return;
    %end;
    %if %superq(GROUPVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for GROUPVAR.;
        %return;
    %end;
    %if %superq(DEPENDENTVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DEPENDENTVAR.;
        %return;
    %end;
    %if %superq(OUT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;
    %IF %varexist(ds=&dataset, var=&groupvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &groupvar is not in &dataset.;
        %return;
    %END;
    %IF %varexist(ds=&dataset, var=&dependentvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &dependentvar is not in &dataset.;
        %return;
    %END;
    /* Check how many distinct values the dependent variable has. */
    %dstCnt(ds=&dataset, dstvar=&dependentvar, outvar=continuouscheck);
        %PUT %str(N)OTE: &dependentvar has &continuouscheck distinct values;
    %symdel continuouscheck / nowarn;



/*Detect how many levels group variable have*/
    %getlevel(&dataset, out=&groupvar._info, factor=&groupvar);
	%count(&groupvar._info, macroout=n_level);

/*Loop through all levels, eaach loop create a summary statistisc of subgroup*/
	%DO noflevel=1 %TO &n_level; /*no i*/
        data _null_;
            set &groupvar._info(firstobs=&noflevel obs=&noflevel);
            call symput('currentfac', strip(factorvalue));
        run;

    	data data&noflevel;
        	set &dataset;
        	if &groupvar="&currentfac" then output;
        run;
	%STAT(dataset=data&noflevel, var=&dependentvar, outdata=var_&noflevel, outvar=&groupvar._&currentfac);
	%END;

/*This is summary statistics for total*/
	%STAT(dataset=&dataset, var=&dependentvar, outdata=total, outvar=total);

/*Merge all summary table*/
	data &out;
    	merge %range(to=&n_level., opre=var_) total;
    	by statc;
    	length variable $30;
    	variable="&dependentvar";
    	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level., opre=var_) %range(to=&n_level., opre=data) new total &groupvar._info;
	quit;

    %symdel n_level / nowarn;
    ods select all;
%mend continuoussummary;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 16:20:54*/
