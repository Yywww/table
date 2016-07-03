/*!
 * Execute user assigned macro loop over a list of variables
 * <br>
 * <b> Macro Location: P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
 *
 * @author Yiwen Luo
 * @created Tuesday, August 18, 2015 14:23:42
 */
/********************************************************************************************************************
    Macro name: variableloop
    Written by: Yiwen Luo
    Creation date: Tuesday, August 18, 2015 14:23:41
    As of date: 
    SAS version: 9.4

    Purpose: execute user assigned macro loop over a list of variables
    Parameters(required):
    Parameters(optional):

    Sub-macros called: % count

    Data sets created: 
          Limitations: 
                Notes: What analysis / summary macros can this macro take?   

    Sample Macro call: 

*************************************************************************************************************/
/**
 * Execute user assigned macro loop over a list of variables
 *
 * @param dataset       Input dataset name
 * @param in            Variable list to be analyzed
 * @param out           Output dataset name
 * @param macrotouse    Name of macro want to be used for variable list provided
 */ 

%macro varloop(dataset=, varlist=, varexclude=, groupvar=, out=, summary_macro=, analysis_macro= ,outputfmt=);

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

%MEND varloop;



/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Friday, October 30, 2015 22:50:49*/
