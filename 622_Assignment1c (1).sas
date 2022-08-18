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

*CLEANING INTERVIWER DATA";

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
if study_id=4019 then delete;
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
	-7="-7=Skipped" 
	-8="-8=Refused to Answer" 
	-9="-9=Does not Know";
	
	
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
	-7="-7=Skipped";
	
	value job
	1="1=Truck Driver"
	2="2=Other Profession"
	3="3=Unemployed"
	-7="-7=Skipped" 
	-8="-8=Refused to Answer" 
	-9="-9=Does not Know";
	
	value country
	1="1=Kenya"
	2="2=Other, SPECIFY"
	-7="-7=Skipped" 
	-8="-8=Refused to Answer" 
	-9="-9=Does not Know"
	;
	
	value results
	1="1=HIV Positive"
	2="2=HIV Negative"
	-7="-7=Skipped";
	
	
	

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
run;
	

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

/*----------------------SYNTAX for 1c STARTS HERE-------------------------*/
/************************** DATA EXAMINIATION **************************/
/*Running frequency tables for each variable  */ 

proc freq data =SD12BI_2; 
	table screeningID--sf_interviewer_race/missing; 
run;


*ISSUES IDENTIFIED *

Issue 1: Based on the frequency table we notice that that 4019 occurs twice in the merged dataset. 
When tracing back, we notice that screening data 2(SD2) has two 4019s 
however thier interview dates, screening ID differ, so do thier ages.
This indicates they maybe differnt participants.
However, there is only one baseline row for 4019 whose clinic and laguage matches both the 4019 rows in SD2 
The age doesn't match any of the copies however same is true for rest of the data.
THUS, there is no way to discern which individual in the corrosponding basline data belongs to;
*SOLUTION: 
I went back and removed 4019 from the baseline data. That way erroneous merging will be avoided.
I changed one of the 4019 to 4018 in final data to give each particiapnt unique IDs.

*Issue 2: Screening ID S110 is repeated twice for unique individuals. 
SOLUTION: As screening ID doesn't play a big role in identification,I will just remove screening ID S110 and replace with missing;


*Issue 3: We see a common occurence of 7 individuals missing data. (Baseline ID 1301,1302,4005,4137,4162,4192,4197). 
Upon inspection we see that these individuals have all thier screening data missing.
We identified 7 whose ALL screening data were missing including sf_d12. 
We will remove these individuals after testing elgigibity criteria for the rest.;

*Issue 4: Baseline clinic and Screening clinic does not match for Baseline ID: 1209.
However, as I don't know the correct clinic, I will leave as is.

*Issue 5: None of the ages in sceeening data match the ages in baseline data. 
I am not sure how to resolve this issue.



-------*Checking eleigibity using crosstabs--------------

SF_D12 is a important identifier of eligibility. 
Sf_D12 is only asked if a participant is deemed eligible correctly by interviewer.
If this question is correctly skipped, then the participant did not meet eligibity requirements.

HERE I WILL CHECK IF SF_D12 missing values are CORRECTLY SKIPPED(missing)
showing participant didn't meet eligibilty requirements
We will also identify any logical errors in AGE variables and HIV variables:

sf_b1 - Willing to be screened? sf_d12 skipped(missing) correctly if corrosponding sf_b1 is No or missing;
proc freq data = SD12BI_2 ; 
	table sf_c2*sf_d12/missing ; 
run;
*crosstab shows 7 missing and rest yes in sf_b1. 
7 missing also have sd_d12 missing.
So sf_d12 is CORRECTLY SKIPPED.


*sf_c2 - Sex of paticipants ? sf_d12 skipped (missing) correctly if corrosponding sf_c2 is Female or missing;
proc freq data = SD12BI_2 ; 
	table sf_c2*sf_d12/missing ; 
run; 
*crosstab shows the 7 missing also have sd_d12 is missing. 
So sf_d12 is CORRECTLY SKIPPED.


/*****LOGIC TEST FOR AGE : *sf_C4 and sf_c4a**/;
*Checking first if sf_C4a logic is correct. IS sf_c4 is 18+ then sf_c4a is yes and no is <18;

proc freq data = SD12BI_2 ; 
	table sf_c4a*sf_c4/missing ; 
run; 
*data is correct as the only one particiapnt is less than 15 yrs in sf_c4 and is marked as No in sf_C4a;

*sf_c4a - Age 18+ ? sf_d12 skipped correctly if corrsponding sf_c4a is No or missing;
proc freq data = SD12BI_2 ; 
	table sf_c4a*sf_d12/missing ; 
run; 
*crosstab shows 7 who had missing Age 18+ and 1 who was <18 have sd_12 missing.
So sf_d12 is CORRECTLY SKIPPED.


*sf_c5 - truck Driver=1? sf_d12 skipped correctly if corrsponding sf_c5 is other or missing;;
proc freq data = SD12BI_2 ; 
	table sf_c5*sf_d12/missing ; 
run; 
*crosstab shows ones who had missing profession or not a truck driver also have sf_D12 is missing.
So sf_d12 is CORRECTLY SKIPPED;

*sf_c6 - From Kenya (1)? if sf_c6 is Not Keneya or missing sf_d12 should be missing;
proc freq data = SD12BI_2 ; 
	table sf_c6*sf_d12/missing ; 
run; 
*crosstab shows ones who had missing country or were not from kenya also has sf_d12 is missing
So sf_d12 is correctly skipped;


*sf_c7 language comfort? if sf_C7 is No or missing, sf_d12 skipped correctly;
proc freq data = SD12BI_2 ; 
	table sf_c7*sf_d12/missing ; 
run;
*7 didnt answer and nine said no. All corrospdonging sf_d12 are missing. 
So sf_d12 are skipped correctly


*sf_c10 Mpesa? if No or missing, corrosponding sf_d12 should be missing;
proc freq data = SD12BI_2 ; 
	table sf_c10*sf_d12/missing ; 
run;
*from Crosstab: 7 did not answer and all said yes. 
The 7 who didnt answer aslo has missing sf_d12.
So sf_d12 is CORRECTLY SKIPPED;


*sf_c11 sign name? if sf_C11 No or missing, corrosponding sf_d12 should be missing;
proc freq data = SD12BI_2 ; 
	table sf_c11*sf_d12/missing ; 
run;
*from Crosstab: 
7 did not answer Question c11 and and all said yes. 
The 7 who didnt answer also has sf_d12 missing.
So sf_d12 is CORRECTLY SKIPPED;



/*****LOGIC TEST for HIV variables:*******/;
proc freq data = SD12BI_2 ; 
	table sf_c8*sf_c9/missing ; 
run; 
*3 that were not tested, all 3 skipped sf_C9 correctly and will be marked as skipped in sf_C9.
*4 tested positive and 14 tested negative. 

*sf_c9 HIV Positive or Neg? if posotive or missing ,sf_d12 skipped correctly;
proc freq data = SD12BI_2 ; 
	table sf_c9*sf_d12/missing ; 
run;
*10 participants' responses were missing from sf_c9 however two of these peoaple had said yes to screening.
These two had said No to testing in sf_c8, making them eligible and thus sf_D12 is corectly marked YES.
We will mark sf_C9 as skipped for those who werent tested for HIV.
Of the 4 who were HIV positve, the screening question was corrctly skipped/missing;


*/--------**************CORRECTIONs**************-----/;

*After checking each variable involved in eligibity criteria we are
marking sf_d12 as SKIPPED(-7) for those who did not meet eligibilty criteria.;

data SD12BI_3; 	
set SD12BI_2 ;
if sf_c6=2 then sf_d12=-7;
if sf_c4a=0 then sf_d12=-7;
if sf_c5=2 then sf_d12 =-7;
if sf_c6=2 then sf_d12 =-7;
if sf_c7=0 then sf_d12 =-7;
if sf_c10=0 then sf_d12 =-7;
if sf_c11=0 then sf_d12 =-7;
*HIV varaibles;
if sf_c9=1 then sf_d12 =-7; *Adding SKIPPED(-7) to sf_d12 to those who were HIV positive;
if sf_c8=0 then sf_c9 =-7; *also, adding SKIPPED(-7) to sf_C9(HIV+/-)for those who were not tested;

/*REVISITING OTHER ISSUES IDENTIFED FROM FREQUENCY TABLES*/

*Issue 3;
*while the above eligibity logic explains and corrobortes why sf_d12 was skipped for certain individuals,
it doesn't do so for the 7 individuals who had no screening data atall (Baseline ID 1301,1302,4005,4137,4162,4192,4197). 
Thus we are removing these individuals from our dataset;
if sf_d12=. then DELETE;

*ISSUE 2: REMOVING PROBLEMATIC DUPLICATE S110 SCREENING ID;
IF SCREENINGID = "S110" THEN SCREENINGID = .;

*ISSUE 1: CHANGING one of 4019 to a differnt ID;
if sf_C4=42 and ID = 4019 then ID=4018;


*DROPPING UNUSED/unneccsery COLUMNS ASSUMING THIS IS A CLOSED DATA SET AND NO NEW ENTRIES WILL BE MADE;
drop SF_C3_4 SF_C5_2 SF_C6_2 RECORD_ID;
RUN;

*Note: I kept variable "completed screening form" as is as these are automatically assigned by redcap

*reformating sf_d12 to indicate non eligibility for ease of use *;

proc format ;
value elig
	1="1=Yes/Will participate"
	0="0=No/Refused to participate"
	-7="-7= Skipped/Not eligible" ;
	
data SD12BI_3; 
	set SD12BI_3 ;
	format sf_d12 elig.;
	
*Exporting assignmet 1c;
data epi.Assignment_1c_BA_dataset ; 
	set SD12BI_3; 
RUN;

*Exporting assignmet 1c;
PROC EXPORT Data=SD12BI_3
	Outfile="/home/u50125037/622/SD12BI_3.xls"
	dbms = xls replace;
	sheet="assignment 1c";
run;
















