/********************************************************************************************************************
Macro name: continus_firstdraft

Written by: Yiwen Luo

Creation date: Jun03 2015

As of date: 

SAS version: 9.4

Purpose: give all statistics result about one continuous variable by one group variable.

Parameters(required):dataset=,var=,groupvar=,
 
Parameters(optional):groupvari=1

Sub-macros called: %stat

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %continuous(dataset=analysis,var=age,groupvar=diabetes,groupvari=1)

*************************************************************************************************************/

%macro continuous(dataset=, var=, groupvar=, use=1);
    %PUT %STR(**********************************************************************************************************);
    %PUT ;
    %PUT Macro Name: %pgmname ;
    %PUT Run By: %SYSGET(USERNAME) On &sysdate at &systime;
    %PUT This macro is NOT Validated.;
    %PUT ;
    %PUT %STR(**********************************************************************************************************);
/*  *****************************************************  */

%if &use=1 %then %do; 
   
    %getlevel(&dataset, out=&groupVar._info, factor=&groupvar);
    %LET n_level = %nobs(&groupVar._info);

    %DO i=1 %TO %nobs(&groupVar._info);
    data _null_;
    	set &groupvar._info(firstobs=&i obs=&i);
    	call symput('currentfac', factorValue);
    run;

    data data&i.;
    	set &dataset;
    	if &groupvar=&currentfac then output;
    run;

    /*% STAT gives the statistics information for each variable of interest */
    %STAT(dataset=data&i., var=&var., outdata=TableDat_&i., outvar=&groupvar._&i);

    %END;

%end;

%STAT(dataset=&dataset, var=&var, outdata=tableDat_tot, outvar=Total);

/*proc ttest data=&dataset;*/
/*    	var &var;*/
/*    	class &groupvar;*/
/*    	ods output TTests=mean_Stats*/
/*					Equality=Variance_Stats;*/
/*run;*/

/*data test_mean_4;*/
/*    	merge mean_Stats Variance_Stats;*/
/*		by Variable;*/
/*		if ProbF>0.05 then if Variances="Equal";*/
/*					else if Variances="Unequal";*/
/*		statc=3;*/
/*		Pvalue=put(Probt,PVALUE6.4);*/
/*    	keep Pvalue statc;*/
/*run;*/

/*proc npar1way data=&dataset wilcoxon;*/
/*    	    var &var;*/
/*    		class &groupvar;*/
/*    		ods output WilcoxonTest=median_Stats;*/
/*run;*/

/*data test_median_5;*/
/*    	set median_Stats;*/
/*    	if Name1="PT2_WIL";*/
/*    	statc=2;*/
/*    	Pvalue=put(nValue1,PVALUE6.4);*/
/*    	keep Pvalue statc;*/
/*run;*/


data &var; 
    	length variable $50;
        merge %range(to=&n_level., opre=tableDat_) tableDat_tot;
/*        merge table_data_1 table_data_2 table_data_3 test_mean_4 test_median_5; */
        by statc; 
        variable="&var"; 
		drop statc;
run;


proc datasets library=work;
	delete %range(to=&n_level., opre=tableDat_) tabledat_tot;
/*test_mean_4 test_median_5 Mean_stats Median_stats Variance_stats;*/
quit;

%mend continuous;


