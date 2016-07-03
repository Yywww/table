/*!
 * This macro tests the difference of a continuous variable over a grouping variable with 2 levels.
 *
 * @author Yiwen Luo
 * @created November 09, 2015 
 */
/********************************************************************************************************************
Macro name: continuous_test_ttest2side
Written by: Yiwen Luo
Creation date: November 09, 2015 

As of date: 

SAS version: 9.4

Purpose: continuous variable test for two group data

Parameters(required):dataset=, dependentvar=, groupvar=, out=, outputfmt=
Parameters(optional):

Sub-macros called: %count

Data sets created: 
Limitations: 

Notes: 
Sample Macro call: %continuous_test_ttest2side(dataset=adapt.regdata, dependentvar=age, groupvar=cauc, out=oooout, outputfmt=notreallymatterrightnow)

*************************************************************************************************************/


	/********************************************************************************************************************
	Example code:
	%INCLUDE "P:\DataAnalysis\MACRO_LIB\CRF Macro Library\UtilityMacros\CRFAssignMacroLibraries.SAS";
	libname adapt "P:\DataAnalysis\ADAPT DES\2 Year FU\AnalysisDatasets";
	%continuous_test_ttest2side(dataset=adapt.regdata, dependentvar=age, groupvar=cauc, out=oooout, outputfmt=notreallymatterrightnow);
	End of Example code
	*************************************************************************************************************/


/**
 * Description: continuous variable test for two group data
 *
 * @param dataset input dataset
 * @param dependentvar variable to be analyzed, a continuous variable
 * @param groupvar group variable that used to divide dataset into two groups
 * @param out output dataset name
 * @return an dataset contains three column: variablename, testname, p-value
 */ 


%macro continuous_test_ttest2side(dataset=, dependentvar=, groupvar=, out=, outputfmt=);
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
/*  *****************************************************  */

	%count(&dataset, macroout=nobs);
	/*	check if number of obs is over 2000, if over then use Anderson-Darling, otherwise use Shapiro-Wilk*/
	%IF %EVAL(&nobs < 1999) %THEN %DO;
		ods output TestsForNormality = normal_test(where=(test="Shapiro-Wilk"));
		proc univariate data = &dataset normal;
			var &dependentvar;
		run;
		%put The test used to check normality is Shapiro-Wilk;
	%END;

	%ELSE %DO;
		ods output TestsForNormality = normal_test(where=(test="Anderson-Darling"));
		proc univariate data = &dataset normal;
			var &dependentvar;
		run;
		%put The test used to check normality is Anderson-Darling;
	%END;


	/*	Extract p-value*/
	data _null_;
		set normal_test;
		call symput('normp', pvalue);
	run;


	/* IF NORMAL */
	%IF %EVAL(&normp > 0.05) %THEN %DO;

		proc sort data=&dataset;
			by &groupvar;
		run;

		proc ttest data=&dataset sides=2 alpha=0.05 h0=0;;
			class &groupvar;
			var &dependentvar;
			ods output TTests = mean_Stats
			           Equality = Variance_Stats;
		run;

		/*check if two sample variance are equal then extract pvalue accordingly*/
		data &out;
			merge mean_Stats Variance_Stats;
			by Variable;
			length test $ 20 Variances $ 10;
			if ProbF > 0.05 then Variances = "Equal";
						else Variances = "Unequal";
			Pvalue = put(Probt, PVALUE6.4);
			test = 'Two Sample T-test';
			variable = "&dependentvar";
			keep Pvalue test variable;
		run;

		proc datasets nolist library=work;
			delete mean_Stats Variance_Stats;
		quit;

	%END;


	/* If NON-NORMAL */
	%ELSE %IF %EVAL(&normp <= 0.05) %THEN %DO;

		proc npar1way data=&dataset wilcoxon;
			var &dependentvar;
			class &groupvar;
			ods output KruskalWallisTest=KruskalWallisTest;
		run;

		data &out;
			set KruskalWallisTest;
			length test $20;
			if Name1="P_KW";
			statc=3;
			Pvalue=put(nValue1,PVALUE6.4);
			test='Kruskal Wallis';
			variable="&dependentvar";
			keep Pvalue test variable;
		run;


	/*delete dataset created during the macro*/
		proc datasets nolist library=work;
			delete KruskalWallisTest;
		quit;

	%END;


	proc datasets nolist library=work;
		delete normal_test;
	quit;

ODS select ALL;

%mend continuous_test_ttest2side;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, November 09, 2015 18:50:02*/
