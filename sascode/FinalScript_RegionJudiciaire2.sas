
/*Final Script voor Municipality*/
/*Parameters*/

%let REGION_LABEL=Belgium Region Judiciaire;
%let REGION_PREFIX=XT;
%let REGION_ISO=928;
%let PROVINCE_LABEL=Custom Region Judiciaire;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_REJ1;




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
PROC MAPIMPORT 	DATAFILE="&path/shape/AD_2_Municipality.shp"
				OUT=MAPSCSTM.MunicipalityMap;
				ID NISCODE;
RUN;


/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.MunicipalityMap OUT=MAPSCSTM.MunicipalityMap;
	ID NISCODE;
RUN;

data mapscstm.regionarrondjudiciaire;
	set mapscstm.municipalitymap;

	/*5 gerechtelijkge gebieden
	Antwerpen: Antwerpen · Limburg 
	Bergen: Henegouwen 
	Brussel: Brussel (BHV) · Leuven · Waals-Brabant 
	Gent: Oost-Vlaanderen · West-Vlaanderen 
	Luik: Luik - Namen - Eupen - Luxemburg 
	*/
	length regionjudNL regionjudFR $ 55 arrondjudNL arrondjudFR $ 55;

	if substr(niscode,1,1) in ('1','7') then
		do;
			regionjud_id=1;
			regionjudNL='Gerechtelijk Gebied Antwerpen';
			regionjudFR='Zone Judiciaire Anvers';
		end;
	else if substr(niscode,1,1) in ('2') then
		do;
			regionjud_id=2;
			regionjudNL='Gerechtelijk Gebied Brussel';
			regionjudFR='Zone Judiciaire Bruxelles';
		end;
	else if substr(niscode,1,1) in ('3','4') then
		do;
			regionjud_id=4;
			regionjudNL='Gerechtelijk Gebied Gent';
			regionjudFR='Zone Judiciaire Gand';
		end;
	else if substr(niscode,1,1) in ('5') then
		do;
			regionjud_id=5;
			regionjudNL='Gerechtelijk Gebied Bergen';
			regionjudFR='Zone Judiciaire Mons';
		end;
	else if substr(niscode,1,1) in ('6', '8', '9') then
		do;
			regionjud_id=6;
			regionjudNL='Gerechtelijk Gebied Luik';
			regionjudFR='Zone Judiciaire Liège';
		end;

	/*12 Gerechtelijke Arrondissementen*/
	if substr(niscode,1,1)='1' then
		do;
			arrondjud_id=10;
			arrondjudNL="Gerechtelijk Arrondissement Antwerpen";
			arrondjudFR="Arrondissement judiciaire d'Anvers";
		end;

	if substr(niscode,1,1) in ('2') then
		do;
			/*Leuven, Brussel, Waals-Brabant*/
			if substr(niscode,1,2) in ('24') then
				do;
					arrondjud_id=24;
					arrondjudNL="Gerechtelijk Arrondissement Leuven";
					arrondjudFR="Arrondissement judiciaire de Louvain";
				end;
			else if substr(niscode,1,2) in ('21', '23') then
				do;
					arrondjud_id=21;
					arrondjudNL="Gerechtelijk Arrondissement Brussel";
					arrondjudFR="Arrondissement judiciaire de Bruxelles";
				end;
			else if substr(niscode,1,2) in ('25') then
				do;
					arrondjud_id=25;
					arrondjudNL="Gerechtelijk Arrondissement Waals-Brabant";
					arrondjudFR="Arrondissement judiciaire du Brabant wallon";
				end;
		end;
	else if substr(niscode,1,1)='3' then
		do;
			arrondjud_id=30;
			arrondjudNL="Gerechtelijk Arrondissement West-Vlaanderen";
			arrondjudFR="Arrondissement judiciaire de Flandre-Occidentale";
		end;
	else if substr(niscode,1,1)='4' then
		do;
			arrondjud_id=40;
			arrondjudNL="Gerechtelijk Arrondissement Oost-Vlaanderen";
			arrondjudFR="Arrondissement judiciaire de Flandre-Orientale";
		end;
	else if substr(niscode,1,1)='5' then
		do;
			arrondjud_id=50;
			arrondjudNL="Gerechtelijk Arrondissement Henegouwen";
			arrondjudFR="Arrondissement judiciaire du Hainaut";
		end;
	else if substr(niscode,1,1)='6' then
		do;
			/*Luik=Verviers, Luik, Huy*/
			if niscode in ('63023', '63040', '63048', '63061', 
				'63001', '63012', '63067','63013','63087') then
				do;
					arrondjud_id=63;
					arrondjudNL="Gerechtelijk Arrondissement Eupen";
					arrondjudFR="Arrondissement judiciaire d'Eupen";
				end;
			else
				do;
					arrondjud_id=60;
					arrondjudNL='Gerechtelijk Arrondissement Luik';
					arrondjudFR="Arrondissement judiciaire de Liège";
				end;
		end; /*Luik*/
	else if substr(niscode,1,1)='7' then
		do;
			arrondjud_id=70;
			arrondjudNL="Gerechtelijk Arrondissement Limburg";
			arrondjudFR="Arrondissement judiciaire du Limbourg";
		end;
	else if substr(niscode,1,1)='8' then
		do;
			arrondjud_id=80;
			arrondjudNL="Gerechtelijk Arrondissement Luxemburg";
			arrondjudFR="Arrondissement judiciaire du Luxembourg";
		end;
	else if substr(niscode,1,1)='9' then
		do;
			arrondjud_id=90;
			arrondjudNL="Gerechtelijk Arrondissement Namur";
			arrondjudFR="Arrondissement judiciaire de Namur";
		end;
run;

proc sort data=mapscstm.regionarrondjudiciaire out=work.regionjudiciaire;
	by regionjud_id;
run;

proc gremove data=work.regionjudiciaire out=mapscstm.regionjudiciaire;
	by regionjud_id;
	id niscode;
run;

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
 SET MAPSCSTM.regionjudiciaire;
 drop arrondjudNL arrondjudFR arrondjud_id;
 ID = compress("&REGION_PREFIX.-" || put(regionjud_id,8.));
 IF substr(left(regionjud_id),1,1) in ('7','4','3','1') THEN DO;
 IDNAME=regionjudNL; 
  END; 
  ELSE IF substr(left(regionjud_id),1,1) in ('9','8','6','5') THEN DO; 
  	 IDNAME=regionjudFR;
  END;
  ELSE IF substr(left(regionjud_id),1,1) = '2' THEN DO;
  	 IDNAME = catx('/',regionjudFR,regionjudNL);
 END;
  
  IDNAME = TRANWRD(IDNAME,'é','e');
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
  IDNAME = Propcase(IDNAME," '/");

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





/*create test table*/

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

