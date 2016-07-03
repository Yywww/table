/*!
*   Default Setting for rtf print
*   <br>
*   <b> Macro Location: </b> P:\DataAnalysis\MACRO_IN_PROGRESS\Macros for analysisSummaryLoop
*
*   @author Yiwen Luo
*   @created
*
*/
 
/********************************************************************************************************************
Macro name: RtfInitial

Written by: Yiwen Luo

Creation date: Tuesday, March 29, 2016 17:27:14

SAS version: 9.4

File Location: P:\DataAnalysis\MACRO_IN_PROGRESS\Macros for analysisSummaryLoop

Validated By:

Date Validated:

Purpose: Default Setting for rtf print

Parameters(required):	

Parameters(optional):	

Sub-macros called: 

Data sets created: 

Notes: This macro is just to save space in actual program

Sample Macro call: 

*************************************************************************************************************/
 
 
/**
*   Default Setting for rtf print
*
*   @param 
*
*   @return
*
*/

%macro RtfInitial;
%LET currentdatetime = %sysfunc(putn(%sysfunc(datetime()), datetime20.));
libname source  'P:\DataAnalysis\Caliber Therapeutics\SABRE\Export';
libname crftemp "P:\DataAnalysis\REVA\RESTORE_OCT\Style Templates";
ODS PATH ods path work.templat(update) crftemp.crftables(read) crftemp.crfreports(read) sasuser.templat(read) sashelp.tmplmst(read);

title; footnote;
options orientation=landscape ;
options nonumber nodate missing=' '
      bottommargin = "0.5in"
      topmargin = "0.5in"
      rightmargin = "0.5in"
      leftmargin = "0.5in";
ods escapechar="^"; 
%mend;
