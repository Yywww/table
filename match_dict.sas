/*!
*   {Macro Description}.
*   <br>
*   <b> Macro Location: </b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\
*
*   @author Yiwen Luo
*   @created
*
*/
 
/********************************************************************************************************************
Macro name: match_dictionary

Written by: Yiwen Luo

Creation date: Sunday, April 17, 2016 19:01:27

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
 
 
/**
*   {Macro Description}.
*
*   @param 
*
*   @return
*
*/

%macro searchdata(dic=);

%mend;



/*Use proc datasets to see variables in analysis dataset*/

data searchindex;
	set adaptdic.baselinevarlist;
	if not missing(SAStype);
run;


proc datasets library=adaptdat;
contents 
data=_ALL_ 
out=WORK._contents(keep = libname memname name type label format length varnum);
run;
quit;

/*extract variable name in dictionary*/
proc sql;
	select DISTINCT MEMNAME 
	into:remain_dataset
	separated by ' '
	from _contents
	where upcase(NAME)='AGE';
quit;

%put &remain_dataset;

proc datasets library=adaptdat;
contents 
data=&remain_dataset 
out=WORK._contents3(keep = libname memname name type label format length varnum);
run;
quit;





