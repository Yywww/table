/*!
 * give binomial test result for binary variable
 *
 * @author Yiwen Luo
 * @created Tuesday, August 18, 2015 09:40:10
 */
/********************************************************************************************************************
Macro name: Binomial

Written by: Yiwen Luo

Creation date: Tuesday, August 18, 2015 09:42:14

As of date: 

SAS version: 9.4

Purpose: give binomial test result for binary variable

Parameters(required):dataset=,var=,h0=,out=
 
Parameters(optional):alpha=0.05

Sub-macros called: 

Data sets created: 

Limitations: Only two side now

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description:give binomial test result for binary variable
 *
 * @param dataset input dataset name
 * @param var name of variable to be analyzed
 * @param h0 null hypethesis to test
 * @param out output dataset name
 * 
 */ 


%MACRO binomial(dataset=,var=,h0=,out=,alpha=0.05)

proc freq data=testset;
	tables male / binomial(p=0.8);
	exact binomial/alpha=&alpha;
	ods output BinomialTest=BinomialTest;
run;

data &out;
	length variable $30;
	set BinomialTest;
	if Name1='XP2_BIN';
	Pvalue=put(cValue1,pvalue6.4);
	variable="&var";
	h0=&h0;
	Test='Binomial Two-Side Test';
run;

%MEND;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Tuesday, August 18, 2015 10:36:31*/







