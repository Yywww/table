/********************************************************************************************************************
Macro name: countdigit

Written by: Yiwen Luo

Creation date: Wednesday, September 02, 2015 08:00:26

As of date: 

SAS version: 9.4

Purpose: to see whether the max and min digit number of a variable is same

Parameters(required): dataset=,var=
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
%macro countdigit(dataset=,var=,out=);
	data _check;
		set &dataset;
		_absolute=abs(&var); 
		keep _absolute;
	run;

	proc sql;
		create table maxmin as
		select max(_absolute) as max, min(_absolute) as min
		from _check
	quit;

	data &out;
		set maxmin;
		length digit $ 10;
		maxk = ceil(log10(max+1));
		mink = ceil(log10(min+1));
		if maxk ne mink then digit='not equal';
		else digit='equal';
		variable="&var";
	run;

	proc datasets library=work nolist nodetails;
		delete _check maxmin;
	quit;
%mend;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, September 02, 2015 08:08:15*/
