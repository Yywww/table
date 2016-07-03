/*!
*   Determines whether a variable is time to event by checking dataset for the same variable with the suffix days
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\UtilityMacros\Utilities
*
*   @author     YLuo
*   @created    05JUNE2015
*
*/

/********************************************************************************************************************
    Macro name: detectlogrank
    Written by: Yiwen Luo
 Creation date: Friday, June 05, 2015 14:09:51
    As of date: Wednesday, June 10, 2015 15:51:18
    SAS version: 9.4

              Purpose: detect survival variable pair
 Parameters(required): detectresult(the result from %detectlogrank),
                       out=
 Parameters(optional):

    Sub-macros called: % count
    Data sets created: dataset specified by out - defaults ot logrank
          Limitations: 
                Notes: 

Sample Macro call: detectlogrank(result)

*************************************************************************************************************/
/**
*   Determine whether a variable is a time to event variable by checking for other variables in the same dataset with the suffix days
* 
*   @param  detectresult    Dataset created by macro % detectvariabletype
*   @param  out             Name of ouput dataset containing names of logrank variables
* 
*/
%macro detectlogrank(detectresult, out=logrank);
    data result;
    	set &detectresult;
    run;

    data event timeevent;
    	set result;
    	if upcase(variabletype) in ("BINARY VARIABLE" "THIS VARIABLE HAS ONLY ONE VALUE") then output EVENT;
        if upcase(variabletype) = "CONTINUOUS VARIABLE" then output TIMEEVENT;
    run;

    %count(event, macroout=nb)

    %do i=1 %to &nb;
        data _null_;
        	set event(firstobs=&i obs=&i);
        	call symput('varname',cats(TableVar));
        run;

        data whatever;
        	set timeevent;
        	if upcase(TableVar)=upcase("&varname.Days");
        run;

        %count(whatever, macroout=lr_days)
        %if &lr_days=1 %then %do;
        	data result;
        		length pair $50;
        		set result;
        		if upcase(TableVar)=upcase("&varname") then do;
        				pair=upcase("&varname.Days");
        				variabletype="Logrank Binary";
        				end;
        		if upcase(TableVar)=upcase("&varname.Days") then do;
        				pair=upcase("&varname");
        				variabletype="Logrank Continuous";
        				end;
        	   run;
        	%end;
    %end;


    data &out;
    	set result;
    	length pair $50;
    	if pair=" " then pair="None";
    run;

    /* Clear Datasets and global macro variables */
    proc datasets library=work nolist nodetails;
    	delete whatever result event timeevent;
    run;
    quit;

    %symdel lr_days nb / nowarn;


%mend detectlogrank;


/* **** End of Macro **** */
/* **** by Yiwen Luo **** */
/*Friday, June 05, 2015 14:08:07*/

