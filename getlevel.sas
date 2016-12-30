/*!
*  getlevels - Returns a dataset with the number and value of levels for a categorical variable.
*
* @author Claire Litherland
* @author Yiwen Luo
* @created 05AUGUST2015
*
*/

/*  *************************************************************************************************************   */
*      Macro Name: getlevels                                                                                        *;
*          Author: C Litherland & Y Luo                                                                             *;
*    Date Created: 05AUGUST2015                                                                                     *;
*   File Location: P:\DataAnalysis\Interns\Yiwen Luo\YL Macro                                                       *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose: Returns a dataset                                                                                *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros: % nobs                                                                                           *;
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
* getlevels - Returns a dataset with the number and values of levels for a categorical variable
*
* @param DS &nspb &nspb &nspb Name of dataset containing categorical variable of interest
* @param out Name of output dataset that will contain factor information
* @param factor Name of categorical variable of interest 
*
*/

%MACRO getlevel(ds, out=, factor=); 
%PUT Macro Name: %pgmname ;
%PUT Run By: %SYSGET(USERNAME) On &sysdate at &systime;
%PUT This macro is NOT Validated.;

proc freq data=&ds;
	table &factor ;
	ods output OneWayFreqs=factor(keep = &factor);
run;

data &out(keep = factorName factorValue NfactorLevel);
    set factor;
    factorName = "&factor";
    factorValue = &factor;
    NfactorLevel = resolve('%nobs(factor)');
    attrib factorName label="Name of Categorical Variable";
    attrib factorValue label="Values of Categorical Variable Levels";
    attrib NfactorLevel label="Number of distinct levels";
run;

proc datasets library=WORK nolist nodetails;
    delete factor;
run;
quit;

%MEND;
/* ***** END OF PROGRAM ***** */
    /* ***** CCL 05AUGUST2015 ***** */






