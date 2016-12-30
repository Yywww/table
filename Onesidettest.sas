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

Creation date: 

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
%macro Onesidettest(dataset=,h0=,alpha=,side=)
/*side: 
	1)'2'  specifies two-sided tests and confidence intervals for means
	2)'L'  specifies lower one-sided tests, in which the alternative hypothesis indicates a mean less than the null value, and lower one-sided confidence intervals between minus infinity and the upper confidence limit.
	3)'U'  specifies upper one-sided tests, in which the alternative hypothesis indicates a mean greater than the null value, and upper one-sided confidence intervals between the lower confidence limit and infinity.*/
proc ttest data=&dataset h0=&h0 plots(showh0) sides=&side alpha=&alpha;
var &outcomevar;
ods output ttests=ttests;
run;

data &groupvar._&currentfac._test;
set ttests;
length group $20 comparison1 $30;
group = "&groupvar";
comparison1 = "&groupvar._&currentfac";
Pvalue=put(Probt, pvalue6.4);
keep comparison1 group pvalue;
run;
