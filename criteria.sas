/*!
 * Give descriptive table of distribution of patients among different criteria.
 * Design to fill sheet 'Eligibility_miss' in Table Shell.
 * Haven't finish function that can delete result when frequency=0.
 * @author Yiwen Luo
 * @created Tuesday, August 04, 2015 10:14:54
 */
/*  *************************************************************************************************************   */
*      Macro Name: criteria.sas                                                                                     *;
*          Author: Y Luo                                                                                            *;
*    Date Created: 04AUGUST2015                                                                                     *;
*   File Location: P:\DataAnalysis\Interns\Yiwen Luo\YL Macro                                                       *;
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
*                                                                                                                   *;
*                                                                                                                   *;
* ================================================================================================================= *;
/*  **************************************************************************************************************  */

/**
 * Description:
 *
 * @param  ds                input dataset
 * @param  ICNM              Variable that can be catogorize as Inclusion Criteria 
 * @param  AICNM             Variable that can be catogorize as Angiographic inclusion criteria
 * @param  ECM               Variable that can be catogorize as Exclusion critieria
 * @param  AECM              Angiographic Exclusion Criteria
 * @param  ICNM_indicator    Inclusion Criteria not met indicator
 * @param  ECM_indicator     Exclusion critieria met indicator
 * @param  out               output dataset
 * @return  
 */ 


%macro Criteria(ds=,ICNM=,AICNM=,ECM=,AECM=,ICNM_indicator=1,ECM_indicator=1,outvar=,out=);


%macro smallcriteria(in=,out=,category=,index=);

data new;
	set &ds;
	keep &in;
run;

proc contents data=new;
ods output variables=_var;
run;

%count(_var,macroout=Nvar)
%do i=1 %to &Nvar;
data _null_;
	set _var(firstobs=&i obs=&i);
	call symput('curv',variable);
run;

data _withoutmissing;
	set new;
	where &curv^=.;
run;

data _count;
	set new;
	where &curv=&index;
run;
%count(_count,macroout=Nm)
%count(_withoutmissing,macroout=N)

data &curv;
Criteria="&curv";
&outvar=cats("&Nm/&N(",put(&Nm/&N,percent7.1),")");
if index(&outvar,'0/0')>0 then &outvar='N/A';
run;

%end;
data &out;
	set &in;
run;


%mend smallcriteria;

%smallcriteria(in=&ICNM,out=ICNM,category=Inclusion Criteria not met,index=&ICNM_indicator)
%smallcriteria(in=&AICNM,out=AICNM,category=Angiographic inclusion criteria not met,index=&ICNM_indicator)
%smallcriteria(in=&ECM,out=ECM,category=Exclusion critieria met,index=&ECM_indicator)
%smallcriteria(in=&AECM,out=AECM,category=Angiographic Exclusion Criteria met,index=&ECM_indicator)


data _null_;
	a="&ICNM &AICNM";
	b=cats(tranwrd(a,' ','=1| '),'=1| ');
	call symput('ifall',b);
run;

data _null_;
	a="&ECM &AECM";
	b=cats(tranwrd(a,' ','=1| '),'=1');
	call symput('ifall2',b);
run;

%put &ifall;
%put &ifall2;


data _all;
	set &ds;
	if &ifall &ifall2;
run;
%count(_all,macroout=Nall)

data _tog;
Criteria="TOTAL";
&outvar=cats("&Nall/&N(",put(&Nall/&N,percent7.1),")");
run;

data &out;
	set ICNM AICNM ECM AECM;
run;

data &out;
	set &out _tog;
	length category $ 50;
	category="&category";
run;

proc datasets nolist;
	delete &ICNM &AICNM &ECM &AECM ICNM AICNM ECM AECM _count _var _tog new;
quit;

%mend Criteria;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Tuesday, August 04, 2015 15:55:08*/





