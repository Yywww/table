
/*!
 * 
 *
 * @author Yiwen Luo
 * @created Friday, August 07, 2015 10:37:10
 */
/********************************************************************************************************************
Macro name: Report

Written by: Yiwen Luo

Creation date: Thursday, August 06, 2015 10:00:45

As of date: 

SAS version: 9.4

Purpose: 

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description:
 *
 * @param <param-name> <param-description>
 * @param 
 * @param 
 * @param 
 * @return 
 */ 


/*For format reference*/

options linesize=100 nofmterr mergenoby=error msglevel=i replace;
libname sabre_ds "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\AnalysisDatasets";
libname tables2 "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Dictionaries";
libname sabreTab "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Tables";
%include 'P:\DataAnalysis\Interns\Yiwen Luo\MacroAutoCall.sas';
options linesize=165 pagesize=65 nocenter nodate NOFMTERR;
%addautos(ylmac, last);



proc sql;
    create table t2_planar_TableData as
    select dict.pgord, dict.sequence, dict.variableDesc,
           var.*,
            CASE
                when statistics = "N" then 1
                when statistics = "Mean ± SD" then 2
                when statistics = "Median [Q1, Q3]" then 3
                when statistics = "Range (min, max)" then 4
                else .
            end as stat_order
    from tables2.t2_planarvarlist as dict
    LEFT JOIN
        t2_plan_table as var
        on strip(upcase(dict.variableName)) = strip(upcase(var.variable))
    order by dict.pgord, dict.sequence, stat_order;
quit;

proc freq data = sabre_ds.t2_planar;
    tables ivustimp / out=group_n;
    run;

data _null_;
    set group_n;
    if IVUSTIMP = 1 then call symput('N_ivustimp_1', strip(count));
    if IVUSTIMP = 2 then call symput('N_ivustimp_2', strip(count));
    if IVUSTIMP = 3 then call symput('N_ivustimp_3', strip(count));
run;


/*  **************************************************************************************************************  */
/*  **************************************************************************************************************  */
/*  **************************************************************************************************************  */

/* OUTPUT TABLE FORMATTING */

libname source  'P:\DataAnalysis\Caliber Therapeutics\SABRE\Export';

libname crftemp "P:\DataAnalysis\REVA\RESTORE_OCT\Style Templates";
ODS PATH ods path work.templat(update) crftemp.crftables(read) crftemp.crfreports(read) sasuser.templat(read) sashelp.tmplmst(read);

/* Create report */
title; footnote;
options orientation=landscape ;
options nonumber nodate missing=' '
      bottommargin = "0.5in"
      topmargin = "0.5in"
      rightmargin = "0.5in"
      leftmargin = "0.5in";
ods escapechar="^"; 

ods listing close;
ODS rtf file="P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Tables\T2_planar_7_23pm.rtf" style=Styles.crftables;

title1 j=l "Caliber Therapeutics, Inc." j=r "Page ^{pageof}";
title2 j=l "Study: SABRE IVUS" j=r "Draft: Confidential";
title3 " " ;
title4 j=c "Table 2: Planar IVUS, Minimum Lumen Area Site in Stent and Reference Segement" ;
title5 j=c "1 Lesion Per Patient";

footnote7  j=r "Created on: &sysdate &systime"; 
footnote8 j=l "Program: %pgmname" j=r "Data Extract Date: %crdte(source.civus, datetime20.)"; 


proc report data=t2_planar_tableData/*(where=(ReportNum=&rptnum))*/ nowindows split='*' PS=120 headline headskip wrap 
   style(column) = [asis=on] missing;
		column pgord sequence VariableDesc stat_order statistics IVUSTIMP_1 IVUSTIMP_2 IVUSTIMP_3;
	define pgord         / group order=internal noprint ;
    define sequence      / group order=internal noprint ;
    define stat_order    / group order = internal noprint;
    define VariableDesc  / group "Category" style(column) = [font_size=8pt CELLWIDTH=200pt] width=1 style(header)={font_size=9.5pt} missing;
	define Statistics        / display center "Statistics" style(column) = [font_size=8pt CELLWIDTH=100pt];
    define IVUSTIMP_1        / display center "Post-Balloon*(N=&N_ivustimp_1)" style(column) = [font_size=10pt CELLWIDTH=110pt];
	define IVUSTIMP_2        / display center "Post-Drug Eluting Balloon *(N=&N_ivustimp_2)" style(column) = [font_size=10pt CELLWIDTH=110pt];
	define IVUSTIMP_3        / display center "6 months Post Procedure *(N=&N_ivustimp_3)" style(column) = [font_size=10pt CELLWIDTH=110pt];
	break after pgord/ PAGE;
run;
ods rtf close;
ods listing;

