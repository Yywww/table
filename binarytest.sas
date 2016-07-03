/*!
*   Conducts Chisq or Fisher exact test for a binary variable over a grouping variable.
*   <br>
*   <b> Macro Location: </b> P:\DataAnalysis\MACRO_IN_PROGRESS\Macros for analysisSummaryLoop
*
*   @author Y Luo
*   @author C Litherland
*   @created 10AUGUST2015
*
*/

/* ******************************************************************************************************************** */
/*    Macro name: binarytest                                                                                            */
/*    Written by: Yiwen Luo                                                                                             */
/* Creation date: Monday, August 10, 2015 09:18:20                                                                      */
/*    As of date:                                                                                                       */
/*   SAS version: 9.4                                                                                                   */
/* Macro Version: 1.2                                                                                                   */
/*              Purpose: Give test statistics of one binary variable                                                    */
/* Parameters(required):dataset=,dependentvar=,groupvar=,test=CHISQUARE,groupvar_refindex=,out=                         */
/* Parameters(optional):                                                                                                */
/*                                                                                                                      */
/*    Sub-macros called: % getlevel % range                                                                             */
/*    Data sets created:                                                                                                */
/*          Limitations:                                                                                                */
/*                Notes:                                                                                                */
/*                                                                                                                      */
/* Sample Macro call: %binarytest(dataset=testset,groupvar=vessel_disease,dependentvar=male,out=testtry,groupvar_refindex=1)*/
/*                                                                                                                      */
/**   --------------------------------------  Revision History -----------------------------------------------------    */
/**   Ref     Date            Author          Reason / Notes                                                            */
/**  [1]      01APRIL2016     Clitherland     add checks for issues that arise with datasets are not created.           */
/* ********************************************************************************************************************** */

/**
 * Gives the appropriate test statistic of one binary variable. 
 *
 * @param dataset input dataset
 * @param dependentvar variable to be analyzed
 * @param groupvar group variable
 * @param groupvar_refindex index for group variable reference
 * @param out output dataset
 */ 


%macro binarytest(dataset=, dependentvar=, groupvar=, groupvar_refindex=0, out=, outputfmt=);
/* CCL Note [01APRIL2016]: Adding documentation macros and logic / data integrity checks */
%MacroNoteToLog;    

/*  ==============================================================================================================  */
/* @section Error Checking.                                                                                         */
/*  ==============================================================================================================  */

    /*dependent variable and group variable can not be the same*/
    %if %upcase(&dependentvar)=%upcase(&groupvar) %then %do;
        %put %str(E)RROR: The groupvar and dependentvar are both &dependentvar.;
        %return;
    %end;
     
    /* * Check that macro parameters are supplied * */
    %if %superq(DATASET)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DATASET.;
        %return;
    %end;
    %if %superq(DEPENDENTVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DEPENDENTVAR.;
        %return;
    %end;
    %if %superq(GROUPVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for GROUPVAR.;
        %return;
    %end;
    %if %superq(GROUPVAR_REFINDEX)=%str() %then %do;
        %put %str(E)RROR: No argument specified for GROUPVAR_REFINDEX.;
        %return;
    %end;
    %if %superq(OUT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;
    /* * Check that the dataset and variables exist * */
    %IF %varexist(ds=&dataset, var=&groupvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &groupvar is not in &dataset.;
        %return;
    %END;
    %IF %varexist(ds=&dataset, var=&dependentvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &dependentvar is not in &dataset.;
        %return;
    %END;
    /* Check that the dependent variable is actually binary. */
    %dstCnt(ds=&dataset, dstvar=&dependentvar, outvar=bincheck);
    %IF &bincheck > 2 %THEN %DO;
        %PUT %str(E)RROR: &dependentvar has more than 2 values - do not use binarytest.;
        %return;
    %END;
    %symdel bincheck / nowarn;

    ods select none;
    
    proc sort data = &dataset;
        by descending &groupvar descending &dependentvar;
    run;

    %getlevel(&dataset, out=groupvar_info, factor=&groupvar);

    /*paired risk ratio and risk difference*/
    data groupvar_info_withoutref;
        set groupvar_info;
    	if factorValue ^= &groupvar_refindex;
    run;

    %count(groupvar_info_withoutref, macroout = nminusone_level);

    %DO npair=1 %TO &nminusone_level;
        data _null_;
        	set groupvar_info_withoutref(firstobs=&npair obs=&npair);
        	call symput('currentpair', strip(factorvalue));
        run;

        data pairdat;
        	set &dataset;
        	if &groupvar=&currentpair | &groupvar=&groupvar_refindex;
			if not missing(&dependentvar);
        run;

		/*check in the pairdat that just created dependentvar have 2 levels*/
		%getlevel(pairdat, out=npairdat1, factor=&dependentvar);
		%getlevel(pairdat, out=npairdat2, factor=&groupvar);

		data _null_;
			set npairdat1;
			call symput('Nofdependlev', NfactorLevel);
		run;

		data _null_;
			set npairdat2;
			call symput('Nofgrouplev', NfactorLevel);
		run;
/* CCL Note [01APRIL2016]: Moved this here - if BOTH RD and RR are not created then enter first loop */
            proc freq data=pairdat;
            	tables &groupvar * &dependentvar / relrisk riskdiff;
            	ods output RiskDiffCol1=rd RelativeRisks=rr;
            run;
        

		%IF &Nofdependlev=1 or &Nofgrouplev=1 or %ds_exist(rd) = 0 or %ds_exist(rr) = 0 %THEN %DO;
        %PUT youre in first loop and npair = &npair;
            %IF %ds_exist(rr)=0 or &Nofdependlev=1 or &Nofgrouplev=1 %THEN %DO;
            %PUT bp1;
            data rr_string&npair;
            	length variable $30;
            	length rr_&currentpair.vs&groupvar_refindex $50;
            	variable="&dependentvar";
    			rr_&currentpair.vs&groupvar_refindex="N/A";
            	keep variable rr_&currentpair.vs&groupvar_refindex;
            run;
            %END;

            %IF %ds_exist(rd)=0 or &Nofdependlev=1 or &Nofgrouplev=1 %THEN %DO;
            %PUT bp2;
    		data rd_string&npair;
            	length variable $30;
            	length rd_&currentpair.vs&groupvar_refindex $50;
            	rd_&currentpair.vs&groupvar_refindex = "N/A";
            	variable = "&dependentvar";
            	keep variable rd_&currentpair.vs&groupvar_refindex;
            run;
            %END;

		%END;

		%IF  (%ds_exist(rd) = 1 or %ds_exist(rr) = 1) & not (&Nofdependlev=1 or &Nofgrouplev=1) %THEN %DO;
        %PUT youre in second loop and npair = &npair;
            %IF %ds_exist(rr)=1 %THEN %DO;
            %PUT bp3;
            data rr_string&npair;
            	set rr;
            	length variable $30;
            	length rr_&currentpair.vs&groupvar_refindex $50;
            	if Statistic="Relative Risk (Column 1)";
            	rr_&currentpair.vs&groupvar_refindex = cat(strip(put(Value, best4.)), " [", 
                                                           strip(put(LowerCL, best4.)), ", ",
                                                           strip(put(UpperCL, best4.)), "]");
            	variable="&dependentvar";
            	keep variable rr_&currentpair.vs&groupvar_refindex;
            run;
            %END;

            %IF %ds_exist(rd)=1 %THEN %DO;
            %PUT bp4;
            data rd_string&npair;
            	set rd;
            	if Row = "Difference";
            	length variable $30;
            	length rd_&currentpair.vs&groupvar_refindex $50;
            	rd_&currentpair.vs&groupvar_refindex = cat(strip(put(Risk, percentn10.2)), " [", 
                                                           strip(put(LowerCL, percentn10.2)), ", ", strip(put(UpperCL, percentn10.2)), "]");
            	variable = "&dependentvar";
            	keep variable rd_&currentpair.vs&groupvar_refindex;
            run;
            %END;
		%END;
    %END;

    data rrrd;
    	merge %range(to=&nminusone_level, opre=rr_string) %range(to=&nminusone_level, opre=rd_string);
    	by Variable;
    run;

    /*overall p-value*/
    /*Check if dependentvar only have one level*/

    %getlevel(&dataset, out=nalldat, factor=&dependentvar);

		data _null_;
			set nalldat;
			call symput('Ndependlev', NfactorLevel);
		run;

	%IF &Ndependlev=1 %THEN %DO;
        data p_string;
          	length test $20 variable $30 Pvalue $20;
            variable = "&dependentvar";
            test = "N/A";
            Pvalue = "N/A";
            keep variable Pvalue test;
        run;

		data &out;
			merge rrrd p_string;
			by variable;
		run;
	%END;

	%ELSE %DO;
    /*Chech if min cell count is greater than 5*/
    	proc freq data = &dataset;
    	   table &groupvar * &dependentvar;
    	   ods output CrossTabFreqs = forcellcount;
    	run;

    	proc sql;
    	    select min(Frequency), max(Frequency)
    	    into :min_cellcount, :max_cellcount
    	    from forcellcount;
    	quit;
    	
        %IF &max_cellcount^=0 %THEN %DO;
        	%IF &min_cellcount<5 %THEN %DO;
                /* % Fisher;*/
                proc freq data = &dataset order = data;
                    tables &groupvar * &dependentvar / fisher;
                    ods output FishersExact = fish;
                run;
                data p_string;
                    length test $20 variable $30 Pvalue $20;
                    set fish;
                    if name1 = 'XP2_FISH';
                    variable = "&dependentvar";
                    Pvalue = put(nValue1, pvalue6.4);
                    test = 'FISHER';
                    keep variable Pvalue test;
                run;
              %END;
              %ELSE %DO;
                /*  % Chisq */
                    proc freq data=&dataset order=data;
                        tables &groupvar*&dependentvar/ fisher;
                        ods output ChiSq=chi;
                    run;
                    data p_string;
                        length test $20 variable $30 Pvalue $20;
                        set chi;
                        if Statistic = "Chi-Square";
                        variable = "&dependentvar";
                        test = "Chi-Square";
                        Pvalue = put(Prob, pvalue6.4);
                        keep variable Pvalue test;
                    run;
                %END; 
        	data &out;
        		merge rrrd p_string;
        		by variable;
        	run;
            %END;
        %ELSE %DO;
        	data &out;
             	length test $20 variable $30 Pvalue $20;
        		variable = "&dependentvar";
        		test = 'N/A';
        		Pvalue = 'N/A';
        	run;
        %END;
    %END;

proc datasets library=work nolist nodetails;
	delete chi fish groupvar_info Npairdat Nalldat Groupvar_info_withoutref forcellcount pairdat p_string rd 
           rr rrrd %range(to=&nminusone_level, opre=rr_string) %range(to=&nminusone_level, opre=rd_string);
quit;

/* CCL Note [01APRIL2016]: Delete global macro variables created. */
    %SYMDEL nminusone_level; 

    ods select all;

%mend binarytest;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 */
