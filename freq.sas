%INCLUDE "P:\DataAnalysis\ADAPT DES\Macros\ADAPTMacro Rewrites\new macro\IncludeCCLMacroCatAutoCalls_ADAPT.sas";




%macro freq(dataset=,var=,groupvar=,out=freq);

proc sort data=&dataset;
by descending &groupvar descending &var;
run;

proc freq data=&dataset order=data;
	table &groupvar*&var/nocol norow nopercent expected chisq relrisk riskdiff;
	ods output CrossTabFreqs=freqtable;
run;

%count(freqtable,macroout=row)
%global zero;
%put &row;

%if &row=9 %then %do;

data _null_;
	set freqtable;
	if _N_=1 then call symput('g1v1',frequency);
	if _N_=3 then call symput('g1vall',frequency);
	if _N_=4 then call symput('g0v1',frequency);
	if _N_=6 then call symput('g0vall',frequency);
	if _N_=7 then call symput('gallv1',frequency);
	if _N_=8 then call symput('gallv0',frequency);
	if _N_=9 then call symput('gallvall',frequency);
run;

proc transpose data=freqtable(where=(expected^=.)) out=trans(drop=_label_);
run;

%if &g0v1=0 %then %let zero=1;
%else %let zero=0;

data _fisher_;
	set trans;
	if _name_='Expected';
	fisher=min(col1,col2,col3,col4)<5;
	keep fisher;
run;

data &out;
	length variable $30;
	firstgroup=cats(put(&g1v1/&g1vall,percent10.1),'(',&g1v1,'/',&g1vall,')');
	secondgroup=cats(put(&g0v1/&g0vall,percent10.1),'(',&g0v1,'/',&g0vall,')');
	total=cats(put(&gallv1/&gallvall,percent10.1),'(',&gallv1,'/',&gallvall,')');
	variable="&var";
run;

%end;

%if &row=6 %then %do;

%let zero=1;

data _fisher_;
	fisher=0;
run;

data _string_;
	set freqtable end=lastobs;
	retain g1v1 g1vall g0v1 g0vall gallv1 gallvall(0,0,0,0,0,0);
	if &groupvar=1 and &var=1 then g1v1=frequency;
	if &groupvar=1 and &var=. then g1vall=frequency;
	if &groupvar=0 and &var=1 then g0v1=frequency;
	if &groupvar=0 and &var=. then g0vall=frequency;
	if &groupvar=. and &var=1 then gallv1=frequency;
	if &groupvar=. and &var=. then gallvall=frequency;
	if lastobs;
run;

data &out;
	set _string_;
	length variable $30;
	firstgroup=cats(put(g1v1/g1vall,percent10.1),'(',g1v1,'/',g1vall,')');
	secondgroup=cats(put(g0v1/g0vall,percent10.1),'(',g0v1,'/',g0vall,')');
	total=cats(put(gallv1/gallvall,percent10.1),'(',gallv1,'/',gallvall,')');
	variable="&var";
	keep firstgroup secondgroup total variable;
run;

%end;

proc datasets nolist;
	delete _string_ trans freqtable;
quit;


%mend freq;

