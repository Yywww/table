/********************************************************************************************************************
Macro name: freq(this is much better than binary_freq)

Written by: Yiwen Luo

Creation date: Wednesday, June 17, 2015 10:07:21

As of date: 

SAS version: 9.4

Purpose: create frequency table for one variable

Parameters(required):dataset=,var=,groupvar=
 
Parameters(optional):out=freq

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: freq(dataset=analysis,var=stent_generation,groupvar=pru_208g,out=freq)

*************************************************************************************************************/
%macro freq(dataset=,var=,groupvar=,out=freq);

proc freq data=&dataset order=data;
	table &groupvar*&var/expected out=freqtable;
	ods output CrossTabFreqs=CrossTabFreqs;
run;

proc transpose data=CrossTabFreqs(where=(expected^=.)) out=trans(drop=_label_);
run;


data count;
	set freqtable(where=(&var^=. and &groupvar^=.));
	retain g1v1 g1v0 g2v1 g2v0;
	if &var=1 and &groupvar=1 then g1v1=count;
	if &var^=1 and &groupvar=1 then g1v0=count;
	if &var=1 and &groupvar^=1 then g2v1=count;
	if &var^=1 and &groupvar^=1 then g2v0=count;
	if g1v1=. then g1v1=0;
	if g1v0=. then g1v0=0;
	if g2v1=. then g2v1=0;
	if g2v0=. then g2v0=0;
	if g1v1*g2v1^=0 then do;
		Zero=0;
		set trans;
		if _name_='Expected';
		fisher=min(col1,col2,col3,col4)<5;
	end;
	else do;
	Zero=1;
	fisher=0;
	end;
run;




/*data &out;*/
/*	length variable $30;*/
/*	firstgroup=cats(put(&g1v1/&g1vall,percent10.1),'(',&g1v1,'/',&g1vall,')');*/
/*	secondgroup=cats(put(&g0v1/&g0vall,percent10.1),'(',&g0v1,'/',&g0vall,')');*/
/*	total=cats(put(&gallv1/&gallvall,percent10.1),'(',&gallv1,'/',&gallvall,')');*/
/*	variable="&var";*/
/*run;*/


proc datasets library=work;
/*	delete freqtable;*/
run;
%mend freq;




	
OPTION SPOOL;
