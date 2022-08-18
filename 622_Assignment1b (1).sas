libname epi '/home/u50125037/622/'; 

/************************** IMPORTING DATASETS **************************/ 

*Import InterviewerData;
FILENAME REFFILE '/home/u50125037/622/InterviewerData.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=int;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=int;
RUN;

FILENAME REFFILE '/home/u50125037/622/BaselineData.sav';
* Import Baseline data;
PROC IMPORT DATAFILE=REFFILE DBMS=SAV OUT=base;
RUN;
PROC CONTENTS DATA=base;
RUN;

*import ScreeningData1;
FILENAME REFFILE '/home/u50125037/622/ScreeningData1.xls';

PROC IMPORT DATAFILE=REFFILE DBMS=XLS OUT=sd1;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=sd1;
RUN;

*Import ScreeningData2;
FILENAME REFFILE '/home/u50125037/622/ScreeningData2.sav';

PROC IMPORT DATAFILE=REFFILE DBMS=SAV OUT=sd2;
RUN;

PROC CONTENTS DATA=sd2;
RUN;

/************************** Data Cleaning **************************/ 

*CLEAING INTERVIWER DATA";

*New numeric variable for interviwer's gender;
data int_2 ;
set int;
if Gender = "Male" then sf_interviewer_gender = 1;
else if Gender = "Female" then sf_interviewer_gender = 2;
 
*New numeric variable for interviewer's race;
if race = "African" then sf_interviewer_race=2;
else if race = "White" then sf_interviewer_race = 3;

*Renaming interviwer age varaible to keep it consistent with other variables from interviwer DATA;
rename Age = sf_interviewer_age; *interviewer;

*Merging variable: renaming INTERVIWER NAME to match with SD1,SD2,Baseline interviewer name variable;
rename Interviewer = sf_a2;

*Dropping old gender and race variable to avoid duplicates;
drop Gender race;
RUN;

*CLEANING "BASELINE DATA";
data base_2 ;
set base;
*Renaming study ID to create matching merging variable of SD1, SD2 and Baseline;
rename study_id = ID;
RUN;

*CLEANING "SCREENING_DATA_1";

data sd1_2 ;
set sd1;
*RENAMING sf_e13 (study id) to create matching merging variable;
rename sf_e13 = ID;

RUN;

*CLEANING "SCREENING_DATA_2";

*Renaming variables of screening data 2 to match that of screening data 1;
data sd2_2;
set sd2;
rename Study_ID = ID; *RENAMING TO CREATE MERGING VARIABLE;
rename sq_date = sf_a1; *date;
rename sq_interviewer = sf_a2; *interviewer;
rename sq_clinic = sf_a3; *clinic;
rename sq_enterer = sf_a4; *enterer;
rename sq_language = sf_a6; *language;
rename sq_b1 = sf_b1; *willing to be screened;
rename sq_c2 = sf_c2;*sex;
rename sq_c3 = sf_c3;*race;
rename sq_c4 = sf_c4;*Age;
rename sq_c4a = sf_c4a;*over 18?;
rename sq_c5 = sf_c5;*job;
rename sq_c6 = sf_c6;*country;
rename sq_c7 = sf_c7;*English or kswahili;
rename sq_c8 = sf_c8;*tested for HIV?;
rename sq_c9 = sf_c9;*Pos or neg HIV?;
rename sq_c10 = sf_c10;*Mpesa?;
rename sq_c11 = sf_c11;*Sign name?;
rename sq_C12 = sf_d12;*HIV Pos or neg HIV?;
rename screening_questionnaire_complete = screeningtdatacollectionform_com;


*************************MERGING!"*******************;

*Vertical Merge : Screening Data 1 and 2 ;
*setting sd2_2 before sd1_1 to preserve the longer charecter length ($1500) for sf_a2 and sf_a4;
 
data SD12; 
	set sd2_2 sd1_2  ;
 
*Horizontal Merge by ID: Baseline data to Screening data1_2 (SD12);
proc sort data=SD12;
by ID;
proc sort data=base_2;
by ID;
DATA SD12B;
  MERGE SD12 base_2;
  BY ID; 
RUN;

*Merging Interviewer data to previoussly merged baseline data and screening data(SD12B);
*Horizontal merge by interviwer name (sf_a2);

proc sort data=int_2;
by sf_a2;
proc sort data=SD12B;
by sf_a2;
DATA SD12BI;
   MERGE SD12B int_2;
  BY sf_a2; 
RUN;



*************************FORMATING AND LABELING***********************;
proc format ;
	value yn
	1="1=Yes"
	0="0=No";
	
	value ynnmore
	1="1=Yes"
	0="0=No"
	-7="SP=Skipped" 
	-8="RA=Refused to Answer" 
	-9="DK=Does not Know";
	
	value gen
	1 = "1=Male"
	2 = "2=Female"; 	
	
	value intrace
	2 = "2=African"
    3 = "3=White" ;

	value lang
	1= "1=English mostly"
	2= "2=Kiswahili mostly"
	3= "3=Both equally";

	value race
	1="1=African"
	2="2=Indian"
	3="3=White/European"
	4="4=Other,SPECIFY" 
	-7="SP=Skipped";
	
	value job
	1="1=Truck Driver"
	2="2=Other Profession"
	3="3=Unemployed"
	-7="SP=Skipped" 
	-8="RA=Refused to Answer" 
	-9="DK=Does not Know";
	
	value country
	1="1=Kenya"
	2="2=Other, SPECIFY"
	-7="SP=Skipped" 
	-8="RA=Refused to Answer" 
	-9="DK=Does not Know"
	;
	
	value results
	1="1=HIV Positive"
	2="2=HIV Negative"
	-7="SP=Skipped";
	
	
	

*applying formats and add labels to the dataset*; 

data SD12BI_2; 
	set SD12BI ;
	format sf_interviewer_gender gen.
	sf_interviewer_race intrace.
	sf_a6 lang.
	sf_b1 yn.
	sf_c2 gen.
	sf_c3 race.
	sf_c4a yn.
	sf_c5 job.
	sf_c6 country.
	sf_c7 ynnmore.
	sf_c8 ynnmore.
	sf_c9 results.
	sf_c10 ynnmore.
	sf_c11 ynnmore.
	sf_d12 ynnmore.;
	

label ID = "Participant ID or Baseline ID"
	ScreeningID = "Screening form ID"
	sf_a1 = "Screening form Interview Date" 
	sf_a2 = "Interviewer" 
	sf_a3 = "Clinic" 
	sf_a4 = "Data enterer"
	sf_a5_1 = "Study Baseline ID (repeat)"
	sf_a6 = "Language of interview"
	sf_b1 = "Willing to be screened?"
	sf_c2 = "Sex of participant"
	sf_c3 = "Race(observed)"
	sf_c3_4 = "Race IF OTHER SPECIFY"
	sf_c4 = "Age at last birthday"
	sf_c4a = "Age 18+?"
	sf_c5 = "Job"
	sf_c5_2 = "Job If OTHER SPECIFY"
	sf_c6 = "Country of Residence"
	sf_c6_2 = "Country of residence If OTHER SPECIFY"
	sf_c7 = "Comfortable with English or Kiswahili?"
	sf_c8 = "Ever tested for HIV?"
	sf_c9 = "Past HIV Test Result (if tested)"
	sf_c10 = "Pay through M-pesa?"
	sf_c11 = "Able to sign name?"
	sf_d12 = "Interested in participating?"
	sf_e14 = "Initials"
	sf_interviewer_age = "Age of Screening Data Interviewer"
	sf_interviewer_gender = "Gender of Screening Data Interviewer"
	sf_interviewer_race = "Race of Screening Data Interviewer";

*Leaving in empty variables:sf_c5_2,sf_c6_2,sf_c3_4,sf_a5_1 incase any 
other data needs to be merged later and data on those variables are present;

*filling missing empty spaces with .;
if screeningID = " " then screeningID=.;
	

*Exporting data to permanent file;

data epi.Assignment_1b_BA_dataset ; 
	set SD12BI_2; 
RUN;

*Exporting to excel file;

PROC EXPORT Data=SD12BI_2
	Outfile="/home/u50125037/622/SD12BI_2.xls"
	dbms = xls replace;
	sheet="assignment 1b";
run;

*checking each merged data in each step;
proc contents data=sd2_2;
proc contents data=sd1_2;
proc contents data=SD12;
proc contents data=SD12B;
proc contents data=SD12BI;
proc contents data=SD12BI_2;
RUN;




