/*!
 * gives frenquency, pvalue and one side CI for a continuous variable
 *
 * @author Yiwen Luo
 * @created Tuesday, August 04, 2015 16:08:22
 */

/**
 * Description:
 *
 * @param dataset input dataset
 * @param var     variable to be analyzed
 * @param h0      null hypothesis
 * @return 
 */ 

%macro ttest(dataset=,var=,h0=);

%STAT(dataset=&dataset,var=&var,outdata=table_data_,outvar=Result);
data table_data_;
	set table_data_;
	Variable=upcase("&var");
run;

proc ttest data=analysis  h0=&h0 plots(showh0) alpha=0.025 sides = U;
   Var age;
   ods output TTests=TTests ConfLimits=ConfLimits;
Run;

data OneSideCI;
	set ConfLimits;
	statc=1;
	keep Variable LowerCLMean statc;
run;
data pvalue;
	set TTests;
	statc=1;
	keep Variable Probt statc;
run;

data &var;
	merge table_data_ OneSideCI pvalue;
	by variable statc;
	drop statc;
run;

proc datasets nolist;
	delete Conflimits Onsideci pvalue table_data_ ttests;
quit;

%mend ttest;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, August 05, 2015 10:47:49*/
