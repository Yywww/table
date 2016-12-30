option nofmterr;
libname sabre_ds "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\AnalysisDatasets";
libname tables2 "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Dictionaries";
libname sabreTab "P:\DataAnalysis\Caliber Therapeutics\SABRE\IVUS\Tables";
%include 'P:\DataAnalysis\Interns\Yiwen Luo\MacroAutoCall.sas';

%bincontable(ds=sabre_ds.T2_planar, ds_dictionary=tables2.t2_planarvarlist, groupvar=IVUSTIMP, out=thiswillwork)
%bincontable(ds=sabre_ds.T4_malap, ds_dictionary=tables2.t4_malapvarlist, groupvar=IVUSTIMP, out=thiswillworktoo)
data blerg;
    set sabre_ds.t4_malap;
    keep ivustimp mal_plqbur mal_vesar;
    run;
data blergvarlist;
    set tables2.t4_malapvarlist;
    where variableName in ("MAL_PLQBUR", "MAL_VESAR");
    run;
options mprint symbolgen ;
%bincontable(ds=blerg, ds_dictionary=blergvarlist, groupvar=IVUSTIMP, out=small)


%bincontable(ds=sabre_ds.t5_diss, ds_dictionary=tables2.t5_dissvarlist, groupvar=IVUSTIMP, out=t5)


proc sql number;
    select variablename, sastype
    from sabredic.t3_volumvarlist;
    quit;
