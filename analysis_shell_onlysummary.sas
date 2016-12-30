/*!
*   {Macro Description}
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\
*
*   @author     YLuo
*   @created    13AUGUST2015
*
*/

/*!
 * Gives both summary and test information regarding all of input variable by group variable
 *
 * @author Yiwen Luo
 * @created Thursday, August 13, 2015 17:12:24
 */
/********************************************************************************************************************
            Macro name: 
            Written by: Yiwen Luo
         Creation date: Thursday, August 13, 2015 16:31:44
            As of date: 
           SAS version: 9.4

               Purpose: Takes a dataset and a grouping variable and generates summary statistics, computes p-value
                        and returns a dataset that contains those.
  Parameters(required): dataset =
                        groupvar = 
                        out = 
  Parameters(optional): 
                        groupvar_refindex - value of group variable to be used as reference in pairwise comparisons
                        dictionary - if specified, dictionary to use as the list of variables of sastype
                                     If used the dictionary **MUST** follow the standard template, having 
                                        VariableName and SASType

                Varlist parameters are alternatives to Dictionary to specify variables to summarize and compare:
                        binaryvarlist - list of binary variables to summarize (return n and percent) and test 
                        continuousvarlist - list of continuous variables to summarize (n, mean +- SD, Median [Q1, Q3],
                                            (Max, Min), 95% CI) and test
                        categoricalvarlist - 
                        logrankvarlist -
                        
                        ALL - if YES, then summarize all the variables in the input dataset - only used if
                              NEITHER dictionary nor varlists are given.
                        rot - Used if ALL = YES, number of levels of a variable to distinguish between categorical
                              and continuous
                                            
     Sub-macros called: % MacroNoteToLog
                        % word
                        % detectvariabletype
                            % count
                            % GetMaxLen
                        % detectlogrank
                            % count
                        % binarysummary
                            % getlevel
                            % freqgroup *poss change to binarysummary_stat
                            % count
                            % range
                        % binarytest
                            % getlevel
                            % range
                        % categoricalsummary
                        % categoricaltest
                        % continuoussummary
                        % continuoustest
                        % logranksummary
                        % logranktest
                        % label_ds 
     Data sets created: 

           Limitations: 
                 Notes: 

     Sample Macro call: 

*************************************************************************************************************/
/**
 * Description:Gives both summary and test information regarding all of input variable by group variable
 *
 * @param <param-name> <param-description>
 * @param 
 * @param 
 * @param 
 * @return 
 */ 


%MACRO analysis_shell_onlysummary(dataset = ,
                      groupvar = ,
                      out = ,
                       /*Only these three is required parameters*/
					groupvar_refindex=,
					dictionary=,
					binaryvarlist=,
					continuousvarlist=,
					categoricalvarlist=,
					logrankvarlist=,
					all=YES,
					rot=5,
                    test_type=TWOSided);
/*  **************************************************************************************************************  */
/*Get variable list through possible input by user*/


    /*Using dictionary*/
    %IF %length(&dictionary)^=0 %THEN %DO;
        proc sql;
        	create table variablelist as
        	select strip(variablename) as variablename, strip(sastype) as variabletype
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
    %END;

    /* If no dictionary, using user input variable list */
    %ELSE %IF %length(&binaryvarlist)^=0 | %length(&continuousvarlist)^=0 | %length(&categoricalvarlist)^=0 | %length(&logrankvarlist)^=0  %THEN %DO;
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
    %END;



    %ELSE %IF %upcase(&all)=YES %THEN %DO;
        /* Macros to dectect variable types - detectlogrank uses the output dataset of detect variable type. */
        %detectvariabletype(&dataset, out=ooo, rot=&rot)
        %detectlogrank(ooo, out=varlistwithgroupvar)

        data variablelist;
        	set varlistwithgroupvar;
        	if upcase(TableVar)^=upcase("&groupvar");
        	variablename=TableVar;
        	if upcase(variabletype) = 'CATEGORICAL VARIABLE WITH THREE OR MORE LEVELS' then variabletype = 'CATEGORICAL';
        	if upcase(variabletype) = 'CONTINUOUS VARIABLE'                            then variabletype = 'CONTINUOUS';
        	if upcase(variabletype) = 'BINARY VARIABLE'                                then variabletype = 'BINARY';
        	if upcase(variabletype) = 'LOGRANK BINARY'                                 then variabletype = 'LOGRANK';
        	if variabletype in ('BINARY','CONTINUOUS','CATEGORICAL','LOGRANK');
        	keep variablename variabletype;
        run;

        proc sql;
            select strip(variablename)
            into : varlist
            separated by ' '
        	from variablelist
        quit;
    %END;

    /* If no variable input list is given, put note to log and stops either this macro or SAS... Check on that. */
    %ELSE %DO;
    %PUT there is no input variable;
    %ABORT;
    %END;

/*  **************************************************************************************************************  */
    /* Loop over variable list and generate summary and tests by variable types */
    %DO n_var=1 %TO %words(&varlist);
        %LET curr_var = %scan(&varlist, &n_var);
        %PUT &curr_var;
            data _NULL_;
                set variablelist;
                if variableName = "&curr_var" then call symput('curr_vartype', variabletype);
            run;

        /*  *****************************************************  */
        /*  ** Summary and tests of BINARY variables **  */
        %IF %upcase(&curr_vartype)=BINARY %THEN %DO;

            %binarysummary(ds=&dataset, groupvar=&groupvar, var=&curr_var, out=&curr_var)


        %END;

        /*  *****************************************************  */
        /* ** Summary and tests of CONTINUOUS variables ** */
        %IF %upcase(&curr_vartype) = CONTINUOUS %THEN %DO;

            %continuoussummary(dataset=&dataset, groupvar=&groupvar, var=&curr_var, out=&curr_var)
  
        %END;
        
        /*  *****************************************************  */
        /* ** Summary and tests of CATEGORICAL variables ** */
        %IF %upcase(&curr_vartype) = CATEGORICAL %THEN %DO;

            %categoricalsummary(dataset=&dataset, groupvar=&groupvar, var=&curr_var, out=&curr_var)
    

        %END;

        /*  *****************************************************  */
        /* ** Summary and tests of LOGRANK variables ** */
        %IF %upcase(&curr_vartype) = LOGRANK %THEN %DO;

            %logranksummary(dataset=&dataset, groupvar=&groupvar, var=&curr_var, timevar=&curr_var.days, out=&curr_var)
   

        %END;


    %END;

    data &out;
    length variable $ 30 category $ 12 statistics $ 20;
    	set &varlist;
    run;

    %label_ds(&out, file_name=%pgmname);

    /*    data &out;*/
    /*    	retain variable category statistics;*/
    /*    	set &out;*/
    /*    	drop statc;*/
    /*    run;*/

    /* Delete intermediate datasets  */
    proc datasets library=work nolist nodetails;
    	delete &varlist ooo variablelist varlistwithgroupvar;
    quit;

%MEND analysis_shell;

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
