/*  **************************************************************************************************************  */
/*  **************************************************************************************************************  */
/*      WILL SOON BE DEPRECATED / NO LONGER NEEDED - DIFFERENT MACRO TO TAKE ITS PLACE */
/*  **************************************************************************************************************  */
/*  **************************************************************************************************************  */

/*  *************************************************************************************************************   */
*      Macro Name:                                                                                                  *;
*          Author: C Litherland                                                                                     *;
*    Date Created:                                                                                                  *;
*   File Location: H:\CCL Macros\Macros                                                                             *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose:                                                                                                  *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros:                                                                                                  *;
*           Usage:                                                                                                  *;
*                                                                                                                   *;
* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
*                                                                                                                   *;
*                                                                                                                   *;
* ================================================================================================================= *;
/*  **************************************************************************************************************  */


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

    





%macro bincontable(ds=, ds_dictionary=, groupvar=, out=);
	proc sql number;
	            select strip(variablename)
	            into : varlist
	            separated by ' '
	            from &ds_dictionary
	            where not missing(variablename);
	quit;


/*	proc sql number;*/
/*	            select strip(sastype) into : vartypelist*/
/*	            separated by ' '*/
/*	            from &ds_dictionary*/
/*	            where not missing(variablename);*/
/*	quit;*/

    %getlevel(&ds, out=&groupvar._info, factor=&groupvar);
        %let n_level = %nobs(&groupvar._info);
        %do noflevel=1 %to &n_level;/*no i*/
        data _null_;
        	set &groupvar._info(firstobs=&noflevel obs=&noflevel);
        	call symput('currentfac', factorvalue);
        run;

		data data&noflevel;
    		set &ds;
    		if &groupvar=&currentfac then output;
    	run;
			%do n_var=1 %to %words(&varlist);
		        %let curr_var = %scan(&varlist, &n_var);
    				%put &curr_var;
/*		        %let curr_vartype = %scan(&vartypelist, &n_var);*/
                data _NULL_;
                    set &ds_dictionary;
                    if variableName = "&curr_var" then call symput('curr_vartype', sastype);
                    run;

				%if &curr_vartype = %upcase(continuous) %then %do;
			    %STAT(dataset=data&noflevel, var=&curr_var, outdata=&curr_var, outvar=&groupvar._&noflevel);
				data &curr_var;
					length variable $50;
					set &curr_var;
					variable="&curr_var";
				run;
				%end;
				%if &curr_vartype = %upcase(binary) %then %do;
				%freqgroup(ds=&ds,var=&curr_var,groupvar=&groupvar,index=&currentfac);
				%end;
			%end;
			data group&noflevel;
				set &varlist;
			run;
			proc sort data=group&noflevel;
			by variable statistics;
        %end;

    data &out._merge; 
        	length variable $50;
            merge %range(to=&n_level., opre=group);
            by variable statistics; 
    run;


    proc sql;
        create table &out as
        select dict.pgord, dict.sequence, dict.variabledesc,
               var.*
        from &ds_dictionary as dict
        left join
            &out._merge as var
            on strip(upcase(dict.variablename)) = strip(upcase(var.variable))
        order by dict.pgord, dict.sequence;
    quit;

%mend bincontable;

