/*!
*   Returns a dataset with frequency summary information for a variable for a specified value of the grouping variable
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
*
* @author Yiwen Luo
* @created Thursday, August 06, 2015 13:48:37
*/

/********************************************************************************************************************
            Macro name: freqgroup
            Written by: Yiwen Luo
         Creation date: Thursday, August 06, 2015 13:48:36
            As of date: 
           SAS version: 9.4

               Purpose: Give frequency table of multiple variable in a certain group

  Parameters(required): ds=
                        in=
                        out=
                        groupvar=
                        index=
 
  Parameters(optional):

     Sub-macros called: % count
     Data sets created: 

           Limitations: 
                 Notes: Called by % binarysummary

Sample Macro call: 

*************************************************************************************************************/
/**
 * Creates a dataset containing frequencies of a binary variable for one level of a group variable 
 *
 * @param ds        input dataset
 * @param in        variable need to be analyzed(can be one variable or a variable list)
 * @param out       output dataset
 * @param groupvar  group variable 
 * @param index     group variable value (level)
 */ 

%macro freqgroup(ds=, var=, groupvar=, index=, out=&var);

    data new;
    	set &ds;
    	where &groupvar=&index and &var^=.;
    	keep &var;
    run;
    

    %count(new, macroout=N)

    data _count;
    	set new;
    	where &var=1;
    run;

    %count(_count, macroout=Nm)

    data &out;
    length variable $50 statistics $50;
        Variable="&var";
        Statistics="n/N(%)";
        &groupvar._&index=cats("&Nm/&N(",put(&Nm/&N,percent7.1),")");
    run;


    proc datasets library=WORK nolist nodetails;
        delete new _count;
        run;
        quit;
    /* Delete global macro variables */
        %symdel N Nm / NOWARN;

%mend freqgroup;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Thursday, August 06, 2015 13:51:01*/
/*%freqgroup(ds=sabre_ds,var=RCA,groupvar=IVUSTIMP,index=2)*/
