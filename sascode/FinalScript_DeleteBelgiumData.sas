libname valib "&configdir/SASApp/Data/valib";
libname MAPSCSTM "&path/sasdata";

/*Uncomment to copy backup datasets first*/
%if %sysfunc(exist(valib.attrlookup_backup)) NE 1 %THEN 
%DO; 
data valib.attrlookup_backup;
	set valib.attrlookup;
run;

data valib.centlookup_backup;
	set valib.centlookup;
run;
%END; 

data valib.attrlookup;
	set valib.attrlookup_backup;
run;

data valib.centlookup;
	set valib.centlookup_backup;
run;
data valib.attrlookup;
	set valib.attrlookup;
	where id NOT LIKE "BE%";
run;

data valib.centlookup;
	set valib.centlookup;
	where id NOT LIKE "BE%";
run;
