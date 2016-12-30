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

%macro varloop(dataset=, varlist=, varexclude=, groupvar=, out=, summary_macro=, analysis_macro=  )

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
    	call symput('curv',variable);
    run;
	%&summary_macro(dataset=&dataset, dependentvar=&curv,groupvar=&groupvar, out=&curv,outputfmt=)
	%&summary_macro(ds=&dataset, groupvar=&groupvar, var=&curr_var, out=&curr_var.summary)
    %binarytest(dataset=&dataset, groupvar=&groupvar, var=&curr_var, out=&curr_var.test, groupvar_refindex=&groupvar_refindex)

%end;

data &out;
	set &in;
run;





/* Delete datasets and global macro variables */
proc datasets library=work nolist nodetails;
	delete varname new &in;
quit;

%symdel Nvar N / nowarn;

%MEND varloop;



/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Friday, October 30, 2015 22:50:49*/
