/********************************************************************************************************************
Macro name: TablePrint

Written by: Yiwen Luo

Creation date: 

SAS version: 9.4

File Location:

Validated By:

Date Validated:

Purpose: 

Parameters(required):	

Parameters(optional):	

Sub-macros called: 

Data sets created: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/

%macro TablePrint(ds=,dic=,groupds=,group=,out=,id=desid,sheet_name=);
proc sort data=&ds;by &id;run;
proc sort data=&groupds;by &id;run;

data _curr_analysisds;
	merge &ds &groupds(in=A);
	if A;
	by &id;
run;

proc sql;
	select max(find(SASTYPE,'BINARY'))
	into :binexist
	from &dic;
run;

proc sql;
	select max(find(SASTYPE,'CONTINUOUS'))
	into :conexist
	from &dic;
run;

proc sql;
	select max(find(SASTYPE,'LOGRANK'))
	into :logexist
	from &dic;
run;

data _raw;
run;

%if &binexist>0 %then %do;
	proc sql;
	    select strip(variablename)
	    into : curr_bin
	    separated by ' '
	    from &dic
	    where sastype='BINARY';
	quit;
	%analysisSummaryLoop(dataset=_curr_analysisds, varlist=&curr_bin, groupvar=&group, out=_raw_bin, summary_macro=binarysummary, analysis_macro=binarytest)
	data _raw;
		set _raw _raw_bin;
	run;
%end;

%if &conexist>0 %then %do;
	proc sql;
	    select strip(variablename)
	    into : curr_con
	    separated by ' '
	    from &dic
	    where sastype='CONTINUOUS';
	quit;
	%analysisSummaryLoop(dataset=_curr_analysisds, varlist=&curr_con, groupvar=&group, out=_raw_con, summary_macro=continuoussummary, analysis_macro=continuoustest)
	data _raw;
		set _raw _raw_con;
	run;
%end;

%if &logexist>0 %then %do;
	proc sql;
	    select strip(variablename)
	    into : curr_log
	    separated by ' '
	    from &dic
	    where sastype='LOGRANK';
	quit;
	%analysisSummaryLoop(dataset=_curr_analysisds, varlist=&curr_log, groupvar=&group, out=_raw_log, summary_macro=logranksummary, analysis_macro=logranktest)
	data _raw;
		set _raw _raw_log;
	run;
%end;


proc sql;
	create table &out as 
	select *
	from &dic as A left join _raw as B on upcase(A.variablename)=upcase(B.variable);
quit;

%if %length(&sheet_name)>0 %then %do;

data &out;
	set &out;
	length sheet_name $50;
	sheet_name="&sheet_name";
run;

%end;


proc datasets library=work;
delete _raw _raw_bin _raw_con _raw_log;
quit;

%mend TablePrint;
