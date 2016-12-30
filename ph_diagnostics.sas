/********************************************************************************************************************
Macro name: ph_diagnostics

Written by: C Litherland & Y Luo

Creation date: Tuesday, July 21, 2015 11:49:15

As of date: 

SAS version: 9.4

Purpose: given a dataset output from proc phreg, produce a pdf of the following diagnostic plots :
						functional form (for continuous variables) 
						Proportional hazards supremum plot 
						Schoenfeld residuals for each predictor 
						deviance residuals (outliers and influential obs) 
						Martingale residuals (overall Fit) 
						Cox snell residuals (overall fit) 

Parameters(required):ds=, covariates=, outcome=, outcome_time=, pdf_loc=
 
Parameters(optional):plot_dim=0.5,author=YLuo

Sub-macros called: %detectvariabletype %count %footnotes

Data sets created: 

Limitations: 

Notes:   Resources http://support.sas.com/resources/papers/proceedings13/431-2013.pdf                              
                   http://www.mwsug.org/proceedings/2006/stats/MWSUG-2006-SD08.pdf 

Sample Macro call: %ph_diagnostics(ds=adapt_forest, covariates=Complex ACS pru_208g age EJECT_FR, outcome=dth, outcome_time=dthdays, pdf_loc=P:\DataAnalysis\ADAPT DES\2 Year FU\Adhocs\PG Complex ACS PRU Request\ph_diagnostics1000.pdf)

*************************************************************************************************************/


%macro ph_diagnostics(ds=, covariates=, outcome=, outcome_time=, pdf_loc=,plot_dim=0.5,author=YLuo);
ods graphics on image_dpi=500;

data _ph;
	set &ds;
	keep &covariates;
run;

%detectvariabletype(_ph,rot=5)
/*this is for binary*/

data _con _bin;
	set result;
	if variabletype='continuous variable' then output _con;
	if variabletype='binary variable' then output _bin;
run;
%count(_bin,macroout=Nbin)
%count(_con,macroout=Ncon)
%count(result,macroout=N)

ods pdf file="&pdf_loc.";

data _null_;
	attrib all length=$32767.;
	set out;
	array col_array {*} COL1-COL&N;
	do i = 1 to dim(col_array);
  	all = catx('+',all,col_array{i});
	/*&beta^{sub i}*/
 	end;
	call symput('model',cats("&outcome_time.*&outcome.=",all));
run;

proc means data=&ds n nmiss;
title1 "Assessing Survival Model";
title2 "&model";
var &covariates;
run;

%if &Nbin=0 %then %do;
proc transpose data=result out=out;
var TableVar;
run;

proc phreg data = &ds;
title "titleTBD";
    model &outcome_time. * &outcome. (0) = &covariates.
                                        / rl ties=efron;
    assess var = (&covariates.)  ph / resample npaths=50 crpanel; 
	ods select CumResidPanel CumulativeResiduals FunctionalFormSupTest ScoreProcess ProportionalHazardsSupTest;
    output out=mod1_diag logsurv=h xbeta=xb resmart=mart resdev=dev1 ressch=ressch1-ressch&N 
                         lmax=lmax ressco=ressco1-ressco&N
                         loglogs=logneglog / method = ch;
    output out=age_mart resmart = resmart;
    run;
%end;

%if &Ncon=0 %then %do;
proc transpose data=result out=out;
var TableVar;
run;

proc phreg data = &ds;
title "title";
    class &covariates./ param=ref desc;
    model &outcome_time. * &outcome. (0) = &covariates.
                                        / rl ties=efron;
    assess ph / resample npaths=50 crpanel;
	ods select CumResidPanel CumulativeResiduals FunctionalFormSupTest ScoreProcess ProportionalHazardsSupTest;
    output out=mod1_diag logsurv=h xbeta=xb resmart=mart resdev=dev1 ressch=ressch1-ressch&N 
                         lmax=lmax ressco=ressco1-ressco&N
                         loglogs=logneglog / method = ch;
    output out=age_mart resmart = resmart;
    run;
%end;


%if &Nbin^=0 and &Ncon^=0 %then %do;

proc transpose data=_bin out=out;
var TableVar;
run;

data _nal_;
	attrib all length=$32767.;
	set out;
	array col_array {*} COL1-COL&Nbin;
	do i = 1 to dim(col_array);
  	all = catx(' ',all,col_array{i});
 	end;
	call symput('cat_var',all);
run;

proc transpose data=_con out=out;
var TableVar;
run;

data _null_;
	attrib all length=$32767.;
	set out;
	array col_array {*} COL1-COL&Ncon;
	do i = 1 to dim(col_array);
  	all = catx(' ',all,col_array{i});
 	end;
	call symput('con_var',all);
run;

proc transpose data=result out=out;
var TableVar;
run;

proc phreg data = &ds;
	title "title TBD";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
    class &cat_var / param=ref desc;
    model &outcome_time. * &outcome. (0) = &covariates.
                                        / rl ties=efron;
    assess var = (&con_var.)  ph / resample npaths=50 crpanel;
	ods select CumResidPanel CumulativeResiduals ScoreProcess;
    output out=mod1_diag logsurv=h xbeta=xb resmart=mart resdev=dev1 ressch=ressch1-ressch&N 
                         lmax=lmax ressco=ressco1-ressco&N
                         loglogs=logneglog / method = ch;
    output out=age_mart resmart = resmart;
    run;
%end;

/* CCL Note:  Code taken from < http://statistics.ats.ucla.edu/stat/sas/examples/sakm/chapter11.htm > */
/* Cox-Snell Residuals for Assessing the Fit of a Cox Model */

data mod1_diag_a;
	set mod1_diag;
	h = -h;
	cons = 1;
	idcount = _n_;
run;

proc phreg data = mod1_diag_a;
	model  h* &outcome.(0) = cons;
	ods EXCLUDE ModelInfo NObs CensoredSummary ConvergenceStatus FitStatistics GlobalTests ParameterEstimates;
	output out = mod1_diag_b logsurv = ls /method = ch;
run;

data mod1_diag_c;
	set mod1_diag_b;
	haz = - ls;
run;

proc sort data =mod1_diag_c;
	by h;
run;

title "Model Diagnostics for Model";
axis1 order = (0 to &plot_dim by .1) minor = none;
axis2 order = (0 to &plot_dim by .1) minor = none label = ( a=90);
symbol1 i = stepjl c= blue;
symbol2 i = join c = red l = 3;

proc gplot data = mod1_diag_c;
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
	plot haz*h =1 h*h =2 /overlay haxis=axis1 vaxis= axis2;
	label haz = "Estimated Cumulative Hazard Rates";
	label h = "Residual";
run;
quit;

%modstyle(name=markstyle, parent=statistical, type=CLM,
          markers=circlefilled squarefilled diamondfilled)
/*Schoenfeld residuals for each predictor*/
%DO i=1 %TO &N;
proc gplot data = mod1_diag;
	title "Schoenfeld Residuals for RESSCH&i.";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
    plot ressch&i * &outcome_time
        / CFRAME=white OVERLAY VAXIS=axis1 HAXIS=axis2 FRAME VREF=0 VMINOR=0 HMINOR=0
          CAXIS = black NAME="plot&i";
	symbol value=dot i=sm60s h=1.2 w=3;
	axis1 label =(a=90 r=0 f='Arial''Schoenfeld Residuals') value=(f='Arial' );
	axis2 label=( f='Arial' 'Time')value=(f='Arial') ; 
run;
quit;
/* Score residuals - one per covariate */
proc sgplot data=mod1_diag_c;
	title "TBD";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
	yaxis grid;
	refline 0 / axis=y;
	scatter y=ressco&i x=idcount;
	run;
%END;


/* Martingale - one per model */
data inf;
	set mod1_diag(where =(dev1 ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=xb ; y=Mart;
run; 

goptions reset=all colors=(black, red,blue,yellow,green,magenta,cyan)
dev=emf target=emf xmax=7 ymax=7 htext=14pt ftext="<ttf> arial"; 

proc gplot data=mod1_diag;
	title1 "Martingale";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
	bubble Mart*xb=lmax /cframe=white annotate=inf vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial ""Martingale Residual")width=2;
run; 

/* deviance with xb as x axis*/
data inf;
	set mod1_diag(where =(dev1 ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=xb ; y=dev1;
run; 

proc gplot data=mod1_diag;
	title1 "Deviance with xb as x axis";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
	bubble dev1*xb=lmax /cframe=white annotate=inf vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial ""Deviance residual")width=2;
	axis2 label=(f="arial ""Xb")width=2;
run; 
/* deviance with id / _n_ as x  */

data inf;
	set mod1_diag_c(where =(dev1 ne .));
	id=_n_;
	length text $12 function $8;
	retain xsys '2' ysys '2' size 1;
	x=idcount ; y=dev1;
run; 

proc gplot data=mod1_diag_c;
	title1 "Deviance with id as x";
	%footnotes(program=%sysget(SAS_EXECFILENAME),fileName=&pdf_loc,datasetName=&ds,author=&author)
	bubble dev1*idcount=lmax /cframe=white annotate=inf vaxis=axis1 haxis=axis2
	frame vref=-1 0 1 2 3 4 vminor=0 hminor=0 caxis= black name='plot3'
	bcolor=red bsize=12;
	axis1 label=(a=90 r=0 f="arial ""Deviance residual")width=2;
	axis2 label=(f="arial ""ID")width=2;
run; 

ods pdf close;

proc datasets nolist;
	delete age_mart inf mod1_diag mod1_diag_a mod1_diag_b mod1_diag_c out result _bin _con _nal_ _ph;
quit;

proc datasets lib=work nolist nodetails; 
	delete _DOCTMP:;
quit;


%MEND;


/* **** End of Macro **** */
/* **** by Yiwen Luo **** */
/*Tuesday, July 21, 2015 11:52:46*/
