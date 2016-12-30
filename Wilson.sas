/*!
*   Gives frequency and 95% CI for binomial probability from Wilson test
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\
*
*   @author     YLuo
*   @created    18AUGUST2015
*
*/

/*  *************************************************************************************************************   */
*      Macro Name: Wilson                                                                                           *;
*          Author: YLuo & CLitherland                                                                               *;
*    Date Created: 18AUGUST2015                                                                                     *;
*   File Location: P:\DataAnalysis\Interns\Yiwen Luo\YL Macro                                                       *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose: Gets frequency and 95% CI for binomial probability                                              *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros: % count                                                                                         *;
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
 *  Creates a dataset containing frenquency and Wilson 95% CI for a binary variable
 *
 * @param dataset            Input dataset
 * @param varlist       All BINARY variables to be analyzed
 * @param index         Value of outcome variable of interest that should be summarized
 * @param out           Output dataset
 *
 */ 

%macro Wilson(dataset=, var=, index=1, out=);

/* CCL Note: Add checks here / error code plan */

        %count(_notmissing, macroout=N) 
        %count(_count, macroout=Nm)
        
        %IF &Nm ^= 0 %THEN %DO;
			proc sort data=&dataset;
				by descending &var;
			run;

            proc freq data=&dataset order=data;
            	tables &var. / binomial(wilson);
            	ods output BinomialCLs = BinomialCLs;
            run;

            data &out;
            length event $ 35 statistics $ 25 result $ 40;
            	set BinomialCLs;
	            Event="&var";
            	Statistics="n/N (%)";
            	Result=cat("&Nm/&N (", strip(put(&Nm/&N,percent7.1)), ")");
				keep event statistics result;
                OUTPUT;
            	Event="&var";
            	Statistics="95% CI";
            	Result=cat('(', strip(put(LowerCL,best4.1)), ', ', strip(put(UpperCL,best4.1)), ')');
				keep event statistics result;
                OUTPUT;
            run;


        %END;
        
        %IF &Nm = 0 %THEN %DO;
            data &out;
            length event $ 35 statistics $ 25 result $ 40;
            	Event="&var";
            	Statistics="n/N (%)";
            	Result=cat("&Nm/&N (", strip(put(0,percent7.1)), ")");
                OUTPUT;
                Event="&var";
                Statistics="95% CI";
            	Result="N/A";
                OUTPUT;
            run;
		%END;


    /* Delete datasets, clear global variables */
    proc datasets nolist;
    	delete binomialcls ci _var &varlist new _N;
    quit;

    %symdel N Nm N_var / nowarn;
%mend Wilson;
