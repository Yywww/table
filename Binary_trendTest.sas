/*  *************************************************************************************************************   */
*      Macro Name: ADAPT125_stupidTable.SAS                                                                             *;
*          Author: C Litherland                                                                                     *;
*    Date Created: 06AUGUST2015                                                                                     *;
*   File Location: H:\CCL Macros\Macros                                                                             *;
*                                                                                                                   *;
*    Validated By:                                                                                                  *;
*  Date Validated:                                                                                                  *;
*                                                                                                                   *;
*         Purpose: Caculates Cochran-Armitage test for trend                                                        *;
*           Notes:                                                                                                  *;
*                                                                                                                   *;
*      Sub-Macros:                                                                                                  *;
*           Usage:                                                                                                  *;
*                                                                                                                   *;
* ================================================================================================================= *;
* PARAMETERS:                                                                                                       *;
* -------name------- -------------------------description---------------------------------------------------------- *;
*                                                                                                                   *;
*                                                                                                                   *;
* ================================================================================================================= *;
/*  **************************************************************************************************************  */
%MACRO adapt125_stupidTable(ds, contvar=, binvar=, catvar=, output_ds=);
    %LET plusminus=%sysfunc(byte(177));

%DO bin_iter=1 %TO %WORDS(&binvar);
    %LET curr_binvar = %scan(&binvar, &bin_iter);
/* Binary Variables */
    ods output TrendTest = &curr_binvar._trend;
    proc freq data = adapt125;
        tables plt_base / out=&curr_binvar._all;
        tables &curr_binvar. * plt_base / norow nopercent trend list out=&curr_binvar._nperc outpct;
        where not missing(&curr_binvar.);
        run;

    proc sql;
        create table &curr_binvar. as
        select "&curr_binvar." as factor, nperc.plt_base,
                cat(strip(put(nperc.pct_col, 8.2)), "% (", strip(put(nperc.count, 8.)), "/", strip(put(denom.count, 8.)), ")") as summInfo,
                p.nvalue1 format=pvalue8.4 as pvalue, 1 as test_type
        from &curr_binvar._trend(where=(name1="P2_TREND")) as p, &curr_binvar._nperc(where = (&curr_binvar.=1)) as nperc
        LEFT JOIN
            &curr_binvar._all as denom
            on nperc.plt_base = denom.plt_base;
    quit;
%END;

%DO cat_iter = 1 %TO %words(&catvar);
    %LET curr_cat = %scan(&catvar, &cat_iter);
/* Categorical */
    proc means data = adapt125 median q1 q3 ndec=2;
        class plt_base;
        var &curr_cat;
        output out=&curr_cat._mediqr median=median q1=q1 q3=q3;
        run;

    proc npar1way data = adapt125 wilcoxon;
        class plt_base;
        var &curr_cat;
        output out=&curr_cat._p wilcoxon;
        run;

    proc sql;
        create table &curr_cat as
        select "&curr_cat" as factor, plt_base,
                cat(strip(put(median, 8.2)), " [", strip(put(q1, 8.2)), ", ", strip(put(q3, 8.2)), "]") as summInfo,
                p_kw as pvalue, 2 as test_type
        from &curr_cat._mediqr(where=(_TYPE_ = 1)), &curr_cat._p;
        quit;
%END;


%DO cont_iter=1 %TO %words(&contvar);
    %LET curr_contvar=%scan(&contvar, &cont_iter);
    /* Continuous Variables */
    proc means data = adapt125 n mean std median q1 q3 ndec=2;
        class plt_base;
        var &curr_contvar;
        output out=&curr_contvar._meanstd mean=mean std=std ;
        run;

    ods  output  'Type III Model ANOVA'=&curr_contvar._p;
    proc glm data=adapt125;
         Class plt_base;
         model &curr_contvar = plt_base  ;
    run;
    quit;

    proc sql;
        create table &curr_contvar as
        select "&curr_contvar" as factor, mean.plt_base, 
                cat(strip(put(mean.mean, 8.1)), " &plusminus ", strip(put(mean.std, 8.1))) as summInfo,
                p.probf as pvalue, 3 as test_type
        from &curr_contvar._meanstd(where=(_TYPE_=1)) as mean, &curr_contvar._p as p;
        quit;

%END;

    data &output_ds;
    length factor $ 50 summInfo $20;
        set &contvar &binvar &catvar;
    run;























