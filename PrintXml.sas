/*!
/********************************************************************************************************************
Macro name: 

Written by: Yiwen Luo

Creation date: 

SAS version: 9.4

Purpose: 

Parameters(required):	

Parameters(optional):	

Sub-macros called: 

Sample Macro call: 

*************************************************************************************************************/

%macro PrintXml(file=,printds=,group=,groupvalue=,grouplabel=,author=YLuo,font_sz=9,cellwd=13);

data &printds._xml;
	length table $20;
	set &printds;
	len=length(variabledesc)-length(left(variabledesc));
	if len>0 then variabledesc2 = catx('','A0A0A0A0'x, strip(variabledesc));
	else variabledesc2=strip(variabledesc);
	if statc=. then statc=0;
run;

ods _all_ close;
ods tagsets.ExcelXP file="&file"
    style=printer
    options(sheet_interval='bygroup'
            sheet_label=' '
            embedded_titles='yes'
            embedded_footnotes='yes'
            suppress_bylines='yes'
            autofit_height='yes'
            );
			title;
    %footnotes(datasetName=&printds, fileName=&file, author=&author)
    PROC REPORT data = &printds._xml nowd split='~';
	column sequence variabledesc statistics %unquote(%do i=1 %to &Ngroup; &group._&&value&i%end;)  pvalue;;
		define sequence   / group order=internal noprint;
		define variabledesc  / group "Parameter" order=data style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
	    define statistics  / order=data center "Statistic" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%] ;
		%do i = 1 %to &Ngroup;   
		define %unquote(&group._&&value&i)  / order=data center "&&label&i" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
		%end; 
		define pvalue  / order=data center "P-value" style(column) = [font_size=&font_sz.pt CELLWIDTH=&cellwd.%];
		compute after _page_;
		line 'end of table';
		endcomp;
	run;
ods tagsets.ExcelXP close;
ods listing;
%mend;
