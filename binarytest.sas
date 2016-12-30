/*!
*   Conducts Chisq or Fisher exact test for a binary variable over a grouping variable
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\
*
*   @author
*   @created
*
*/
/*!
 * Give test statistics of one binary variable
 *
 * @author Yiwen Luo
 * @created Monday, August 10, 2015 11:34:31
 */
/********************************************************************************************************************
    Macro name: binarytest
    Written by: Yiwen Luo
 Creation date: Monday, August 10, 2015 09:18:20
    As of date: 
   SAS version: 9.4

              Purpose: Give test statistics of one binary variable
 Parameters(required):dataset=,var=,groupvar=,test=CHISQUARE,groupvar_refindex=,out=
 Parameters(optional):

    Sub-macros called: % getlevel % range
    Data sets created: 
          Limitations: 
                Notes: 

 Sample Macro call: %binarytest(dataset=testset,groupvar=vessel_disease,var=male,out=testtry,groupvar_refindex=1)

*************************************************************************************************************/
/**
 * Description: Give test statistics of one binary variable
 *
 * @param dataset input dataset
 * @param var variable to be analyzed
 * @param groupvar group variable
 * @param groupvar_refindex index for group variable reference
 * @param out output dataset
 */ 


%macro binarytest(dataset=, var=, groupvar=, test=CHISQUARE, groupvar_refindex=, out=);

    proc sort data=&dataset;
        by descending &groupvar descending &var;
    run;

    %getlevel(&dataset, out=groupvar_info, factor=&groupvar);

    /*paired risk ratio and risk difference*/

    data groupvar_info_withoutref;
        set groupvar_info;
    	if factorValue^=&groupvar_refindex;
    run;

    %let nminusone_level = %nobs(groupvar_info_withoutref);

    %DO npair=1 %TO &nminusone_level;/*no i*/
        data _null_;
        	set groupvar_info_withoutref(firstobs=&npair obs=&npair);
        	call symput('currentpair', strip(factorvalue));
        run;

        data pairdat;
        	set &dataset;
        	if &groupvar=&currentpair | &groupvar=&groupvar_refindex;
        run;

        proc freq data=pairdat;
        	tables &groupvar*&var/relrisk riskdiff;
        	ods output RiskDiffCol1=rd RelativeRisks=rr;
        run;

        data rr_string&npair;
        	set rr;
        	length variable $30;
        	length rr_&currentpair.vs&groupvar_refindex $50;
        	if Statistic="Relative Risk (Column 1)";
        	rr_&currentpair.vs&groupvar_refindex=cats(put(Value,best4.),"[",put(LowerCL,best4.),",",put(UpperCL,best4.),"]");
        	variable="&var";
        	keep variable rr_&currentpair.vs&groupvar_refindex;
        run;


        data rd_string&npair;
        	set rd;
        	if Row="Difference";
        	length variable $30;
        	length rd_&currentpair.vs&groupvar_refindex $50;
        	rd_&currentpair.vs&groupvar_refindex=cats(put(Risk,percentn10.2),"[",put(LowerCL,percentn10.2),",",put(UpperCL,percentn10.2),"]");
        	variable="&var";
        	keep variable rd_&currentpair.vs&groupvar_refindex;
        run;
    %END;

    data rrrd;
    	merge %range(to=&nminusone_level, opre=rr_string) %range(to=&nminusone_level, opre=rd_string);
    	by Variable;
    run;


/*overall p-value*/
    %IF test_type = TWOSIDED %THEN %DO;
        %IF %upcase(&test)=FISHER %THEN %DO;
/*        % Fisher;*/
                proc freq data=&dataset order=data;
                	tables vessel_disease*male / chisq fisher;
                	ods output FishersExact=fish;
                run;
                data p_string;
                	set fish;
                	length test $20 variable $30;
                	if name1='XP2_FISH';
                	variable="&var";
                	Pvalue=put(nValue1,pvalue6.4);
                	test='FISHER';
                	keep variable Pvalue statistics;
                run;

        %END;
        %ELSE %IF %upcase(&test)=CHISQUARE %THEN %DO;
/*          % Chisq */
                proc freq data=testset order=data;
                	tables vessel_disease*male/chisq fisher;
                	ods output ChiSq=chi;
                run;
                data p_string;
                	set chi;
                	if Statistic="Chi-Square";
                	length test $20;
                	length variable $30;
                	variable="&var";
                	test="Chi-Square";
                	Pvalue=put(Prob,pvalue6.4);
                	keep variable Pvalue test;
                run;
        %END; 
    %END;

/* */
    %ELSE %DO;
        %PUT The statistic requested is not recognized, please check that the spelling is correct;
        %ABORT;
    %END;

data &out;
	merge rrrd p_string;
	by variable;
run;

proc datasets library=work nolist nodetails;
	delete chi fish groupvar_info Groupvar_info_withoutref pairdat p_string rd rr rrrd %range(to=&nminusone_level, opre=rr_string) %range(to=&nminusone_level, opre=rd_string);
quit;

%mend binarytest;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 15:42:24*/
