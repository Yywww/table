/*!
*   {Macro Description}.
*   <br>
*   <b> Macro Location: </b> P:\DataAnalysis\MACRO_IN_PROGRESS\Macros for analysisSummaryLoop\
*
*   @author Yiwen Luo
*   @created Thursday, March 10, 2016 13:20:13
*
*/
 
/********************************************************************************************************************
Macro name: AnalysisSummaryLoop
Written by: Yiwen Luo
Creation date: Thursday, March 10, 2016 13:19:56
SAS version: 9.4
File Location: P:\DataAnalysis\MACRO_IN_PROGRESS\Macros for analysisSummaryLoop\

Validated By:
Date Validated:

Purpose: Execute user assigned macro loop over a list of variables
Parameters(required):	dataset=
						groupvar=
						out=
						summary_macro=

Parameters(optional):	varlist=
						varexclude=
						analysis_macro=
						outputfmt=

Sub-macros called: % count()

Data sets created: 

Notes: The analysis_macro and summary_macro this macro calls has to have specific parameter.

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
 * @return a dataset name by out parameter
 */ 

%macro analysisSummaryLoop(dataset=, varlist=, varexclude=, groupvar=, out=, summary_macro=, analysis_macro= ,outputfmt=);


ods select none;
/*1.make a dataset called '_new' of all the variable that consist of all the variables needs to analysis using varlist and varexclude
. If varlist is not specified, default is to analysis all variables in that dataset*/
%if %length(&varlist)=0 %then %do;
	%if %length(&varexclude)=0 %then %do; 
		data _new;
			set &dataset;
		run;
	%end;
	%else %do;
		data _new;
			set &dataset;
			drop &varexclude;
		run;
	%end;
%end;

%else %do;
	%if %length(&varexclude)=0 %then %do; 
		data _new;
			set &dataset;
			keep &varlist;
		run;
	%end;

	%else %do;
		data _new;
			set &dataset;
			keep &varlist;
			drop &varexclude;
		run;
	%end;
%end;

proc contents data=_new;
ods output variables=_varname;
run;

proc sql noprint;
    select strip(variable)
    into : in
    separated by ' '
    from _varname;
quit;


%count(_varname, macroout=Nvar)

/*Loop over all variables. 
If user specifies analysis_macro, then do both and merge them together. 
If user doesn't specify analysis_macro, then only do summary_macro*/

%do i=1 %to &Nvar;
		data _null_;
		set _varname(firstobs=&i obs=&i);
		call symput('curv',strip(variable));
		run;
		%if %length(&summary_macro)^=0 %then %do;
				%&summary_macro.(dataset=&dataset, dependentvar=&curv, groupvar=&groupvar, out=_curvsumm, outputfmt=&outputfmt)
				%if %length(&analysis_macro)^=0 %then %do;
						%&analysis_macro.(dataset=&dataset, dependentvar=&curv, groupvar=&groupvar, out=_curvtest, outputfmt=&outputfmt)
						data varsum&i;
							merge _curvsumm _curvtest;
							by variable %if %index(%upcase("&analysis_macro."),CONTINUOUS)>0 %then %do; statc %end;;
						run;
				%end;
				%else %do;
						data varsum&i;
							set _curvsumm;
						run;
				%end;
		%end;
		proc datasets library=work;
			delete _curvsumm _curvtest;
		run;
%end;

data &out;
	set %range(to=&Nvar,opre=varsum);
run;

proc datasets library=work;
	delete %range(to=&Nvar,opre=varsum) _varname _new;
quit;

ods select all;
%symdel Nvar / nowarn;

%MEND;



/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, November 30, 2015 18:59:05*/
