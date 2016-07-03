/*!
*   Determines the variable types for all variables in the given dataset
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\UtilityMacros\Utilities
*
*   @author YLuo
*   @author CLitherlan
*   @created  03JUNE2015
*
*/

/*  **************************************************************************************************************  */
*     Macro name: detectvariabletype
*     Written by: Yiwen Luo - edited by Clitherland on 22JULY2015
*  Creation date: Jun03 2015
*     As of date: Thursday, June 11, 2015 09:40:21
*    SAS version: 9.4
* 
*   Validated by:
* Date Validated:
* 
*        Purpose: detect variable type in one dataset
*
* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
* dataset                                                                                                           *;
*                                                                                                                   *;
* OPTIONAL PARAMETERS                                                                                               *;
* out                                                                                                               *;
* rot               rule of thumb, over how many levels can a variable be determined as a continus variable         *;
*                                                                                                                   *;
* ================================================================================================================= *;
*
/* Sub-macros called: %count %varloop %countdigit                                                                                         */
*  Data sets created: Nlevels
*        Limitations: don't know if it can handle missing
* 
*              Notes: 
* 
*  Sample Macro call: %detectvariabletype(mydata,out=result)
*                                                                                                                   *;
/*  **************************************************************************************************************  */

/**
*   Determines the variable type of all varaibles in the given dataset
* 
*   @param  dataset Input dataset
*   @param  out Name of dataset to output
*   @param  rot Rule Of Thumb - how many levels should there be to distinguish between categorical variables and continuous ones
*   @param  show_summary    Show summary of variable types in the dataset
* 
*/



%macro detectvariabletype(dataset, out=result, rot=10, show_summary=YES);
    /* Turn off all output listings */
    ods select none ;

    proc freq data=&dataset NLEVELS;
    ods output Nlevels=Nlevels;
    run;

    data _null_;
        dset=open('Nlevels');
        call symput ('check', varnum(dset,'NnonmissLevels'));
    run; 

    %if &check gt 0 %then %let level=NnonmissLevels;
    %else %let level=NLevels;

    %count(&dataset, macroout=N)
	
	proc contents data=&dataset;
	ods output variables=charnum;
	run;

	data charnum;
		set charnum;
		Tablevar=variable;
	run;

	proc sort data=charnum;by Tablevar;run;
	proc sort data=Nlevels;by Tablevar;run;

    data firstdetect;
    	merge Nlevels charnum;
		by Tablevar;
    	length variabletype $50;
/* CCL Note [22JULY2015]: Is this always true?  what if it is a measureed variable or something like age */
/*                        that could have as many distinct values as observations?  Not sure how to fix / detect that */
/*                        but its something to think about...                                                           */
        if &level=&N then variabletype="id variable";
    	else if &level=1 then variabletype="this variable has only one value";
    	else if &level=2 then variabletype="binary variable";
    	else if &level>=3 and &level<=&rot or &level>=3 and type='Char' then variabletype="categorical variable";
    	else variabletype="continuous variable";
    	keep Tablevar variabletype TableVarLabel;
    run;


	/*  **************************************************************************************************************  */
/* this data step select variables may be categorized wrong and check them using %countdigit */

	data numvariabletobecheck;
		merge Nlevels charnum;
		by Tablevar;
		if &level>=3 and &level<=&rot and type='Num';
	run;

	%count(numvariabletobecheck,macroout=abc)

	%if &abc^=0 %then %do;

    proc sql;
        select strip(Tablevar)
        into : vartobecheck
        separated by ' '
        from numvariabletobecheck;
    quit;

	
/* CCL Note [01SEPTEMBER2015]: YIWEN  :(  What is going on here?  does this work?  Why is countdigit defined in this macro? And in a data step?!? */

	%varloop(dataset=&dataset,in=&vartobecheck,out=digit,macrotouse=countdigit)

	data seconddetect;
		set digit;
		if digit='not equal' then VariableType='continuous variable';
		else VariableType=' ';
		Tablevar=variable;
	run;

	%end;

	/*  **************************************************************************************************************  */



    proc contents data=&dataset;
    ods output Variables=form;
    run;

    data date;
    	set form;
    	Tablevar=Variable;
    	if find(format,'DATE') gt 0 then VariableType="Date Variable";
    	keep Tablevar VariableType;
    run;

    proc sort data=date;
    	by TableVar;
    run;

    proc sort data=firstdetect;
    	by Tablevar;
    run;


	%if &abc^=0 %then %do;

	proc sort data=seconddetect;
		by Tablevar;
	run;

    data firstdetect;
        length tablevar $ %GetMaxLen(firstdetect seconddetect, tablevar);
    	update firstdetect seconddetect;
    	by Tablevar;
		keep Tablevar TableVarLabel variabletype;
    run;

	%end;

    data &out;
        length tablevar $ %GetMaxLen(firstdetect date, tablevar);
    	update firstdetect date;
    	by Tablevar;
    run;

    %IF %UPCASE(&show_summary) = YES %THEN %DO;
        ods select all;
    proc report data=&out;
    	title "Variable Type of &dataset";
    	column TableVar TableVarLabel variabletype;
    		define TableVar / display "Variable name in dataset";
    		define TableVarLabel / display "Variable Label";
    		define variabletype / display "Variable Type";
    	compute after;
    					line @2 "                                                                   ";
    		       		line @2 "Please be advised the id variables might be in the wrong category.";
    					line @2 "Also, I don't know why you can't see this result in ods listing.";
    	endcomp;
    run;
        ods select none;
    %END;

    proc datasets library=work nolist nodetails;
    	delete Nlevels form date firstdetect charnum numvariabletobecheck seconddetect;
    run;
    quit;

    /* Restore ODS output */
    ods select all;

%mend detectvariabletype;





/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, September 02, 2015 08:55:11*/
