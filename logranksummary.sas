/*!
*   Summarized time to event variables by KM estimates and n failed
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
*
*   @author     CLitherland
*   @created    01SEPTEMBER2015
*
*/

/********************************************************************************************************************
    Macro name: logranksummary
    Written by: Yiwen Luo
 Creation date: Wednesday, August 12, 2015 
    As of date: 
   SAS version: 9.4

              Purpose: Give summary information about a logrank variable
 Parameters(required): dataset=
                       var=
                       timevar=
                       censor_val = 0
                       groupvar=
                       out=
 Parameters(optional):

    Sub-macros called: % getlevel % range
    Data sets created: 
          Limitations: 
                Notes: 

Sample Macro call: % logranksummary(dataset=testset, var=mace, timevar=macedays, groupvar=vessel_disease, out=mace)

*************************************************************************************************************/
/**
 * Returns dataset with KM estimates for time to event variable by a group variable(THis macro is for %varloop to use)
 *
 * @param dataset       Input dataset
 * @param groupvar      Group variable
 * @param timevar       Variable containing time to event 
 * @param var           Variable indicating event or censor
 * @param censor_val    Value of VAR indicating censor - default to 0
 * @param out           Output dataset
 * 
 */ 


%macro logranksummary(dataset=, dependentvar=, groupvar=, out=,outputfmt=);

	%MacroNoteToLog; 

	%let timevar=&dependentvar.days;
    ods output ProductLimitEstimates=lrfreqg;
	proc lifetest data=&dataset method=km;
		time &timevar * &dependentvar(0);
		strata &groupvar;
	run;

    ods output ProductLimitEstimates=lrfreqt;
	proc lifetest data=&dataset method=km;
		time &timevar * &dependentvar(0);	
	run;

	%getlevel(&dataset, out=&groupvar._info, factor=&groupvar);
/*	%LET n_level = %nobs(&groupvar._info);*/
	%count(&groupvar._info,macroout=n_level)
	%DO noflevel = 1 %TO &n_level;
	    data _null_;
	        set &groupvar._info(firstobs=&noflevel obs=&noflevel);
	        call symput('currentfac', strip(factorvalue));
	    run;

		data logrank_&noflevel;
			set lrfreqg(where=(Failure^=. and &groupvar=&currentfac)) end=lastobs;
			if lastobs;
			length variable $30 statistics $50;
			&groupvar._&currentfac = cat(strip(put(Failure, percent10.1)), ' (', strip(put(Failed, 8.)), ')');
			statistics = "%(N)";
			variable = "&dependentvar";
			keep variable &groupvar._&currentfac statistics;
		run;
	%END;

	data logrank_total;
		set lrfreqt(where=(Failure^=.)) end=lastobs;
		if lastobs;
		length variable $30 statistics $50;
		total = cat(strip(put(Failure, percent10.1)), ' (', strip(put(Failed, 8.)), ')');
		statistics = "%(N)";
		variable = "&dependentvar";
		keep total variable statistics;
	run;

	data &out;
		merge %range(to=&n_level,opre=logrank_) logrank_total;
		by variable;
	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level,opre=logrank_) logrank_total lrfreqg lrfreqt &groupvar._info;
    run;
	quit;
%mend ;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Friday, November 20, 2015 14:21:14*/
