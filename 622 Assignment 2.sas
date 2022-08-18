
*\Data Import*;
libname epi '/home/u50125037/622/622 Assignment 2';

*\checking all variables present in raw dataset\;
proc contents data=epi.nychanes13;


*WHOLE POPulation - subest required variables ;
data nycsubset;
set epi.nychanes13;
keep EDU DMQ_7YEAR DMQ_A DMQ_5 DMQ_6 GENDER INC25K EDU3CAT HUQ_9 HIQ_1 CAPI_WT BOROSTRATUM PSUNEST RACE AGEGRP3C INQ_4;

*------------------CLEANING DATA----------------*

*Formats for each varaible from NYU;
proc format ;
Value RACE
1 =  '  1: Non-Hispanic White'
2 =  '  2: Non-Hispanic Black'
3 =  '  3: Hispanic'
4 =  '  4: Asian'
5 =  '  5: Other'
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
.  =  '.: Legit skip';
Value GENDER 
1 =  '  1: Male'
2 =  '  2: Female';
Value INTYFMT
.D =   " .D: Don't know"
.R =  ' .R: Refusal'
. =  '.: Legit skip';
Value NUM2FMT
. =  '.: Legit skip';
Value INC25K
1 =  '  1: Less than $25,000'
2 =  '  2: $25,000 - $49,999'
3 =  '  3: $50,000 - $74,999'
4 =  '  4: $75,000 - $99,999'
5 =  '  5: $100,000  or more'
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
.  =  '.: Legit skip';
Value EDU3CAT
1 =  "  1: High school diploma or less"
2 =   " 2: Some college or associate's degree"
3 =  "  3: College graduate or more"
.D  =   " .D: Don't know"
.R  =  " .R: Refusal"
.  =  ".: Legit skip";
Value TE_3F
1 =  '  1: Yes'
2 =  '  2: No'
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
.  =  '.: Legit skip';
Value NUM6FMT 
0 =  '  0: No value'
.D =   " .D: Don't know"
.R =  ' .R: Refusal'
. =  '.: Legit skip';
value bornwhere
1= "1= US Born"
2= "2= Foreign";
Value $COUNTRY
'10'   =  '  10: United States'
'11'   =  '  11: Puerto Rico'
'12'   =  '  12: Dominican Republic'
'13'   =  '  13: Jamaica'
'14'   =  '  14: Mexico'
'15'   =  '  15: China'
'16'   =  '  16: Russia'
'17'   =  '  17: Guyana'
'18'   =  '  18: Ecuador'
'19'   =  '  19: Haiti'
'20'   =  '  20: India'
'21'   =  '  21: Korea'
'22'   =  '  22: Trinidad and Tobago'
'23'   =  '  23: Colombia'
'24'   =  '  24: United Kingdom'
'25'   =  '  25: Philippines'
'26'   =  '  26: Italy'
'27'   =  '  27: Ireland'
'28'   =  '  28: Japan'
'29'   =  '  29: Ukraine'
'30'   =  '  30: Germany'
'66'   =  '  66: Other'
'DN'   =   "DN: Don't know"
'R'   =  'R: Refusal'
''  =  '<Space>: Legit skip';
Value $CHARF
'DN'   =   "DN: Don't know"
'R'   =  'R: Refusal'
''  =  '<Space>: Legit skip';
Value AGEGRP3CAT
1 =  '  1: 20-34'
2 =  '  2: 35-64'
3 =  '  3: 65 and over'
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
.  =  '.: Legit skip';
Value TE_77F
1 =  '  1: $20,000 or more'
2 =  '  2: Less than $20,000'
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
. =  '.: Legit skip';
Value INQCOMB
1 =  ' 1: less than $25,000'
2 =  '  2: more than $25,000'
;
Value EDUFMT 
1 =  '  1: < High School'
2 =  '  2: >=   High School'  
.D  =   " .D: Don't know"
.R  =  ' .R: Refusal'
.  =  '.: Legit skip'
;


*Applying formats data nycsubset; 

format
	DMQ_7YEAR INTYFMT.
	DMQ_A INTYFMT.
	DMQ_5 $COUNTRY.
	DMQ_6 $CHARF.
	GENDER GENDER.
	INC25K INC25K.
	EDU3CAT EDU3CAT.
	HUQ_9 TE_3F.
	HIQ_1 TE_3F.
	RACE RACE.
	CAPI_WT NUM6FMT.
	BOROSTRATUM NUM6FMT.
	PSUNEST NUM6FMT.
	AGEGRP3C AGEGRP3CAT.
	EDU EDUFMT.;
run;

*---------------------Cleaning--------------*
*creating variables for Lentgh of stay and age of move;
data nycsubset;
set nycsubset;
US_time = 2014-DMQ_7YEAR;
Age_reloc = 2014-DMQ_A;
label US_time = Length of stay in US;
label Age_reloc = Age of relocation to US;
run;

*checking US born vs Non-US-Born;
proc freq data=epi.nychanes13;
table DMQ_5;
run; 
*\DMQ_5-4 dont knows and 4 refused, nothing missing";

*checking if any of the DMQ7YEAR overlaps with DMQ_5 =10 or DN or R*;
proc freq data=epi.nychanes13;
table DMQ_5*DMQ_7YEAR;
run;
*

*8 people were deleted as it's a small number and none corrosponded to DMQ_7YEAR*;
*This variable will allow for use of DOMAIN function for our subset;
data nycsubset;
set nycsubset;
if DMQ_5 = 'DN' then DELETE;
if DMQ_5 = 'R' then DELETE;
if DMQ_5 = 10 then BORN = 1; *US Born;
if DMQ_5 ne 10 then BORN =2; *Foreign Born;
label BORN = Where was R Born;
format BORN bornwhere.;
run;

proc freq data=nycsubset;
TABLE BORN;
TABLE BORN*HUQ_9;
run;

*Collapsing income to 2 catagories, >25k = 2 and <25k =1
data nycsubset;
data nycsubset;
set nycsubset;
if INC25k in(1 ) then INC = 1;
else if INC25k in (2 3 4 5) then INC = 2;
format INC INQCOMB.;
label INC = Income;
run;

*Checking final subset data*;
proc contents data = nycsubset;


*----------------------- Descriptive Stats for Table 1----------*;
*foreign born *outcome;

PROC SURVEYFREQ  data=nycsubset;
TABLE BORN;
TABLES  BORN*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT;
run;


*race x outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*race*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;

*  income x outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*INC*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;

*SEX x Outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*gender*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;

*Eduation x Outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*EDU*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;


*Health Care Access x Outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*HIQ_1*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;

**Age(age of R) x outcome*;
PROC SURVEYFREQ  data=nycsubset;
TABLES  BORN*AGEGRP3C*HUQ_9/row chisq; 
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
RUN;


*US_time(length of stay) x outcome*;
PROC surveymeans data=nycsubset mean STDERR median min max;
var US_TIME;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign')*HUQ_9/diff;
RUN;

*Age_reloc(age of relocation) x outcome*;
PROC surveymeans data=nycsubset mean STDERR median min max;
var Age_reloc;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign')*HUQ_9/diff;
RUN;



**-----------------univariate logistic --------------*;
*length og stay;
PROC SURVEYLOGISTIC  data=nycsubset;
Model HUQ_9 = US_time ;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*Age of relocation;
PROC SURVEYLOGISTIC  data=nycsubset;
Model HUQ_9 = age_Reloc ;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*gender;
PROC SURVEYLOGISTIC  data=nycsubset;
class GENDER (ref="1: Male") /param=ref;
Model HUQ_9 = gender ;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;



*income;
PROC SURVEYLOGISTIC  data=nycsubset;
class INC (ref = " 1: less than $25,000") /param=ref;
Model HUQ_9 = INC;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;




*Education;
PROC SURVEYLOGISTIC  data=nycsubset;
class EDU (ref= " 1: < High School") /param=ref;
Model HUQ_9 = EDU;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*Health access;
PROC SURVEYLOGISTIC  data=nycsubset;
class HIQ_1 (ref="2: No") /param=ref;
Model HUQ_9 = HIQ_1;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*Race;
PROC SURVEYLOGISTIC  data=nycsubset;
class race(ref="1: Non-Hispanic White") /param=ref;
Model HUQ_9 = race;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*Age;
PROC SURVEYLOGISTIC  data=nycsubset;
class AGEGRP3C(ref="1: 20-34") /param=ref;
Model HUQ_9 = AGEGRP3C;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;


**----------------multivariate logistic -----*;

PROC SURVEYLOGISTIC  data=nycsubset;
class GENDER (ref="1: Male") 
INC (ref = " 1: less than $25,000")
 EDU (ref= " 1: < High School")
 race(ref="1: Non-Hispanic White")
 HIQ_1 (ref="2: No")
 AGEGRP3C(ref="1: 20-34") /param=ref;
Model HUQ_9 = US_time US_time race GENDER INC EDU HIQ_1 AGEGRP3C Age_Reloc US_time*Age_Reloc;
STRATA BOROSTRATUM; 
CLUSTER PSUNEST; 
WEIGHT CAPI_WT; 
DOMAIN BORN('2= Foreign'); 
RUN;

*keeping collapsed education but not collasuingincom