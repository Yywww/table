/*!
 * Create summary statistics for categorical variables over some grouping variable.
 * <br>
 * <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
 *
 * @author Yiwen Luo
 * @author CLitherland
 * @created Tuesday, August 11, 2015 
 * 
 */

/********************************************************************************************************************
    Macro name: categoricalsummary
    Written by: Yiwen Luo
 Creation date: Tuesday, August 11, 2015 10:14:51
    As of date: 
   SAS version: 9.4

              Purpose: Creates summary of categorical variable by groups
 Parameters(required): dataset=
                       var=
                       groupvar= 
                       out=
 Parameters(optional):

    Sub-macros called: % getlevel % count % binarysummary % range
    Data sets created:  
          Limitations: 
                Notes: 

 Sample Macro call: % categoricalsummary(dataset=testset,groupvar=vessel_disease,var=stent_num,out=stent)

*************************************************************************************************************/

/**
 * Returns a dataset containing summary statistics for a categorical variable (n/N %) for each level of a grouping variable.
 *
 * @param dataset       Input dataset
 * @param groupvar      Group variable - can have 2+ levels
 * @param var           Categorical variable to be analyzed
 * @param out           Output dataset
 * 
 */ 

%macro categoricalsummary(dataset=, dependentvar=, groupvar=, out=, outputfmt=);

	%getlevel(&dataset, out=catevarinfo, factor=&dependentvar)

	%count(catevarinfo, macroout=Nlevelofcate)

    /* Loops over levels of categorical variable to get summaries */
	%DO catei=1 %TO &Nlevelofcate;

        data _null_;
    		set catevarinfo(firstobs=&catei obs=&catei);
    		call symput('currentcatefac', factorvalue);
    	run;

    	data dummy;
    		set &dataset;
    		if &dependentvar = &currentcatefac then dummy=1;
    		else dummy=0;
    		keep &groupvar dummy;
    	run;

    	proc sort data=dummy;
    		by descending dummy desending &groupvar;
    	run;

    	%binarysummary(dataset=dummy, dependentvar=dummy, groupvar=&groupvar, out=out, outputfmt=)

    	data cate&catei;
    		set out;
    		length variable $30;
    		variable="&dependentvar";
    		category="&currentcatefac";
    	run;
	%END;


	data &out;
		set %range(to=&Nlevelofcate, opre=cate);
	run;

    /* Delete intermediate datasets and clear global macro variables */
	proc datasets library=work nolist nodetails;
		delete %range(to=&Nlevelofcate, opre=cate) out dummy catevarinfo;
	quit;

    %symdel Nlevelofcate / nowarn;

%MEND;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Tuesday, August 11, 2015 11:25:20*/
