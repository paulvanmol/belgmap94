/*Final Script voor Arrondisment*/
/*Parameters*/


%let REGION_LABEL=Belgium Arrondisement;
%let REGION_PREFIX=XA;
%let REGION_ISO=923;
%let PROVINCE_LABEL=Custom Arrondisement;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_ARR1;
%let shapeversion=AdminVector_2019_WGS84_shp;
%let shapeversion=AdminVector_2015_WGS84_shp;
/*Load Custom Regions*/

/* create libraries */
libname valib "&configdir/SASApp/Data/valib";
libname MAPSCSTM "&path/sasdata";
proc sql; 
delete * from valib.attrlookup
where ID ? "&REGION_PREFIX"; 
delete * from valib.centlookup
where ID ? "&REGION_PREFIX"; 
quit;

/* import SHAPE file to SAS dataset */
PROC MAPIMPORT 	DATAFILE="&path/shape/&shapeversion/AD_3_District.shp"
				OUT=MAPSCSTM.ArrondisementMap;
				ID NISCODE;
RUN;


/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.ArrondisementMap OUT=MAPSCSTM.ArrondisementMap;
	ID NISCODE;
RUN;


/* add Custom Regions to ATTRLOOKUP */ 
proc sql;
 insert into valib.attrlookup
 values ( 
  "&REGION_LABEL.",            /* IDLABEL=State/Province Label */
  "&REGION_PREFIX.", 		/* ID=SAS Map ID Value */
  "&REGION_LABEL.",            /* IDNAME=State/Province Name */
  "",                   	/* ID1NAME=Country Name */
  "",                          /* ID2NAME */
  "&REGION_ISO.",              /* ISO=Country ISO Numeric Code */
  "&REGION_LABEL.",          	/* ISONAME */
  "&REGION_LABEL.",     	/* KEY */
  "",                          /* ID1=Country ISO 2-Letter Code */
  "",                          /* ID2 */
  "",                          /* ID3 */
  "",                          /* ID3NAME */
  0                            /* LEVEL (0=country level) */
 );
;quit;


/* create Custom Regions dataset */
data &PROVINCE_DATASET.;
 SET MAPSCSTM.ArrondisementMap;
 ID = compress("&REGION_PREFIX.-" || put(NISCODE,8.));
 IF substr(left(niscode),1,1) in ('7','4','3','1') THEN DO;
  	IF name_dut ne ' ' THEN IDNAME=name_dut; 
  END; 
  ELSE IF substr(left(niscode),1,1) in ('9','8','6','5') THEN DO; 
  	IF name_fre ne ' ' THEN IDNAME=name_fre;
  	ELSE IF name_ger ne ' ' THEN IDNAME=name_ger;
  END;
  ELSE IF substr(left(niscode),1,1) = '2' THEN DO;
    code = substr(left(niscode),1,2);
  	IF code in ('24', '23') THEN IDNAME = name_dut;
	ELSE IF code = '25' THEN IDNAME = name_fre;
	ELSE IF code = '21' THEN IDNAME = catx(' / ',name_fre,name_dut);
  END;
  
  IDNAME = TRANWRD(IDNAME,'�','e');
  IDNAME = TRANWRD(IDNAME,'�','e');
  IDNAME = TRANWRD(IDNAME,'�','e');
  IDNAME = TRANWRD(IDNAME,'�','e');
  IDNAME = TRANWRD(IDNAME,'�','a');
  IDNAME = TRANWRD(IDNAME,'�','a');
  IDNAME = TRANWRD(IDNAME,'�','a');
  IDNAME = TRANWRD(IDNAME,'�','a');
  IDNAME = TRANWRD(IDNAME,'�','i');
  IDNAME = TRANWRD(IDNAME,'�','o');
  IDNAME = TRANWRD(IDNAME,'�','o');
  IDNAME = TRANWRD(IDNAME,'�','u');
  IDNAME = TRANWRD(IDNAME,'�','u');
  IDNAME = TRANWRD(IDNAME,'�','u');
  IDNAME = TRANWRD(IDNAME,'�','u');
  IDNAME = TRANWRD(IDNAME,'?','oe');
  IDNAME = PROPCASE(IDNAME);
  
  IF (left(niscode)) = '62093' THEN IDNAME = 'SAINT-NICOLAS';
 IDNAME = "Arr. "||IDNAME;
 LONG = X;
 LAT = Y;
 ISO = "&REGION_ISO.";
 RESOLUTION = 1;
 LAKE = 0;
 ISOALPHA2 = "&REGION_PREFIX.";
 AdminType = "regions";
 WHERE DENSITY <= 1;
 keep ID SEGMENT IDNAME LONG LAT X Y ISO DENSITY RESOLUTION LAKE ISOALPHA2 AdminType;
run;

/* add custom subregions to ATTRLOOKUP */
proc sql;
 insert into valib.attrlookup
 select distinct 
  IDNAME,                              /* IDLABEL=State/Province Label */
  ID, 				        			/* ID=SAS Map ID Value */
  IDNAME,                              /* IDNAME=State/Province Name */
  "&REGION_LABEL.",                    /* ID1NAME=Country Name */
  "",                                  /* ID2NAME */
  "&REGION_ISO.",                      /* ISO=Country ISO Numeric Code */
  "&REGION_LABEL.",            			/* ISONAME */
  trim(IDNAME) || "|&REGION_LABEL.",   /* KEY */
  "&REGION_PREFIX.",                   /* ID1=Country ISO 2-Letter Code */
  "",                                  /* ID2 */
  "",                                  /* ID3 */
  "",                                  /* ID3NAME */
  1                                    /* LEVEL (1=state level) */
 from &PROVINCE_DATASET.
;quit;run;


/* add data to CENTLOOKUP */
proc sql;
  /* add custom region to CENTLOOKUP */
  insert into valib.centlookup
  select distinct
     "&PROVINCE_DATASET." as mapname,
     "&REGION_PREFIX." as ID,
     avg(x) as x,
     avg(y) as y
  from &PROVINCE_DATASET.;
  /* add custom provinces to CENTLOOKUP */
  insert into valib.centlookup
  select distinct
     "&PROVINCE_DATASET." as mapname,
     ID as ID,
     avg(x) as x,
     avg(y) as y
  from &PROVINCE_DATASET.
  group by id;
;quit;run;








GOPTIONS ACCESSIBLE;
proc sql;
   create table &PROVINCE_DATASET._TEST as
   select distinct 
       ID as ID,
       IDNAME as NAME
   from &PROVINCE_DATASET.;
   create table &PROVINCE_DATASET._TEST as
   select *,
       round(ranuni(1) * 10000) as population,
       round(ranuni(1) * 100000) as avg_income format=dollar20.0
   from &PROVINCE_DATASET._TEST
   group by ID, NAME
   order by ID, NAME
;quit;run;


