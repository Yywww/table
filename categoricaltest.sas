/*!
 * Give test statistics to a categorical variable
 *
 * @author Yiwen Luo
 * @created Wednesday, August 12, 2015 13:34:40
 */
/********************************************************************************************************************
Macro name: 

Written by: Yiwen Luo

Creation date: Wednesday, August 12, 2015 13:34:41

As of date: 

SAS version: 9.4

Purpose: Give test statistics to a categorical variable

Parameters(required): dataset=,var=,groupvar=,out=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %categoricaltest(dataset=testset,groupvar=vessel_disease,var=stent_num,out=stenttest)

*************************************************************************************************************/
/**
 * Description:
 *
 * @param dataset input dataset
 * @param var variable to be analyzed
 * @param groupvar group variable
 * @param out output dataset
 */ 
%macro categoricaltest_chisq(dataset=,var=,groupvar=,out=);

proc freq data=&dataset order=data;
	tables &groupvar*&var/chisq;
	ods output ChiSq=chisq;
run;


data &out;
	set chisq(firstobs=1 obs=1);
	length variable $30;
	length test $20;
	variable="&var";
	Pvalue=put(Prob, pvalue6.4);
	test='Chi-Square';
	keep variable Pvalue test;
run;

proc datasets library=work nolist nodetails;
	delete chisq;
quit;

%mend categoricaltest;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, August 12, 2015 14:03:27*/













