
/*Final Script voor Municipality Section*/
/*Parameters*/

%let REGION_LABEL=Belgium Municipality Section;
%let REGION_PREFIX=XD;
%let REGION_ISO=925;
%let PROVINCE_LABEL=Custom Municipality Section;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_MUS1;




/*Load Custom Regions*/


GOPTIONS ACCESSIBLE;
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
PROC MAPIMPORT 	DATAFILE="&path/shape/AD_1_MunicipalSection.shp"
				OUT=MAPSCSTM.MunicipalitySection;
				ID NISCODE;
RUN;


/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.MunicipalitySection OUT=MAPSCSTM.MunicipalitySection;
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
 SET MAPSCSTM.MunicipalitySection;
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
  
  IDNAME = TRANWRD(IDNAME,'é','e');
  IDNAME = TRANWRD(IDNAME,'É','E');
  IDNAME = TRANWRD(IDNAME,'È','E');
  IDNAME = TRANWRD(IDNAME,'ç','c');
  IDNAME = TRANWRD(IDNAME,'è','e');
  IDNAME = TRANWRD(IDNAME,'ë','e');
  IDNAME = TRANWRD(IDNAME,'ê','e');
  IDNAME = TRANWRD(IDNAME,'ä','a');
  IDNAME = TRANWRD(IDNAME,'â','a');
  IDNAME = TRANWRD(IDNAME,'à','a');
  IDNAME = TRANWRD(IDNAME,'á','a');
  IDNAME = TRANWRD(IDNAME,'ï','i');
  IDNAME = TRANWRD(IDNAME,'ô','o');
  IDNAME = TRANWRD(IDNAME,'ö','o');
  IDNAME = TRANWRD(IDNAME,'ü','u');
  IDNAME = TRANWRD(IDNAME,'û','u');
  IDNAME = TRANWRD(IDNAME,'ú','u');
  IDNAME = TRANWRD(IDNAME,'ù','u');
  IDNAME = TRANWRD(IDNAME,'?','oe');
 IDNAME = CATX(" ",IDNAME,'(Nis.',NISCODE) || ')';
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






GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

%LET _CLIENTTASKLABEL='Create Test Table';
%LET _CLIENTPROJECTPATH='C:\Users\sbxdad\Documents\Visual Analytics Documents\Custom Regions\Own Research\Final Scripts\Final Script voor Municipality Section.egp';
%LET _CLIENTPROJECTNAME='Final Script voor Municipality Section.egp';
%LET _SASPROGRAMFILE=;

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


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

