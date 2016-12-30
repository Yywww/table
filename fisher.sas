/*!
 * 
 *
 * @author Yiwen Luo	
 * @created Wednesday, August 05, 2015 11:19:20
 */

/**
 * Description:give frenquency rd rr and p-value from fisher
 *
 * @param dataset input dataset
 * @param var variable to be analyzed
 * @param groupvar group variable that 
 * @param vari var indicator
 * @param out output dataset
 * @return 
 */ 

%macro fisher(dataset=,var=,groupvar=,vari=,out=);

proc sort data=&dataset;
	by descending &var descending &groupvar;
run;

%freq(dataset=&dataset,var=&var,groupvar=&groupvar,out=freq)

%if &Zero=1 %then %do;
	data rrrdp;
		length variable $30;
		length rrci $20;
		length rdci $20;
		length Pvalue $6;
		variable="&var";
		rdci="N/A";
		rrci="N/A";
		Pvalue="N/A";
	run;
%end;
%else %do;

proc sort data=&dataset;
by descending &groupvar descending &var;
run;


proc freq data=&dataset order=data;
	tables &groupvar*&var/relrisk riskdiff chisq fisher;
	ods output CrossTabFreqs=CT RiskDiffCol1=rd ChiSq=chi RelativeRisks=rr FishersExact=fish;
run;

data rr_string;
	set rr;
	length variable $30;
	length rrci $50;
	if Statistic="Relative Risk (Column 1)";
	rrci=cats(put(Value,best4.),"[",put(LowerCL,best4.),",",put(UpperCL,best4.),"]");
	variable="&var";
	keep variable rrci;
run;


data rd_string;
	set rd;
	if Row="Difference";
	length variable $30;
	length rdci $50;
	rdci=cats(put(Risk,percentn10.2),"[",put(LowerCL,percentn10.2),",",put(UpperCL,percentn10.2),"]");
	variable="&var";
	keep variable rdci;
run;

data p_string;
	set fish;
	if name1='XP2_FISH';
	variable="&var";
	Pvalue=put(nValue1,pvalue6.4);
	keep variable Pvalue;
run;

data rrrdp;
	merge rr_string rd_string p_string;
	by variable;
run;

%end;

proc sql;
	create table &out as
	select t1.firstgroup,t1.secondgroup,t1.total, t2.*
	from freq as t1, rrrdp as t2
	where t1.variable=t2.variable;
quit;

proc datasets library=work;
	delete freq rrrdp  rr rd chi rr_string rd_string p_string ct fish _fisher_;
quit;
%mend fisher;

/* **** End of Program **** */
/* **** by Yiwen Luo **** */
/*Wednesday, August 05, 2015 11:19:29*/
