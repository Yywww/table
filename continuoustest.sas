
/*!
 * Give test statistics of one continuous variable
 *
 * @author Yiwen Luo
 * @created Monday, August 10, 2015 16:26:30
 */
/********************************************************************************************************************
Macro name: continuoustest

Written by: Yiwen Luo

Creation date: Monday, August 10, 2015 16:26:32

As of date: 

SAS version: 9.4

Purpose: Give test statistics of one continuous variable

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description: Give test statistics of one continuous variable
 *
 * @param 
 * @param 
 * @param 
 * @param 
 * @return 
 */ 

%macro continuoustest(dataset=,var=,groupvar=,out=);

%getlevel(&dataset, out=&groupvar._info, factor=&groupvar);

%count(&groupvar._info,macroout=Nofgroupvarlevel)

%if &Nofgroupvarlevel=2 %then %do;

proc ttest data=&dataset;
    	var &var;
    	class &groupvar;
    	ods output TTests=mean_Stats
					Equality=Variance_Stats;
run;

data test_mean;
    	merge mean_Stats Variance_Stats;
		by Variable;
		length test $20;
		if ProbF>0.05 then if Variances="Equal";
					else if Variances="Unequal";
		statc=2;
		Pvalue=put(Probt,PVALUE6.4);
		test='Two Sample T-test';
    	keep Pvalue statc test;
run;

proc npar1way data=&dataset wilcoxon;
    	    var &var;
    		class &groupvar;
    		ods output WilcoxonTest=median_Stats;
run;

data test_median;
    	set median_Stats;
		length test $20;
    	if Name1="PT2_WIL";
    	statc=3;
    	Pvalue=put(nValue1,PVALUE6.4);
		test='Wilcoxon';
    	keep Pvalue statc test;
run;

data &out;
	set test_mean test_median;
	length variable $30;
	variable="&var";
run;

%end;

%else %if &Nofgroupvarlevel>2 %then %do;

proc glm data=&dataset;
	class &groupvar;
	model &var=&groupvar;
	means &groupvar;
	ods output ModelANOVA=ModelANOVA;
run;

data test_mean;
    	set ModelANOVA(firstobs=1 obs=1);
    	statc=2;
		length test $20;
    	Pvalue=put(ProbF,PVALUE6.4);
		test='One-way ANOVA';
    	keep Pvalue statc test;
run;


proc npar1way data = &dataset;
	class &groupvar;
	var &var;
	ods output KruskalWallisTest=KruskalWallisTest;
run;



data test_median;
	set KruskalWallisTest;
	if Name1='P_KW';
	length test $20;
    Pvalue=put(nValue1,PVALUE6.4);
	test='Kruskal Wallis';
	statc=3;
	keep Pvalue test statc;
run;

data &out;
	set test_mean test_median;
	length variable $30;
	variable="&var";
run;

%end;

proc datasets library=work nolist nodetails;
	delete KruskalWallisTest ModelANOVA test_median test_mean &groupvar._info mean_Stats Variance_Stats median_Stats;
run;

%mend continuoustest;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, August 13, 2015 10:08:36*/
