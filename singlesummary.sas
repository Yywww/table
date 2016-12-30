/*!
*   return Description}
*   <br>
*   <b> Macro Location: <\b> P:\DataAnalysis\MACRO_LIB\CRF Macro Library\
*
*   @author
*   @created
*
*/
/*  *************************************************************************************************************   */
*    Program Name: singlesummary(temp)												                                *;
*          Author: Y Luo                                                                                            *;
*    Date Created:                                                                                                  *;
*   File Location:                                                                                                  *;
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

%MACRO singlesummary(dataset=, var=, out=, outvar=result, outfmt=5.1);
/*    %MacroNoteToLog;*/

     proc means data=&dataset alpha=0.05 n median mean std min max Q1 Q3 lclm uclm;
         var &var;
         output out=_Summ n=n median=median mean=mean std=std min=min max=max Q1=Q1 Q3=Q3 lclm=lclm uclm=uclm;
         run;

    %LET plusminus = %sysfunc(byte(177));

    data &out(keep=variable &outvar statistics statc);
    	length &outvar $ 20;
    	length statistics $20;
    	length variable $50;
    	if 0 < nobs then set _Summ nobs=nobs;
    	variable="&var";
    	do statc=1 to 5;

    	if statc=1 then do;
    		if missing(n) then &OUTVAR='0';
    		else &OUTVAR=strip(put(n, 7.));
    		statistics='N';
    		output;
    	end;
/* CCL Note [11SEPTEMBER2015]: Changing order of statistics per AB's Request */
    	else if statc=4 then do;
    		if missing(median) then &OUTVAR=' N/A';
    		else &OUTVAR=left(cat(strip(put(median, &OUTFMT.)),' [', strip(put(Q1, &OUTFMT.)), ', ', 
                                  strip(put(Q3, &OUTFMT.)), ']'));
    		statistics='Median [Q1, Q3]';
    		output;
    	end;
    	else if statc=2 then do;
    		if missing(mean) then &OUTVAR=' N/A';
    		else &OUTVAR=left(cat(strip(put(mean, &OUTFMT.))," &plusminus ", strip(put(std, &OUTFMT.))));
    		statistics="Mean &plusminus SD";
    		output;
    	end;
    	else if statc=5 then do;
    		if missing(min) and
    		missing(max) then &OUTVAR=' N/A';
    		else &OUTVAR='('|| strip(put(min, &OUTFMT.))||', '|| strip(left(put(max, &OUTFMT.))) ||')';
    		statistics='(Min, Max)';
    		output;
    	end;
    	else if statc=3 then do;
    		if missing(lclm) and
    		missing(uclm) then &OUTVAR=' N/A';
    		else &OUTVAR='('|| strip(put(lclm, &OUTFMT.))||', '|| strip(left(put(uclm, &OUTFMT.))) ||')';
    		statistics='95% CI';
    		output;
    	end;
    end;
    run;

    /* Delete intermediate datasets */
    proc datasets nolist; 
        delete _Summ; 
    quit;
%MEND singlesummary; 
