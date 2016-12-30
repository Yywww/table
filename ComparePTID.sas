/********************************************************************************************************************
Macro name: ComparePTID

Written by: Yiwen Luo

Creation date: Monday, February 01, 2016 18:34:10

As of date: 

SAS version: 9.4

Purpose: To compare patient in different dataset,

Parameters(required):base=,compare=
 
Parameters(optional):check=

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/

%macro ComparePTID(base=,compare=,check=, IDvariable=desid);
%mend;

data baseid;
	set &base;
	keep &IDvariable;
run;

data compareid;
	set &compare;
	keep &IDvariable;
run;

proc sort data=baseid;by desid;run;
proc sort data=compareid;by desid;run;

data basewithoutcompare;
	merge baseid(in=A) compareid(in=B);
	if A and not B;
run;

data comparewithoutbase;
	merge baseid(in=A) compareid(in=B);
	if not A and B;
run;

data both;
	merge baseid(in=A) compareid(in=B);
	if A and B;
run;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, February 01, 2016 18:59:21*/
