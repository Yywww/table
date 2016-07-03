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
 * @param dataset       Input dataset
 * @param groupvar      Grouping variable
 * @param dependentvar  Binary variable to be analyzed
 * @param out           Output dataset
 * @param outputfmt     Output dataset
 * 
 */ 


%macro binarysummary(dataset=, groupvar=, dependentvar=, out=, outputfmt=);
    %MacroNoteToLog;
    ods select NONE;
/*  ==============================================================================================================  */
/* @section Error checks                                                                                            */
/*  ==============================================================================================================  */
    %if %superq(DATASET)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DATASET.;
        %return;
    %end;
    %if %superq(GROUPVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for GROUPVAR.;
        %return;
    %end;
    %if %superq(DEPENDENTVAR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DEPENDENTVAR.;
        %return;
    %end;
    %if %superq(OUT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;
    %IF %varexist(ds=&dataset, var=&groupvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &groupvar is not in &dataset.;
        %return;
    %END;
    %IF %varexist(ds=&dataset, var=&dependentvar) = 0 %THEN %DO;
        %PUT %str(E)RROR: &dependentvar is not in &dataset.;
        %return;
    %END;
    /* Check that the dependent variable is actually binary. */
    %dstCnt(ds=&dataset, dstvar=&dependentvar, outvar=bincheck);
    %IF &bincheck > 2 %THEN %DO;
        %PUT %str(E)RROR: &dependentvar has more than 2 values - do not use binarysummary.;
        %return;
    %END;
    %symdel bincheck / nowarn;

/* CCL Note [01SEPTEMBER2015]: Add check for variable name that is "too" long - if it is, maybe give it a shorter name? */

    %getlevel(&dataset, out=&groupvar._info, factor=&groupvar);
/*	%let n_level = %nobs(&groupvar._info);*/
	%count(&groupvar._info, macroout=n_level);

    %DO noflevel=1 %TO &n_level;
    data _null_;
        set &groupvar._info(firstobs=&noflevel obs=&noflevel);
        call symput('currentfac', factorvalue);
    run;

	%freqgroup(ds=&dataset, var=&dependentvar, groupvar=&groupvar, index=&currentfac, out=var_&noflevel);
	%END;

	data new;
		set &dataset;
		keep &dependentvar;
	run;

	%count(new, macroout=N)

	data _count;
		set new;
		where &dependentvar=1;
	run;

	%count(_count, macroout=Nm)

	data total;
		length variable $ 30 statistics $ 50 total $ 20;
		Variable="&dependentvar";
		Statistics="n/N (%)";
/*		Total=cat("&Nm / &N (", strip(put(&Nm/&N, percent7.1)), ")");*/
		Total=cat("%cmpres(&Nm) / %cmpres(&N) (", strip(put(&Nm/&N, percent7.1)), ")");
	run;

	data &out;
	merge %range(to=&n_level., opre=var_) total;
	by variable;
	run;

/*  ==============================================================================================================  */
/* @section Delete intermediate datasets and clear global macro variables.                                          */
/*  ==============================================================================================================  */

	proc datasets library=work nolist nodetails;
		delete %range(to=&n_level., opre=var_) new total &groupvar._info _count;
	quit;

    %symdel N Nm n_level/ nowarn;
    ODS SELECT ALL;
%mend binarysummary;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Monday, August 10, 2015 11:31:06*/
