/*!
 * Execute user assigned macro loop over a list of variables
 * <br>
 * <b> Macro Location: 
 *
 * @author Yiwen Luo
 * @created Monday, November 30, 2015 19:02:15
 */
/********************************************************************************************************************
    Macro name: analysisSummaryLoop
    Written by: Yiwen Luo
    Creation date: Tuesday, August 18, 2015 14:23:41
    As of date: 
    SAS version: 9.4

    Purpose: execute user assigned macro loop over a list of variables
    Parameters(required):	dataset=
							varlist=
							groupvar=
							out=
							summary_macro=
    Parameters(optional):
							varexclude=
							out=
							analysis_macro=
							outputfmt=
    Sub-macros called: % count

    Data sets created: 
          Limitations: 
                Notes: To see what macros can loop in this macro, please read guideline file.

    Sample Macro call: 

*************************************************************************************************************/
/**
 * Execute user assigned macro loop over a list of variables
 *
 * @param dataset       	Input dataset name
 * @param varlist       	variables need to summarize and analyze
 * @param varexclude		variables that in the variable list which result are not required
 * @param groupvar			group variable
 * @param out				name of output dataset
 * @param summary_macro 	macro that used to output summary result
 * @param analysis_macro	macro that used to output analysis result
 * @param outputfmt			output format. see guideline file for more information
 */ 








%macro analysisSummaryLoop(dataset=, varlist=, varexclude=, groupvar=, out=, summary_macro=, analysis_macro= ,outputfmt=);



/*1.make a dataset called 'new' of all the variable that consist of all the variables needs to analysis*/
%if %length(&varlist)=0 %then %do;
	%if %length(&varexclude)=0 %then %do; 
		data new;
			set &dataset;
		run;
	%end;
	%else %do;
		data new;
			set &dataset;
			drop &varexclude;
		run;
	%end;
%end;

%else %do;
	%if %length(&varexclude)=0 %then %do; 
		data new;
			set &dataset;
			keep &varlist;
		run;
	%end;

	%else %do;
		data new;
			set &dataset;
			keep &varlist;
			drop &varexclude;
		run;
	%end;
%end;

proc contents data=new;
ods output variables=varname;
run;

proc sql;
    select strip(variable)
    into : in
    separated by ' '
    from varname;
quit;


%count(varname, macroout=Nvar)
%count(new, macroout=N)/*	why need to count this */


/*Loop over all variables*/

%do i=1 %to &Nvar;
		data _null_;
		set varname(firstobs=&i obs=&i);
		call symput('curv',strip(variable));
		run;
		%if %length(&summary_macro)^=0 %then %do;
				%&summary_macro.(dataset=&dataset, dependentvar=&curv, groupvar=&groupvar, out=&curv.summ, outputfmt=&outputfmt)
				%if %length(&analysis_macro)^=0 %then %do;
						%&analysis_macro.(dataset=&dataset, dependentvar=&curv, groupvar=&groupvar, out=&curv.test, outputfmt=&outputfmt)
						data &curv;
							merge &curv.summ &curv.test;
							by variable;
						run;
				%end;
				%else %do;
						data &curv;
							set &curv.summ;
						run;
				%end;
		%end;
		proc datasets library=work;
			delete &curv.summ &curv.test;
		run;
%end;

data &out;
	set &in;
run;

proc datasets library=work;
	delete &in varname new;
quit;
%symdel Nvar N / nowarn;

%MEND;



/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, November 30, 2015 18:59:05*/
