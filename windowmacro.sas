%macro windowmacro(word=);


%window reenter  ICOLUMN= 15 IROW= 10
 COLUMNS=40 ROWS=15 color=white
  #5 @5 'Input dataset does not exist.' attr=highlight color=black;	 
%display reenter;

%mend;

%windowmacro
