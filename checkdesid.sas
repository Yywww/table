/*  *************************************************************************************************************   */
*    Program Name: 												                                                    *;
*         Query #:                                                                                                  *;
*         Issue #:                                                                                                  *;
*          Author: Y Luo                                                                                  *;
*    Date Created:                                                                                                  *;
*   File Location:                                                                                                  *;
*                                                                                                                   *;
*           Study:                                                                                                  *;
*    Investigator:                                                                                                  *;
*         Purpose:                                                                                                  *;
*                                                                                                                   *;
* Description of Major Sections of the Program:                                                                     *;
*                                                                                                                   *;
* Related files / notes :                                                                                           *;
*                                                                                                                   *;
*                                                                                                                   *;
*  Date Completed:                                                                                                  *;
*  Final Datasets:                                                                                                  *;
*    Final Output:                                                                                                  *;
*                                                                                                                   *;
* Revision History: ddmmmyyyy  -  Updated by xxx                                                                    *;
/*  **************************************************************************************************************  */
/********************************************************************************************************************
Macro name: checkdesid

Written by: Yiwen Luo

Creation date: Sunday, January 03, 2016 13:26:46

As of date: 

SAS version: 9.4

Purpose: To check if a patient is in a certain dataset

Parameters(required):
 
Parameters(optional):

Sub-macros called: 

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/

%macro checkdesid(desid,dataset);

data _check_;
	set &dataset;
	patient=0;
	if upcase(strip(desid))=upcase(strip("&desid")) then patient=1;
	keep patient;
run;

proc means data=_check_ max;
var patient;
run;


%mend checkdesid;

