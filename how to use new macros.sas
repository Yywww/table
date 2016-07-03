/*  *************************************************************************************************************   */
*    Program Name: How to use new macros												                                                    *;
*         Query #:                                                                                                  *;
*         Issue #:                                                                                                  *;
*          Author: Y Luo                                                                                  *;
*    Date Created: Thursday, November 05, 2015 14:07:25                                                                                                 *;
*   File Location: P:\DataAnalysis\MACRO_IN_PROGRESS                                                                                                 *;
*                                                                                                                   *;
*           Study:                                                                                                  *;
*    Investigator:                                                                                                  *;
*         Purpose:                                                                                                  *;
*                                                                                                                   *;
* Description of Major Sections of the Program:                                                                     *;
*                                                                                                                   *;
* Related files / notes :                                                                                           *;
*                                                                                                                   *;
*                                                                                                                   *;
*  Date Completed:                                                                                                  *;
*  Final Datasets:                                                                                                  *;
*    Final Output:                                                                                                  *;
*                                                                                                                   *;
* Revision History: ddmmmyyyy  -  Updated by xxx                                                                    *;
/*  **************************************************************************************************************  */



/*I don't know how to use sas %addautos*/


/*  **************************************************************************************************************  */

%include 'P:\DataAnalysis\Interns\Yiwen Luo\MacroAutoCall.sas';



libname adapt 'P:\DataAnalysis\ADAPT DES\2 Year FU\AnalysisDatasets';

libname sabre 'P:\DataAnalysis\Caliber Therapeutics\SABRE\Primary\AnalysisDatasets';
libname sabredic 'P:\DataAnalysis\Caliber Therapeutics\SABRE\Primary\Dictionaries';

%continuoussummary(dataset=adapt.regdata, dependentvar=age, groupvar=CAUC, out=agesumm, outputfmt=)
%continuous_test_ttest2side(dataset=adapt.regdata, dependentvar=age, groupvar=CAUC, out=agetest, outputfmt=)

%varloop(dataset=adapt.regdata, varlist=age bmi CREACL LESLEN P2Y_PRU, varexclude=bmi, groupvar=CAUC, out=test1, summary_macro=continuoussummary, analysis_macro=continuous_test_ttest2side )

%varloop(dataset=sabre.corelab, varlist=%make_dict_list(dictionary=sabredic.corelabvarlist,type=CONTINUOUS), varexclude=, groupvar=RSTGR50, out=test2, summary_macro=continuoussummary, analysis_macro=continuous_test_ttest2side )


