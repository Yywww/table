/*!
* Give test statistics of one continuous variable
*
*   <br>
*   <b> Macro Location: </b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\

* @author Yiwen Luo
* @created Monday, August 10, 2015 16:26:30
*/
/********************************************************************************************************************
Macro name: continuoustest

Written by: Yiwen Luo

Creation date: Monday, August 10, 2015 16:26:32

SAS version: 9.4

File Location: P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacro

Validated By:

Date Validated:

Purpose: Give test statistics of one continuous variable

Parameters(required):	dataset=
						dependentvar=
						groupvar=
						out=

Parameters(optional):	outputfmt=

Sub-macros called: %getlevel %count

Data sets created: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
 
 
/**
*   {Macro Description}.
*
*   @param dataset       Input dataset name
*   @param dependentvar  variable need to analyze
*   @param groupvar      group variable
*   @param out			 output dataset name
*   @param outputfmt     output format
*
*   @return
*
*/


%macro continuoustest(dataset=,dependentvar=,groupvar=,out=,outputfmt=);
%MacroNoteToLog; 
%getlevel(&dataset, out=&groupvar._info, factor=&groupvar);

%count(&groupvar._info,macroout=Nofgroupvarlevel)

/*Test Normality*/
proc univariate data=&dataset normal;
var &dependentvar;
ods output TestsForNormality=TestsForNormality;
run;

data _null_;
	set TestsForNormality(where=(Test='Kolmogorov-Smirnov'));
	call symput('p_value',pValue);
run;

/*According to number of groups and normality test, use appropriate test*/

%if &Nofgroupvarlevel=2 %then %do;

	%if &p_value>0.05 %then %do;
		proc ttest data=&dataset;
		    	var &dependentvar;
		    	class &groupvar;
		    	ods output TTests=mean_Stats
							Equality=Variance_Stats;
		run;

		data &out;
				length test $20 variable $30 Pvalue $20;
		    	merge mean_Stats Variance_Stats;
				by Variable;
				statc=3;
				if ProbF>0.05 then if Variances="Equal";
							else if Variances="Unequal";
				Pvalue=put(Probt,PVALUE6.4);
				test='Two Sample T-test';
				variable="&dependentvar";
		    	keep Pvalue variable test statc;
		run;

	%end;

	%else %do;

		proc npar1way data=&dataset wilcoxon;
		    	    var &dependentvar;
		    		class &groupvar;
		    		ods output WilcoxonTest=median_Stats;
		run;

		data &out;
				length test $20 variable $30 Pvalue $20;
		    	set median_Stats(drop=variable);
		    	if Name1="PT2_WIL";
				statc=2;
		    	Pvalue=put(nValue1,PVALUE6.4);
				test='Wilcoxon';
				variable="&dependentvar";
		    	keep Pvalue variable test statc;
		run;

	%end;

%end;

%else %if &Nofgroupvarlevel>2 %then %do;

	%if &p_value>0.05 %then %do;
		proc glm data=&dataset;
			class &groupvar;
			model &dependentvar=&groupvar;
			means &groupvar;
			ods output ModelANOVA=ModelANOVA;
		run;

		data &out;
			length test $20 variable $30 Pvalue $20;
		    set ModelANOVA(firstobs=1 obs=1);
		    statc=3;
		    Pvalue=put(ProbF,PVALUE6.4);
			test='One-way ANOVA';
			variable="&dependentvar";
		    keep Pvalue variable test statc;
		run;
	%end;
	%else %do;

		proc npar1way data = &dataset;
			class &groupvar;
			var &dependentvar;
			ods output KruskalWallisTest=KruskalWallisTest;
		run;

		data &out;
			length test $20 variable $30 Pvalue $20;
			set KruskalWallisTest(drop=variable);
			if Name1='P_KW';
			statc=2;
		    Pvalue=put(nValue1,PVALUE6.4);
			test='Kruskal Wallis';
			variable="&dependentvar";
			keep Pvalue test variable statc;
		run;

	%end;
%end;

proc datasets library=work nolist nodetails;
	delete KruskalWallisTest ModelANOVA test_median test_mean &groupvar._info mean_Stats Variance_Stats median_Stats;
run;

%symdel Nofgroupvarlevel/ nowarn;

%mend continuoustest;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, August 13, 2015 10:08:36*/
