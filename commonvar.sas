/********************************************************************************************************************
Macro name: commonvar

Written by: Yiwen Luo

Creation date: Wednesday, July 29, 2015 09:58:38

As of date: 

SAS version: 9.4

Purpose: find the common variable of mutiple dataset

Parameters(required):ds(position parameter)
 
Parameters(optional):

Sub-macros called: %count

Data sets created: Monday, August 03, 2015 16:39:30

Limitations: 

Notes: 

Sample Macro call: %commonvar(adaptdat.baseline adaptdat.carddiag)

*************************************************************************************************************/

%macro commonvar(ds);

data _data;/*That is a cool name*/
string="&ds";
run;


data _dataset;/*This is cooler!*/
length dataset $42.; 
set _data; 
do i=1 by 1 while(scan(string,i,' ') ^=' '); 
dataset=scan(string,i,' '); 
output; 
end; 
run;


data _null_;
	set _dataset(firstobs=1 obs=1);
	call symput('curdataset',strip(dataset));
run;

/*Basic idea is to use proc contents to get variable list of each dataset then merge them all*/

proc contents data=&curdataset;
ods output Variables=_v;
run;

proc sort data=_v;by Variable;run;

data commonvar;
	set _v;
run;
%count(_dataset)
%do i=2 %to &N;

data _null_;
	set _dataset(firstobs=&i obs=&i);
	call symput('curdataset',strip(dataset));
run;

proc contents data=&curdataset;
ods output Variables=_v;
run;

proc sort data=_v;by Variable;run;

data commonvar;
	merge commonvar(in=A) _v(in=B);
	if A and B;
run;

%end;

proc sql;
	select Variable
	from commonvar;
quit;

%mend commonvar;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 03, 2015 16:39:45*/
