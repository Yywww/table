/*!
 * Give summary information for one binary variable by a group variable. 
 * <br>
 * <b> Macro Location: </b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
 *
 * @author Yiwen Luo
 * @created Monday, August 10, 2015 09:18:11
 */
/********************************************************************************************************************
            Macro name: binarysummary
            Written by: Yiwen Luo
         Creation date: Monday, August 10, 2015 09:18:20
            As of date: 
           SAS version: 9.4

               Purpose: Give summary information of one binary variable
  Parameters(required): ds=
                        groupvar= 
                        var= 
                        out= 
  Parameters(optional):

     Sub-macros called: 
     Data sets created: 

           Limitations: group variable name can not be very long
                 Notes: 

     Sample Macro call: % binarysummary(ds = testset, groupvar = vessel_disease, var = male, out = try)

*************************************************************************************************************/
/**
 * Gives summary information (n/N %) for one binary variable by a grouping variable.
 *
 * @param ds        Input dataset
 * @param groupvar  Grouping variable
 * @param var       Binary variable to be analyzed
 * @param out       Output dataset
 * 
 */ 


%macro binarysummary(ds=,groupvar=,var=,out=);
/*    %MacroNoteToLog;*/

    /* CCL Note [17AUGUST2015]: Add checks and escape routes for macro */
/* CCL Note [01SEPTEMBER2015]: Add check for variable name that is "too" long - if it is, maybe give it a shorter name? */

    %getlevel(&ds, out=&groupvar._info, factor=&groupvar);
	%let n_level = %nobs(&groupvar._info);
    %do noflevel=1 %to &n_level;/*no i*/
    data _null_;
        set &groupvar._info(firstobs=&noflevel obs=&noflevel);
        call symput('currentfac', factorvalue);
    run;

	%freqgroup(ds=&ds, var=&var, groupvar=&groupvar, index=&currentfac, out=var_&noflevel);
	%end;

	data new;
		set &ds;
		keep &var;
	run;

	%count(new,macroout=N)

	data _count;
		set new;
		where &var=1;
	run;
	%count(_count,macroout=Nm)
	data total;
		length variable $30 statistics $50;
		Variable="&var";
		Statistics="n/N (%)";
/*		Total=cat("&Nm / &N (", strip(put(&Nm/&N, percent7.1)), ")");*/
		Total=cat("%cmpres(&Nm) / %cmpres(&N) (", strip(put(&Nm/&N, percent7.1)), ")");
	run;

	data &out;
	merge %range(to=&n_level., opre=var_) total;
	by variable;
	run;

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level., opre=var_) new total &groupvar._info _count;
	quit;
%mend binarysummary;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 11:31:06*/
