/*  *************************************************************************************************************   */
*      Macro Name: variableloop                                                                                     *;
*          Author: C Litherland                                                                                     *;
*    Date Created: 06AUGUST2015                                                                                     *;
*   File Location: P:\DataAnalysis\Interns\Yiwen Luo\YL Macro                                                       *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose: Loop over list of Variables in dictionary to run appropriate analysis                           *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros:                                                                                                  *;
*           Usage:                                                                                                  *;
*                                                                                                                   *;
* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
* ds                                                                                                                *;
* ds_dictionary                                                                                                     *;
* out                                                                                                               *;
* groupvar                                                                                                          *;
*                                                                                                                   *;
* ================================================================================================================= *;
/*  **************************************************************************************************************  */

%MACRO variableloop(ds, ds_dictionary=, out=, groupvar=);
    %PUT %STR(**********************************************************************************************************);
    %PUT ;
    %PUT Macro Name: %pgmname ;
    %PUT Run By: %SYSGET(USERNAME) On &sysdate at &systime;
    %PUT This macro is NOT Validated.;
    %PUT ;
    %PUT %STR(**********************************************************************************************************);
/*  *****************************************************  */
    proc sql;
        select strip(VariableName)
        into : VarList
        separated by ' '
        from &ds_dictionary
        where not missing(VariableName);
    quit;

    %DO varlist_iter=1 %TO %words(&VarList);
        %LET curr_var = %SCAN(&VarList, &varlist_iter);
    /* if dict says continuous then run this       */
        %continuous(dataset=&ds., var=&curr_var., groupvar=&groupvar.);
    /* if dict says bianry run this */
       /* %binary */
    %END;

    data &out;
        set &varList;
    run;
%MEND;
