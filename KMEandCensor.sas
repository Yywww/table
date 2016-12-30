/*!
 * Generate Kaplan-Meier Estimate % (N) and Censored observations % (N) for one logrank variable
 * <br>
 * <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\DataSummaryMacros
 *
 * @author Yiwen Luo
 * @created Tuesday, August 18, 2015 14:20:41
 */
/********************************************************************************************************************
    Macro name: KMEandCensor
    Written by: Yiwen Luo
    Creation date: Tuesday, August 18, 2015 14:19:59
    As of date: 
    SAS version: 9.4

             Purpose: Generate Kaplan-Meier Estimate % (N) and Censored observations % (N) for one logrank variable
 Parameters(required): dataset= 
                       var=
                       out=
 Parameters(optional):

    Sub-macros called: 
    Data sets created: 
          Limitations: 
                Notes: This macro is meant to be called by % varloop

Sample Macro call: % KMEandCensor(dataset=sabre.tttlf, var=TLF6m, out=TLF6m);


*************************************************************************************************************/
/**
 * Description: Generate Kaplan-Meier Estimate % (N) and Censored observations % (N) for one logrank variable
 *
 * @param dataset input dataset name
 * @param var name of the variable to be analyzed
 * @param out output dataset name
 */ 

%MACRO KMEandCensor(dataset=, var=, out=);
/* CCL Note [01SEPTEMBER2015]: Why is this done twice? */    

    ods output  CensoredSummary=CensoredSummary
                ProductLimitEstimates=lrfreqt;
    proc lifetest data=&dataset method=km;
    	time &var.days*&var(0);
    run;

/*    proc lifetest data=&dataset method=km;*/
/*    	time &var.days*&var(0);*/
/*    run;*/

    data _kme;
    	set lrfreqt(where=(Failure^=.)) end=lastobs;
    	if lastobs;
    	length variable $30;
    	result=cats(put(Failure,percent10.1),'(',Failed,')');
    	variable="&var";
    	statistics="Kaplan-Meier Estimate % (N)";
    	keep result statistics variable;
    run;

    data _censor;
    	set censoredsummary;
    	length variable $30;
    	result=cats(put(PctCens,best4.1),'% (',Censored,')');
    	variable="&var";
    	statistics="Censored observations % (N)";
    	keep result statistics variable;
    run;

    data &out;
    	set _kme _censor;
    run;

    /* Delete Intermediate datasets */
    proc datasets library=WORK nolist nodetails;
        delete CensoredSummary lrfreqt _kme _censor;
        run;
        quit;

%MEND;


/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Tuesday, August 18, 2015 14:19:54*/
