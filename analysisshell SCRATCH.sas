

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

Creation date: Thursday, August 13, 2015 16:31:44

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




%macro analysis_shell(dataset=,groupvar=,out=,/*Only these three is required parameters*/
					groupvar_refindex=,
					dictionary=,
					binaryvarlist=,
					continuousvarlist=,
					categoricalvarlist=,
					logrankvarlist=,
					all=YES,
					rot=5);

/*  **************************************************************************************************************  */
/*Get variable list through possible input by user*/


/*Using dictionary*/
%if %length(&dictionary)^=0 %then %do;
proc sql;
			create table variablelist as
			select strip(variablename) as variablename,strip(sastype) as variabletype
            from &dictionary
            where not missing(variablename) and not missing(sastype);
quit;

proc sql;
            select strip(variablename)
            into : varlist
            separated by ' '
			from &dictionary
            where not missing(variablename) and not missing(sastype);
quit;

%end;

/*Using user input variable list*/
%else %if %length(&binaryvarlist)^=0 | %length(&continuousvarlist)^=0 | %length(&categoricalvarlist)^=0 | %length(&logrankvarlist)^=0  %then %do;

data variablelist;
	do i=1 by 1 while(scan("&binaryvarlist",i,' ')^='');
	variablename=scan("&binaryvarlist",i,' ');
	variabletype='binary';
	output;
	end;
	do i=1 by 1 while(scan("&continuousvarlist",i,' ')^='');
	variablename=scan("&continuousvarlist",i,' ');
	variabletype='continuous';
	output;
	end;
	do i=1 by 1 while(scan("&categoricalvarlist",i,' ')^='');
	variablename=scan("&categoricalvarlist",i,' ');
	variabletype='categorical';
	output;
	end;
	do i=1 by 1 while(scan("&logrankvarlist",i,' ')^='');
	variablename=scan("&logrankvarlist",i,' ');
	variabletype='logrank';
	output;
	end;
run;


proc sql;
            select strip(variablename)
            into : varlist
            separated by ' '
			from variablelist
quit;

%end;



%else %if %upcase(&all)=YES %then %do;

%detectvariabletype(&dataset,out=ooo,rot=&rot)
%detectlogrank(ooo,out=varlistwithgroupvar)

data variablelist;
	set varlistwithgroupvar;
	if upcase(TableVar)^=upcase("&groupvar");
	variablename=TableVar;
	if variabletype='categorical variable with three or more levels' then variabletype='categorical';
	if variabletype='continuous variable' then variabletype='continuous';
	if variabletype='binary variable' then variabletype='binary';
	if variabletype='logrank binary' then variabletype='logrank';
	if variabletype in ('binary','continuous','categorical','logrank');
	keep variablename variabletype;
run;

proc sql;
            select strip(variablename)
            into : varlist
            separated by ' '
			from variablelist
quit;

%end;
%else %do;
%put there is no input variable;
%abort;
%end;



/*  **************************************************************************************************************  */


%do n_var=1 %to %words(&varlist);
%let curr_var = %scan(&varlist, &n_var);

data _NULL_;
set variablelist;
if variableName = "&curr_var" then call symput('curr_vartype', variabletype);
run;

%if %upcase(&curr_vartype)=BINARY %then %do;

%binarysummary(ds=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.summary)
%binarytest(dataset=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.test,groupvar_refindex=&groupvar_refindex)

data &curr_var;
	merge &curr_var.summary &curr_var.test;
	by variable;
run;

%end;

%if %upcase(&curr_vartype) = CONTINUOUS %then %do;

%continuoussummary(dataset=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.summary)
%continuoustest(dataset=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.test)

data &curr_var;
	merge &curr_var.summary &curr_var.test;
	by statc;
run;

%end;

%if %upcase(&curr_vartype) = CATEGORICAL %then %do;

%categoricalsummary(dataset=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.summary)
%categoricaltest(dataset=&dataset,groupvar=&groupvar,var=&curr_var,out=&curr_var.test)

data &curr_var;
	set &curr_var.summary &curr_var.test;
run;

%end;

%if %upcase(&curr_vartype) = LOGRANK %then %do;

%logranksummary(dataset=&dataset,groupvar=&groupvar,var=&curr_var,timevar=&curr_var.days,out=&curr_var.summary)
%logranktest(dataset=&dataset,groupvar=&groupvar,var=&curr_var,timevar=&curr_var.days,out=&curr_var.test)

data &curr_var;
	merge &curr_var.summary &curr_var.test;
	by variable;
run;

%end;

/*proc datasets library=work nolist nodetails;*/
/*	delete &curr_var.summary &curr_var.test;*/
/*quit;*/

%end;

data &out;
	set &varlist;
run;

/*proc datasets library=work nolist nodetails;*/
/*	delete &varlist;*/
/*quit;*/

%mend analysis_shell;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, August 13, 2015 11:28:14*/


/* Layout / pseudocode for general analysis shell macro */
/* Purpose - given a list of variables, return summary information by group (if needed), and statistical test results */
/* if requested.  Data should be returned in a dataset that can then be put into a report. */
/*  **************************************************************************************************************  */
/* 1. Accept a list.  (either dictionary, dataset, or list) */
/* 2. For each element in the list, determine the appropriate variable type */
    /* a. dictionary                            */
    /* b. programatically %detectvariabletype   */
    /* c. user supplied list                    */

/*  2b. For each element in the list, generate the summary information in the format requested */
/* -> based on variable type */
/* 3. If p-value is requested - do test (default or specified) */
/* 4. Combine variable summary information with p-value */
/* 5. Combine all variables into final dataset */

/* ** FINAL GOAL ** */
/*analysisshell([R] dataset, groupvar, outputds, */
            /* Dertermine variable type for each element in the list */
/*              a. [default] detectvariabletype*/
/*              b. dictionary=*/
/*              c. {binaryvarlist=, continuousvarlist=, categoricalvarlist=, logrankvarlist= } - user supplied list*/
            /* Generate summary information requested */
/*              a1. statsrequested= - user selected stats (possibly by type) */
/*              a2. {binarysummaryformat=, continuoussumformat=, catsumformat=, logranksumformat=} - user selected format options*/
/*              eg binarysummaryformat=1 => n/N (%) - continuoussummaryformat=*/
            /* alternative ways of specifying variable list */
/*              a. [default] (none - all var in dataset) */
/*              b. dictionary=*/
/*              c. {varlist=, testlist= - takes aligned list of variables and their appropriate test}*/
/*              d. vartest_combined= - takes list of variables followed by appropriate test followed by separator |*/
            /* Return data in appropriate order */
/*              a. dictionary*/
/*              b. (user specified by entry)*/
/*  *****************************************************  */

/* First step: */

/* analysisshell(dataset, groupvar, outputds);*/
/*    a. determine n levels of group var*/
/* for each variable:*/
/*    b. detectvariabletype (automatically) */
/*        1. generate stats summary for variable*/
/*        2. conduct appropriate test*/
/*        3. create variable set (summary + p)*/
/*    c. combine all variable sets*/

/*  *****************************************************  */
/* Macros that will be needed: */
/* detectvariabletype - done*/
/* binarysummary*/
/* binarytest*/
/* categoricalsummary*/
/* categoricaltest*/
/* continuoussummary*/
/* continuoustest*/
/* logranksummary - %km_estimates needs work */
/* logranktest*/
/*  *****************************************************  */
