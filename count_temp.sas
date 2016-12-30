/*!
*   Counts observations in a dataset and assigns the value to a macro variable <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\CompiledmacroCatalog\Source 
*
*   @author YLuo
*   @created 02JUNE2015
*
*/

/********************************************************************************************************************
        Macro name: count
        Written by: Yiwen Luo
     Creation date: Jun02 2015
        As of date: 
       SAS version: 9.4

            Purpose: count number of observations in a dataset and give its value to a macro,
                        macro name specify by macroout= 

* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
* dataset                                                                                                           *;
*                                                                                                                   *;
* OPTIONAL PARAMETERS                                                                                               *;
* macroout          Name of macro variable containing number of observations DEFAULTS to n                          *;
*                                                                                                                   *;
* ================================================================================================================= *;

 Sub-macros called: 
 Data sets created: work.N(delete when finish)

       Limitations: 
             Notes: 

 Sample Macro call: % count(mydata, macroout=N)

*************************************************************************************************************/
/**
*   Assigns number of observations in a dataset to a macrovariable
* 
*   @param  dataset     [Req] Dataset whose number of observations you want to count
*   @param  macroout    Macro variable name that will contain the number of obs
* 
*/

%macro count(dataset, macroout=N);
%MacroNoteToLog;

    ods select none;
    proc contents data=&dataset ;
        ods output Attributes=Nnn;
    run;
    ods select all;

    %GLOBAL &macroout;
    data _null_;
    	set Nnn;
    	if Label2="Observations" then call symput('thisisanameotherswontuse',cValue2);
    run;

    proc datasets library=work nolist nodetails;
        delete Nnn;
    run; quit;

    %LET &macroout=&thisisanameotherswontuse;
    %PUT &thisisanameotherswontuse;
%mend;


