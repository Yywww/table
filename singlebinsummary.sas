/********************************************************************************************************************
Macro name: singlebinsummary

Written by: Yiwen Luo

Creation date: Wednesday, September 16, 2015 21:57:11

As of date: 

SAS version: 9.4

Purpose: create single summary for one binary variable in a dataset

Parameters(required):dataset=, var=,out=
 
Parameters(optional):

Sub-macros called: %count

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: %singlebinsummary(dataset=sabre.psproc, var=APC_N, out=test);

*************************************************************************************************************/

%macro singlebinsummary(dataset=, var=, out=, outvar=result, outfmt=percent7.1);
	data _nomissing;
    	set &dataset;
    	where &var^=.;
    run;
    %count(_nomissing,macroout=N)

    data _count;
    	set &dataset;
    	where &var=1;
    run;

    %count(_count,macroout=Nm)

%if &N=0 %then %do;
    data &out;
    length variable $50 statistics $50 &outvar $50;
        Variable="&var";
        Statistics="n/N (%)";
        &outvar="N/A";
    run;

%end;
%else %do;
    data &out;
    length variable $50 statistics $50 &outvar $50;
        Variable="&var";
        Statistics="n/N (%)";
        &outvar = cat("%cmpres(&Nm)/%cmpres(&N) (", strip(put(&Nm/&N, &outfmt)), ")");
    run;
%end;
%mend;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, September 16, 2015 21:56:10*/
