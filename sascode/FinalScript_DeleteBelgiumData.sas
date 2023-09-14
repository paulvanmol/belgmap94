libname valib "c:/sas/config/Lev1/SASApp/Data/valib";
libname MAPSCSTM "d:/workshop/belgmap/sasdata";

/*
data valib.attrlookup_backup;
	set valib.attrlookup;
run;

data valib.centlookup_backup;
	set valib.centlookup;
run;
*/
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
