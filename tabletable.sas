/********************************************************************************************************************
Macro name: tabletable(I need a new name...)

Written by: Yiwen Luo

Creation date: Jun03 2015

As of date: Monday, June 15, 2015 16:08:52

SAS version: 9.4

Purpose: generate table of a dataset

Parameters(required):dataset=,groupvar=
 
Parameters(optional):table=table (table name),groupvari=1

Sub-macros called: %detectvariabletype, %count, %binary, %continuous

Data sets created: 

Limitations: 

Notes: 

Sample Macro call:%table(dataset=analysis,groupvar=PRU_208G,table=finally)

*************************************************************************************************************/

%macro tabletable(data=, groupvar=,table=table,groupvari=1,rot=8);

/* Check if Dataset Exists */
%if %sysfunc(exist(&data))=0 %then %do;
%window win1  ICOLUMN= 15 IROW= 10
 COLUMNS= 40 ROWS=20 color=white
  #5 @5 'Input dataset does not exist.' attr=highlight color=blue;	 
%display win1;
%abort;
%end;

/* Check if output table already exists */
    /* Future thing: give option to overwrite? */
%if %sysfunc(exist(&table))=1 %then %do;
%window win2  ICOLUMN= 15 IROW= 10
 COLUMNS= 50 ROWS=20 color=white
  #5 @5 'Dataset &table already exist.' color=blue	 
  #7 @5 'Do you want to overwrite it?(Y/N)' color=blue
  #7 @38 ow 1 attr=underline color=blue;
%display win2;

%if %upcase(&ow)=Y %then %goto start;
%else %abort;
%end;
/*  **************************************************************************************************************  */

%start:%let datetime_start = %sysfunc(TIME()) ;
%put START TIME: %sysfunc(datetime(),datetime14.);

data _temp;
	set &data;
run;

%let dataset=_temp;

%detectvariabletype(&dataset,out=ooo,rot=&rot)


data _null_;
	set ooo;
	if upcase(TableVar)=upcase("&groupvar");
	call symput('groupvartype',cats(variabletype));
run;

%put &groupvartype;

%if "&groupvartype"^="binary variable" %then %do;
%put "input group variable is not binary, please check again";
%abort;
%end;

%detectlogrank(ooo,out=list)




data result_logrank result_binary result_continuous result_cate;
	set list;
	if upcase(TableVar)^=upcase("&groupvar");
	if variabletype="binary variable" then output result_binary;
	else if variabletype="continuous variable" then output result_continuous;
	else if variabletype="logrank binary" then output result_logrank;
	else if variabletype="categorical variable with three or more levels" then output result_cate;
run;

data group1 group2;
	set &dataset;
	if &groupvar=&groupvari then output group1;
	else output group2;
run;

%count(dataset=result_binary,macroout=N1)
/*  *****************************************************  */
    %do index=1 %to &N1;
        %put &index+binary;
        data _NULL_;
              set result_binary(firstobs=&index obs=&index);
              call symput('var',TableVar);
        run;

        %binary(dataset=&dataset,var=&var,groupvar=&groupvar,out=&var);

    %end;
/*  *****************************************************  */

%count(dataset=result_continuous,macroout=N2)

/*  *****************************************************  */
    %do index=1 %to &N2;
        %put &index+continuous;
        data _NULL_;
              set result_continuous(firstobs=&index obs=&index);
              call symput('var',TableVar);
        run;

        %continuous(dataset=&dataset,var=&var,groupvar=&groupvar,groupvari=1,use=withinmacro);
    %end;



%count(dataset=result_logrank,macroout=N3)
/*  *****************************************************  */
    %do index=1 %to &N3;
        %put &index+logrank;
        data _NULL_;
              set result_logrank(firstobs=&index obs=&index);
              call symput('var',TableVar);
        run;

        %logrank(dataset=&dataset,var=&var,groupvar=&groupvar,groupvari=1)
    %end;
/*  *****************************************************  */



%count(dataset=result_cate,macroout=N4)
/*  *****************************************************  */
    %do index=1 %to &N4;
        %put &index+cate;

        data _NULL_;
              set result_cate(firstobs=&index obs=&index);
              call symput('var',TableVar);
        run;

        %cate(dataset=&dataset,cate=&var,groupvar=&groupvar)
    %end;
/*  *****************************************************  */


data _left;
	set list;
		if variabletype in ("binary variable",
						"continuous variable",
						"logrank binary",
						"categorical variable with three or more levels");
		if upcase(TableVar)^=upcase("&groupvar");
run;


%count(dataset=_left,macroout=N);

data _NULL_;
      set _left(firstobs=1 obs=1);
      call symput('var',TableVar);
run;
data table;
	set &var;
run;

proc datasets library=work;
	delete &var;
run;

%do index=2 %to &N;
%put &index+assemble;
data _NULL_;
      set _left(firstobs=&index obs=&index);
      call symput('var',TableVar);
run;
data table;
	length variable $ %GetMaxLen(&var table, variable);
	set &var table;
run;

proc datasets library=work;
	delete &var;
run;

%end;

proc contents data=&data;
ods output Variables=label;
run;

proc sort data=table;
	by Variable;
run;

proc sort data=label;
	by Variable;
run;

%if %varexist(label,label)=1 %then %do; 
/*use overwrite is more efficient*/
data &table;
	length variable $ %GetMaxLen(label table, variable);
	merge table(in=A) label(keep=label variable);
	by Variable;
	if A;
	if Label=" " then Label=Variable;
	if rrci^=" " then rrhrci=rrci;
	if hrci^=" " then rrhrci=hrci;
run;
%end;
%else %do;
data &table;
	length variable $ %GetMaxLen(label table, variable);
	merge table(in=A) label(keep=variable);
	by Variable;
	if A;
	if rrci^=" " then rrhrci=rrci;
	if hrci^=" " then rrhrci=hrci;
run;
%end;

proc datasets library=work nolist nodetails;
	delete group1 group2 _temp result_binary result_continuous result_cate result_logrank 
           list binary continuous factor ooo _left &groupvar label _fisher_;
run;

proc datasets lib=work nolist nodetails; 
	delete _DOCTMP:;
quit;

quit;

%put END TIME: %sysfunc(datetime(),datetime14.);
%put PROCESSING TIME:  %sysfunc(putn(%sysevalf(%sysfunc(TIME())-&datetime_start.),mmss.)) (mm:ss) ;

%mend tabletable;

/* **** End of Macro **** */
/* **** by Yiwen Luo **** */
/*Friday, June 05, 2015 16:54:11*/

