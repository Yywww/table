/********************************************************************************************************************
Macro name: PrintRtf

Written by: Yiwen Luo

Creation date: Tuesday, March 29, 2016 17:30:30

SAS version: 9.4

Purpose: Print table in rtf file, table must be created by %TablePrint macro

Parameters(required):	file=,
			printds=,
			group=,
			groupvalue=,
			grouplabel=,
Parameters(optional):	author=YLuo,
			font_sz=9,
			cellwd=13


Sub-macros called: %footnote

Sample Macro call: 

*************************************************************************************************************/
 
%macro PrintRtf(file=,printds=,group=,groupvalue=,grouplabel=,author=YLuo,font_sz=9,cellwd=13);

%let Ngroup=%sysfunc(countw(%superq(groupvalue),'#'));
%do i = 1 %to &Ngroup;                                                                                                              
%let value&i=%qscan(%superq(groupvalue),&i,%str(#));                                                                                      
%end; 

%put &value1;

%do i = 1 %to &Ngroup;                                                                                                              
%let label&i=%qscan(%superq(grouplabel),&i,%str(#));                                                                                      
%end;

ods listing close;
ods rtf file="&file" style=Styles.crftables;

%footnotes(program=%pgmname, fileName=&file,datasetname=&printds,author=&author)

proc report data=&printds nowindows split='*' PS=120 headline headskip wrap 
   style(column) = [asis=on] missing style(report) = {cellpadding=5 width=95%};
		column sequence variabledesc statistics %if %varexist(&printds,statc)=1 %then %do;statc%end;%unquote(%do i=1 %to &Ngroup; &group._&&value&i%end;)  pvalue;;
	define sequence   / group order=internal noprint;
	define variabledesc  / group "Parameter" order=data style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
	%if %varexist(&printds,statc)=1 %then %do;
	define statc/group order=internal noprint;
	%end;
    define statistics  / order=data center "Statistic" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%] ;
%do i = 1 %to &Ngroup;   
	define %unquote(&group._&&value&i)  / order=data center "&&label&i" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
%end; 
	define pvalue  / order=data center "P-value" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
	compute after _page_;
	line 'end of table';
	endcomp;
run;

ods rtf close;
ods listing;

%mend;
