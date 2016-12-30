/********************************************************************************************************************
Macro name: cox_ph

Written by: Yiwen Luo

Creation date: Tuesday, October 27, 2015 21:34:57

As of date: 

SAS version: 9.4

Purpose: Check assumption for variables in cox-ph model

Parameters(required):dataset=, varlist=, outcome=, outcome_time=, pdf_loc=
 
Parameters(optional):rot=5 ,martingale=True,cumhazloglog=True,SchoenfeldScore=True,overall=True

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %cox_ph(dataset=analysis, varlist=ACS AGE CALC CHF CRT_BASE DES GP2_ANY GRAFT_Lesion HGB_BASE 
HYPERLIP HYPERTEN IVUS_USD LESLEN MALE PRU_230G Prev_CABG Prev_MI, 
outcome=dth, outcome_time=dthdays,pdf_loc=P:\DataAnalysis\Interns\Yiwen Luo\
,martingale=T,cumhazloglog=T,SchoenfeldScore=T,overall=True)

*************************************************************************************************************/

%macro cox_ph(dataset=, varlist=, outcome=, outcome_time=, pdf_loc=, rot=5 ,martingale=True,
cumhazloglog=True,SchoenfeldScore=True,overall=True);

data _ph;
	set &dataset;
	keep &varlist;
run;

%detectvariabletype(_ph,rot=5)

proc contents data=_ph;
ods output  Variables=variablename;
run;

proc sort data=variablename;
by variable;
run;

data _con _bin;
	set result;
	if variabletype='continuous variable' then output _con;
	if variabletype='binary variable' then output _bin;
run;

%count(_bin,macroout=Nbin)
%count(_con,macroout=Ncon)
%count(result,macroout=N)

proc transpose data=result out=out;
var TableVar;
run;

data _null_;
	attrib all length=$32767.;
	set out;
	array col_array {*} COL1-COL&N;
	do i = 1 to dim(col_array);
  	all = catx('+',all,col_array{i});
 	end;
	call symput('model',cats("&outcome_time.*&outcome.=",all));
run;

proc transpose data=_bin out=outbin;
var TableVar;
run;

proc transpose data=_con out=outcon;
var TableVar;
run;

data _nal_;
	attrib all length=$32767.;
	set outbin;
	array col_array {*} COL1-COL&Nbin;
	do i = 1 to dim(col_array);
  	all = catx(' ',all,col_array{i});
 	end;
	call symput('bin_var',all);
run;

data _null_;
	attrib all length=$32767.;
	set outcon;
	array col_array {*} COL1-COL&Ncon;
	do i = 1 to dim(col_array);
  	all = catx(' ',all,col_array{i});
 	end;
	call symput('con_var',all);
run;


/*First part: Martingale Residual for each xontinuous variable*/

%if %upcase(&martingale)=TRUE or %upcase(&martingale)=T %then %do;

ods pdf file="&pdf_loc.Martingale Residual.pdf";

%do i=1 %to &Ncon;
	data _null_;
    	set _con(firstobs=&i obs=&i);
    	call symput('cur_var',tablevar);
    run;

	data _null_;
    	set _con(firstobs=&i obs=&i);
    	call symput('cur_var_label',tablevarlabel);
    run;

	ods select none;
	proc phreg data = &dataset;
	    model &outcome_time. * &outcome. (0) =  &cur_var./ rl ties=efron;
	    output out=Martingale_onevar xbeta=xb resmart=mart / method = ch;
	run;
	
	ods select all;
	proc sgplot data=Martingale_onevar;
		title "Martingale Residual Plot for &cur_var.";
		yaxis grid;
		refline 0 / axis=y;
		scatter y=mart x=xb/ MARKERATTRS=(symbol=X);
	run;

%end;

ods pdf close;

%end;
/*First part end*/

%if %upcase(&cumhazloglog)=TRUE or %upcase(&cumhazloglog)=T %then %do;
/*Second part: Cumhaz and log-log plots for binary and categorical variables*/
ods pdf file="&pdf_loc.Cumulative Hazard and log-log.pdf";
%do i=1 %to &Nbin;

	data _null_;
    	set _bin(firstobs=&i obs=&i);
    	call symput('cur_var',tablevar);
    run;
	data _null_;
    	set _bin(firstobs=&i obs=&i);
    	call symput('cur_var_label',tablevarlabel);
    run;
	ods select none;
	proc phreg data=&dataset;
		model &outcome_time. * &outcome.(0)=;
		strata &cur_var;
		baseline out=cumhazloglogs cumhaz=cumhaz loglogs=loglogs;
	run;
	ods select all;
	proc sgplot data=cumhazloglogs;
		title "Cumulative Hazard Plot for &cur_var.";
		series x=&outcome_time. y=cumhaz/GROUP=&cur_var;
	run;

	proc sgplot data=cumhazloglogs;
		title "log(-log(S(t))) Plot for &cur_var.";
		series x=&outcome_time. y=loglogs/GROUP=&cur_var;
	run;

%end;
ods pdf close;
%end;
/*Second part end*/



/*Third part: Schoenfeld residuals for each predictor (using the multivariate model)*/

%if %upcase(&SchoenfeldScore)=TRUE or %upcase(&SchoenfeldScore)=T %then %do;
ods pdf file="&pdf_loc.Schoenfeld and score residuals.pdf";
ods select none;

%if &Nbin!=0 %then %do;

proc phreg data = &dataset;
    class &bin_var / param=ref desc;
    model &outcome_time. * &outcome. (0) = &varlist./ rl ties=efron;
    output out=Schoenfeld logsurv=h xbeta=xb resmart=mart resdev=dev1 ressch=ressch1-ressch&N 
                         lmax=lmax ressco=ressco1-ressco&N / method = ch;
    output out=overall_mart resmart = resmart;
run;

%end;
%else %do;
proc phreg data = &dataset;
    model &outcome_time. * &outcome. (0) = &varlist./ rl ties=efron;
    output out=Schoenfeld logsurv=h xbeta=xb resmart=mart resdev=dev1 ressch=ressch1-ressch&N 
                         lmax=lmax ressco=ressco1-ressco&N / method = ch;
    output out=overall_mart resmart = resmart;
run;
%end;

ods select all;

/*This is to plot schoenfeld residual*/
%do i=1 %to &N;

	data _null_;
    	set variablename(firstobs=&i obs=&i);
    	call symput('cur_var_label',label);
    run;
	proc gplot data = Schoenfeld;
		title "Schoenfeld Residuals for &cur_var.";
	    plot ressch&i * &outcome_time
	        / CFRAME=white OVERLAY VAXIS=axis1 HAXIS=axis2 FRAME VREF=0 VMINOR=0 HMINOR=0
	          CAXIS = black;
		symbol value=dot i=sm60s h=1.2 w=3;
		axis1 label =(a=90 r=0 f='Arial' 'Schoenfeld Residuals') value=(f='Arial' );
		axis2 label=( f='Arial' 'Time')value=(f='Arial') ; 
	run;

%end;

data score;
	set schoenfeld;
	idcount=_n_;
run;

/*This is to plot score residual*/
%do i=1 %to &N;
	data _null_;
    	set variablename(firstobs=&i obs=&i);
    	call symput('cur_var_label',label);
    run;

	proc sgplot data=Score;
		title "Score Residuals for &cur_var.";
		yaxis grid;
		refline 0 / axis=y;
		scatter y=ressco&i x=idcount;
	run;

%end;

ods pdf close;

%end;
/*Third part end*/



/*Fourth part: Martingale, Schoenfeld, score and deviance residuals for the entire MV Cox model*/
%if %upcase(&overall)=TRUE or %upcase(&overall)=T %then %do;
ods pdf file="&pdf_loc.overall fit.pdf";
ods select none;
proc phreg data = &dataset;
    class &bin_var / param=ref desc;
    model &outcome_time. * &outcome. (0) = &varlist./ rl ties=efron;
    output out=overall resmart = resmart ressch=ressch ressco=ressco lmax=lmax xbeta=linear_predictor resdev=resdev;
run;
ods select all;

data overall;
	set overall;
	idcount=_n_;
run;

data inf;
	set overall(where =(resdev ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=linear_predictor ; y=resmart;
run; 

goptions reset=all colors=(black, red,blue,yellow,green,magenta,cyan)
dev=emf target=emf xmax=7 ymax=7 htext=14pt ftext="<ttf> arial"; 

proc gplot data=overall;
	title1 "Martingale Residual for Cox model";
	bubble resmart*linear_predictor=lmax /cframe=white annotate=inf vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial" "Martingale Residual")width=2;
	axis2 label=(f="arial" "Linear Predictor")width=2;
run; 

/* deviance with xb as x axis*/
data inf_devxb;
	set overall(where =(resdev ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=linear_predictor ; y=resdev;
run; 

proc gplot data=overall;
	title1 "Deviance Residual for Cox model";
	bubble resdev*linear_predictor=lmax /cframe=white annotate=inf_devxb vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial" "Deviance residual")width=2;
	axis2 label=(f="arial" "Linear Predictor")width=2;
run; 
/* deviance with id / _n_ as x  */

/*data inf_devid;*/
/*	set overall(where =(resdev ne .));*/
/*	id=_n_;*/
/*	length text $12 function $8;*/
/*	retain xsys '2' ysys '2' size 1;*/
/*	x=_n_ ; y=resdev;*/
/*run; */
/*;*/
/*proc gplot data=overall;*/
/*	title1 "Deviance with id as x";*/
/*	bubble resdev*idcount=lmax /cframe=white annotate=inf_devid vaxis=axis1 haxis=axis2*/
/*	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'*/
/*	bcolor=red bsize=12;*/
/*	axis1 label=(a=90 r=0 f="arial" "Deviance residual")width=2;*/
/*	axis2 label=(f="arial" "ID")width=2;*/
/*run; */

/*Schoenfeld Residual*/

data inf_sch;
	set overall(where =(resdev ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=linear_predictor ; y=ressch;
run; 

proc gplot data=overall;
	title1 "Schoenfeld Residual for Cox model";
	bubble ressch*linear_predictor=lmax /cframe=white annotate=inf_sch vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial" "Schoenfeld Residual")width=2;
	axis2 label=(f="arial" "Linear Predictor")width=2;
run; 


/*Score Residual*/

data inf_sco;
	set overall(where =(resdev ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=linear_predictor ; y=ressco;
run; 

proc gplot data=overall;
	title1 "Score Residual for Cox model";
	bubble ressco*linear_predictor=lmax /cframe=white annotate=inf_sco vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial" "Score Residual")width=2;
	axis2 label=(f="arial" "Linear Predictor")width=2;
run; 


ods pdf close;

%end;
/*Fourth part end*/

proc datasets library=work nolist;
delete cumhazloglogs inf inf_devid inf_devxb martingale_onevar out outbin outcon overall overall_mart result schoenfeld score variablename _bin _con _nal_ _ph;
quit;

%mend;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Tuesday, October 27, 2015 21:36:16*/


