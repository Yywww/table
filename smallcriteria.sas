


/*  *************************************************************************************************************   */
*      Macro Name:                                                                                                  *;
*          Author: C Litherland                                                                                     *;
*    Date Created:                                                                                                  *;
*   File Location: H:\CCL Macros\Macros                                                                             *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose:                                                                                                  *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros:                                                                                                  *;
*           Usage:                                                                                                  *;
*                                                                                                                   *;
* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
* in                                                                                                                *;
* out                                                                                                               *;
* category                                                                                                          *;
* index                                                                                                             *;
*                                                                                                                   *;
*                                                                                                                   *;
* ================================================================================================================= *;
/*  **************************************************************************************************************  */
%INCLUDE "H:\CCL Macros\IncludeCCLMacroCatAutoCalls.SAS";
%INCLUDE "H:\CCL Macros\Include_Local_CCLMacroCatAutoCalls.SAS";
options linesize=165 pagesize=65 nocenter nodate NOFMTERR;

libname sabre_ds "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\AnalysisDatasets";
libname tables2 "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Dictionaries";
libname sabreTab "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Tables";
%directory(dir=sabre_ds)
%contents(sabre_ds.t4_malap)

/*data deleted_val;*/
/*    set sabre_ds.t4_malap;*/
/*    if mal_any =1*/
proc freq data=sabre_ds.t4_malap ;
    tables mal_any * ivustimp / list out=test missing;
    run;

proc sql; select * from test; quit;

%macro smallcriteria(in=, out=, category=, index=);
  
    data new;
    	set &ds;
    	keep &in;
    run;

    proc contents data=new;
    ods output variables=_var;
    run;

    %count(_var, macroout=Nvar)
    %count(new, macroout=N)

    /* Gives frequency - n(%) - of all binary variables*/
    %do smallcriteria_i=1 %to &Nvar;
        data _null_;
        	set _var(firstobs=&smallcriteria_i obs=&smallcriteria_i);
        	call symput('curv', variable);
        run;

        data _count;
        	set new;
        	where &curv = &index;
        run;

        %count(_count, macroout=Nm)

        data &curv;
            Criteria="&curv";
            frequency=cats("&Nm/&N(",put(&Nm/&N,percent7.1),")");
        run;

    /**/
    %end;

    data &out;
    	set &in;
    run;

    data &out;
    	set &out _tog;
    	length category $ 30;
    	category="&category";
    run;

    /* delete datasets */

%mend smallcriteria;
