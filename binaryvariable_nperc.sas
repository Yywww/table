
/*!
 *  Creates a frequency table 
 *
 * @author Yiwen Luo
 * @created Thursday, August 06, 2015 13:56:40
 */

/********************************************************************************************************************
           Macro name: binaryvariable_nperc
           Written by: Yiwen Luo
        Creation date: Thursday, August 06, 2015 13:56:41
           As of date: 
          SAS version: 9.4

              Purpose: Give frenquency table of binary variable group by one group variable(need dictionary)
 Parameters(required): ds = 
                       dict = 
                       groupvar= 
                       out=
 
 Parameters(optional):
    Sub-macros called: % getlevel % freqgroup % range

Data sets created: 

Limitations: 

Notes: 

Sample Macro call: 

*************************************************************************************************************/
/**
 * Description: Give frenquency table of binary variable group by one group variable(need dictionary)
 *
 * @param ds input dataset
 * @param dict dictionary dataset used
 * @param groupvar group variable
 * @param out output dataset
 * 
 */ 


%macro binaryvariable_nperc(ds=, ds_dictionary=, groupvar=, out=);
%MacroNoteToLog;

    proc sql;
            select strip(VariableName)
            into : VarList
            separated by ' '
            from &ds_dictionary
            where not missing(VariableName);
        quit;

    %getlevel(&ds, out=&groupvar._info, factor=&groupvar);
        %LET n_level = %nobs(&groupvar._info);

        %DO noflevel=1 %TO &n_level;/*No i*/
        data _null_;
        	set &groupvar._info(firstobs=&noflevel obs=&noflevel);
        	call symput('currentfac', factorValue);
        run;
    			%freqgroup(ds=&ds, in=&Varlist, out=out&noflevel, groupvar=&groupvar, index=&currentfac);
        %END;

    data &out._merge; 
        	length variable $50;
            merge %range(to=&n_level., opre=out);
            by Variable; 
    run;


    proc sql;
        create table &out as
        select dict.pgord, dict.sequence, dict.variableDesc,
               var.*
        from &ds_dictionary as dict
        LEFT JOIN
            &out._merge as var
            on strip(upcase(dict.variableName)) = strip(upcase(var.variable))
        order by dict.pgord, dict.sequence;
    quit;

    proc datasets library=WORK nolist nodetails;
        delete %range(to=&n_level., opre=out) &out._merge;
        run;
        quit;

%mend binaryvariable_nperc;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, August 06, 2015 13:58:34*/


