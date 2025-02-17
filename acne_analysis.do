*__________________________________________________________________________________________________________________

**Data cleaning (see 'Acne_script.ipynb' for initial cleaning in Python)
*Loading in data
clear all
use "Z:\acne_psychosocial_v3.dta"

*Recoding sex binary feature (0=female,1=male)
recode Sex (2=0)
tabulate Sex

*Labelling variables 
label variable ResultsPHQ9 "PHQ-9 score shortly after starting clinic"
label variable ONSET "age of acne onset"
label variable Sex "0=Male, 1=Female"
label variable Socioeconomic_status "Low (0) and middle-to-upper (1) socioeconomic income, based on monthly income"
label variable Type_adultAcne "1=late-onset, 2=persistent, 3=recurrent"
label variable WellBeingScale "acne-specific wellbeing scale from patient questionnaire, 0=no effect, 10=ruins life"

*Renaming variables with long names
rename New_where_does_the_pt_live pt_location
rename New_if_pt_lives_in_urban_environ pt_urban_loc

*Replacing np.nan with zero values in site variables 
replace FaceAffected = 0 if missing(FaceAffected)
replace BackAffected = 0 if missing(BackAffected)
replace ChestAffected = 0 if missing(ChestAffected)
replace NeckAffected = 0 if missing(NeckAffected)
replace UpperArmsAffected = 0 if missing(UpperArmsAffected)
replace MildSeverity = 0 if missing(MildSeverity)
replace ModerateSeverity = 0 if missing(ModerateSeverity)
replace FamilyDepression = 0 if missing(FamilyDepression)

*Inspecting missingness per variable 
misstable summarize 
ssc install mdesc, replace
mdesc
sum
tab ONSET
tab Age

*Inspecting missingness per row 
egen miss_count = rowmiss(*)
tab miss_count
/*

 miss_count |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |          4        0.18        0.18
          1 |         20        0.89        1.07
          2 |         53        2.36        3.43
          3 |        126        5.61        9.05
          4 |        216        9.63       18.67
          5 |        227       10.12       28.79
          6 |        117        5.21       34.00
          7 |         67        2.99       36.99
          8 |         40        1.78       38.77
          9 |         18        0.80       39.57
         10 |         13        0.58       40.15
         11 |         10        0.45       40.60
         12 |          4        0.18       40.78
         13 |          2        0.09       40.86
         14 |          7        0.31       41.18
         15 |          4        0.18       41.35
         16 |          3        0.13       41.49
         17 |          4        0.18       41.67
         18 |          7        0.31       41.98
         19 |         27        1.20       43.18
         20 |         14        0.62       43.81
         21 |         31        1.38       45.19
         22 |         23        1.02       46.21
         23 |         60        2.67       48.89
         24 |         12        0.53       49.42
         25 |         11        0.49       49.91
         26 |         10        0.45       50.36
         27 |          4        0.18       50.53
         28 |          2        0.09       50.62
         29 |          1        0.04       50.67
         30 |         23        1.02       51.69
         31 |        105        4.68       56.37
         32 |        110        4.90       61.27
         33 |        391       17.42       78.70
         34 |        122        5.44       84.14
         35 |         63        2.81       86.94
         36 |         54        2.41       89.35
         37 |         23        1.02       90.37
         38 |         16        0.71       91.09
         39 |          9        0.40       91.49
         40 |          4        0.18       91.67
         41 |          1        0.04       91.71
         42 |          2        0.09       91.80
         43 |          2        0.09       91.89
         44 |          3        0.13       92.02
         45 |          1        0.04       92.07
         46 |          1        0.04       92.11
         47 |          1        0.04       92.16
         48 |          1        0.04       92.20
         49 |         47        2.09       94.30
         50 |         22        0.98       95.28
         52 |         98        4.37       99.64
         53 |          8        0.36      100.00
------------+-----------------------------------
      Total |      2,244      100.00

*/

*Dropping rows with >48 missing values 
drop if miss_count>48
*Arranging in order of increasing missingness by ID 
gsort +ID +miss_count
*Dropping duplicates (keeping those with most information)
duplicates drop ID, force

*Inspecting variables for out-of-place values (e.g. 0.0001 cigarettes smoked)
sum
tab ONSET 
tab Duration 
tab NurseBackLeedsGrade 
tab NurseLeedsGradeChestWhole 
tab CombinedAcneScore
tab ScarringSeverityFace
tab pt_location 
tab pt_urban_loc
tab WellBeingScale
tab New_Level_of_stress
tab Results_Had
tab BMI
tab PHQ9_1
tab PHQ9_2
tab PHQ9_3
tab PHQ9_4
tab PHQ9_5
tab PHQ9_6
tab PHQ9_7
tab PHQ9_8
tab PHQ9_9
tab HAD_I_Feel_Tense
tab HAD_I_Still_Enjoy
tab HAD_I_Frightened_Feeling
tab HAD_I_Can_Laugh
tab HAD_Worrying_Thoughts
tab HAD_I_Feel_Cheerful
tab HAD_I_Can_Sit_Relaxed
tab HAD_I_Feel_Slowed_Down
tab HAD_I_Get_Frightened
tab HAD_I_Have_Lost
tab HAD_I_Feel_restless
tab HAD_I_look_forward
tab HAD_I_Get_sudden_panic
tab HAD_I_Enjoy_a_good_book

*Fixing out-of-place values 
replace cigarettes = . if cigarettes == 0.00001
replace WellBeingScale = . if WellBeingScale == 6.5
replace New_Level_of_stress = . if New_Level_of_stress > 10

/* N.B. PHQ-9 not used as the primary outcome measure for research due to the lack of variance shown in the current dataset. With the range being 0-19, it does not represent typical distribution patterns seen in the general population, and should range from 0-27 
(Tomitaka, S., Kawasaki, Y., Ide, K. et al. Distributional patterns of item responses and total scores on the PHQ-9 in the general population: data from the National Health and Nutrition Examination Survey. BMC Psychiatry 18, 108 (2018). https://doi.org/10.1186/s12888-018-1696-9)
*Recoding individual PHQ-9 questions to fit the scoring metrics
recode PHQ9_1 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_2 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_3 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_4 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_5 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_6 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_7 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_8 (0=.) (1=0) (2=1) (3=2) (4=3)
recode PHQ9_9 (0=.) (1=0) (2=1) (3=2) (4=3)

*Summing individual PHQ-9 scores to calculate overall score
egen phq9_total = rowtotal(PHQ9_1 PHQ9_2 PHQ9_3 PHQ9_4 PHQ9_5 PHQ9_6 PHQ9_7 PHQ9_8 PHQ9_9)
*Inspecting summed PHQ-9 scoring 
tab phq9_total

*Finding how many questions are missing for each row 
egen phq9_missing = rowmiss(PHQ9_1 PHQ9_2 PHQ9_3 PHQ9_4 PHQ9_5 PHQ9_6 PHQ9_7 PHQ9_8 PHQ9_9)
tab phq9_missing
*Setting rows with all PHQ-9 questions missing as nan 
replace phq9_total = . if phq9_missing == 9
*Calculating average score for the questions in the row 
egen phq9_av = rmean(PHQ9_1 PHQ9_2 PHQ9_3 PHQ9_4 PHQ9_5 PHQ9_6 PHQ9_7 PHQ9_8 PHQ9_9)
tab phq9_av
*Replacing missing questions in each row with row average 
replace PHQ9_1 = phq9_av if missing(PHQ9_1)
replace PHQ9_2 = phq9_av if missing(PHQ9_2)
replace PHQ9_3 = phq9_av if missing(PHQ9_3)
replace PHQ9_4 = phq9_av if missing(PHQ9_4)
replace PHQ9_5 = phq9_av if missing(PHQ9_5)
replace PHQ9_6 = phq9_av if missing(PHQ9_6)
replace PHQ9_7 = phq9_av if missing(PHQ9_7)
replace PHQ9_8 = phq9_av if missing(PHQ9_8)
replace PHQ9_9 = phq9_av if missing(PHQ9_9)
*Recomputing row summed PHQ-9 score with imputed values 
egen phq9_score = rowtotal(PHQ9_1 PHQ9_2 PHQ9_3 PHQ9_4 PHQ9_5 PHQ9_6 PHQ9_7 PHQ9_8 PHQ9_9)
*Setting rows with all PHQ-9 questions missing as nan 
replace phq9_score = . if phq9_missing == 9
*Rounding each summed PHQ-9 score 
replace phq9_score = round(phq9_score)
tab phq9_score
hist phq9_score
*Dropping temporary variables 
drop phq9_total
drop phq9_missing
drop phq9_av
drop ResultsPHQ9
label variable phq9_score "PHQ-9 results upon admission"
*/

*Summing individual HADS scores to calculate overall score 
egen hads_dep = rowtotal(HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book)
egen hads_anx = rowtotal(HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic)
*Inspecting summed PHQ-9 scoring
tab hads_dep
tab hads_anx
qnorm hads_dep

*Single imputation to handle missing values in HADS questions 
*Finding how many questions are missing for each row 
egen hadsdep_missing = rowmiss(HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book)
egen hadsanx_missing = rowmiss(HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic)
*Setting rows with all HADS questions missing as nan
replace hads_dep = . if hadsdep_missing == 7
replace hads_anx = . if hadsanx_missing == 7
*Calculating average score for questions in the row
egen dep_av = rmean(HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book)
egen anx_av = rmean(HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic)
*Replacing missing questions in each row with row average 
replace HAD_I_Feel_Tense = anx_av if missing(HAD_I_Feel_Tense)
replace HAD_I_Still_Enjoy = dep_av if missing(HAD_I_Still_Enjoy)
replace HAD_I_Frightened_Feeling = anx_av if missing(HAD_I_Frightened_Feeling)
replace HAD_I_Can_Laugh = dep_av if missing(HAD_I_Can_Laugh)
replace HAD_Worrying_Thoughts = anx_av if missing(HAD_Worrying_Thoughts)
replace HAD_I_Feel_Cheerful = dep_av if missing(HAD_I_Feel_Cheerful)
replace HAD_I_Can_Sit_Relaxed = anx_av if missing(HAD_I_Can_Sit_Relaxed)
replace HAD_I_Feel_Slowed_Down = dep_av if missing(HAD_I_Feel_Slowed_Down)
replace HAD_I_Get_Frightened = anx_av if missing(HAD_I_Get_Frightened)
replace HAD_I_Have_Lost = dep_av if missing(HAD_I_Have_Lost)
replace HAD_I_Feel_restless = anx_av if missing(HAD_I_Feel_restless)
replace HAD_I_look_forward = dep_av if missing(HAD_I_look_forward)
replace HAD_I_Get_sudden_panic = anx_av if missing(HAD_I_Get_sudden_panic)
replace HAD_I_Enjoy_a_good_book = dep_av if missing(HAD_I_Enjoy_a_good_book)
*Recomputing summed HADS score with imputed values 
egen hads_dep_score = rowtotal(HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book)
egen hads_anx_score = rowtotal(HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic)
*Setting rows with all HADS questions missing as nan
replace hads_dep_score = . if hadsdep_missing == 7
replace hads_anx_score = . if hadsanx_missing == 7
*Rounding each summed HADS score 
replace hads_dep_score = round(hads_dep)
replace hads_anx_score = round(hads_anx)
tab hads_dep_score
tab hads_anx_score
hist hads_anx_score
*Dropping temporary variables 
drop hads_dep hads_anx hadsdep_missing hadsanx_missing dep_av anx_av Results_Had /*temporary variable not required for final dataset*/
drop PHQ9_1 PHQ9_2 PHQ9_3 PHQ9_4 PHQ9_5 PHQ9_6 PHQ9_7 PHQ9_8 PHQ9_9 HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic /*individual questions no longer needed, due to summed scores*/
drop miss_count /*temporary variable not required for final dataset*/
drop Weight Height /*no longer required due to BMI variable*/
drop persistent /*not required due to 'Type_adultAcne' variable*/
drop phq9_score /*phq-9 not used as primary outcome due to lack of variance*/
drop WellBeingScale New_Level_of_stress /*Wellbeing scale not used as primary outcome due to close ties with acne*/
*Creating new variable with HADS total score 
gen hads_total = hads_anx_score + hads_dep_score
*Labelling HADS variables 
label variable hads_dep_score "Hospital depression score upon admission"
label variable hads_anx_score "Hospital anxiety score upon admission"
label variable hads_total "HADS total score upon admission"

*Saving changes
save "Z:\acne_psychosocial_v3.dta", replace
clear all
use "Z:\acne_psychosocial_v3.dta" 

*__________________________________________________________________________________________________________________

**Descriptive stats and exploring data 
*Table 1: Descriptive statistics of the research population
*Inspecting present age and age of onset
sum
tab hads_dep_score
hist hads_dep_score
qnorm hads_anx_score
hist hads_dep_score, norm
hist hads_anx_score, norm
tab Type_adultAcne

*Figure 2: Distribution of ages at acne onset and ages upon admission 
*Two-way histogram of present age and age of onset 
twoway (histogram Age, color(red%50) lcolor(none) bin(30)) ///
	(histogram ONSET, color(green%50) lcolor(none) bin(30)), ///
	legend(label(1 "Age upon admission") label(2 "Age of acne onset")) ///
	ytitle("Density") xtitle("Years")

*__________________________________________________________________________________________________________________

**Univariable analysis 
*Figure 3: Comparison of means between adolescents and adults for HADS scores
*Checking if adults and adolescents have equal variances  
sdtest hads_anx_score, by(Yes_adult) /*unequal variances shown*/
sd test hads_dep_score, by(Yes_adult)

*Welch's t test to compare means of adolescents and adults 
ttest hads_anx_score, by(Yes_adult) unequal /*adults higher, statistically significant*/
ttest hads_dep_score, by(Yes_adult) unequal /*adults higher, statistically significant*/
*Visualisation made in Python due to difficulties with Stata

*Effect sizes for t test, by glass delta 
esize twosample hads_anx_score, by(Yes_adult) glass
esize twosample hads_dep_score, by(Yes_adult) glass

*Figure 4: Histogram of anxiety and depression scores
*Creating variables for HADS scores based on age cohort 
gen anx_adult = hads_anx_score if Yes_adult == 1
gen anx_teen = hads_anx_score if Yes_adult == 0
gen dep_adult = hads_dep_score if Yes_adult == 1 
gen dep_teen = hads_dep_score if Yes_adult == 0
*Plotting histogram for anxiety
twoway (hist anx_adult, start(0) width(1) color(red%50)) ///
	(hist anx_teen, start(0) width(1) color(blue%50)) ///
	(kdensity anx_adult, lcolor(red)) ///
	(kdensity anx_teen, lcolor(blue)), ///
	legend(label(1 "Adults (>25)") label(2 "Adolescents") ////
	label (3 "Adult density") label(4 "Adolescent density")) ///
	xtitle("HADS-Anxiety score") ytitle("Frequency") name("Anx_by_age")
*Plotting histogram for depression
twoway (hist dep_adult, start(0) width(1) color(red%50)) ///
	(hist dep_teen, start(0) width(1) color(blue%50)) ///
	(kdensity dep_adult, lcolor(red)) ///
	(kdensity dep_teen, lcolor(blue)), ///
	legend(label(1 "Adults (>25)") label(2 "Adolescents") ////
	label (3 "Adult density") label(4 "Adolescent density")) ///
	xtitle("HADS-Depression score") ytitle("Frequency") name("Dep_by_age")
*Plotting histogram for total score
gen hads_adult = hads_total if Yes_adult == 1 
gen hads_teen = hads_total if Yes_adult == 0
twoway (hist hads_adult, start(0) width(1) color(red%50)) ///
	(hist hads_teen, start(0) width(1) color(blue%50)) ///
	(kdensity hads_adult, lcolor(red)) ///
	(kdensity hads_teen, lcolor(blue)), ///
	legend(label(1 "Adults (>25)") label(2 "Adolescents") ////
	label (3 "Adult density") label(4 "Adolescent density")) ///
	xtitle("HADS-Total score") ytitle("Frequency") name("HadsTotal_by_age")


*Figure 5: Correlation matrix
*Using heatplot tool by https://github.com/benjann/heatplot
*Installing required packages for heatplot tool 
ssc install heatplot, replace
ssc install colrspace, replace
ssc install palettes, replace
ssc install gtools, replace
*Generating dep heatplot 
spearman hads_dep_score Age ONSET cigarettes BMI  
matrix C = r(Rho)
heatplot C, values(format(%9.3f)) color(hcl diverging, intensity(.8)) ///
	legend(off) aspectratio(1) lower nodiagonal
*Generating anx heatplot 
spearman hads_anx_score Age ONSET cigarettes BMI  
matrix C = r(Rho)
heatplot C, values(format(%9.3f)) color(hcl diverging, intensity(.8)) ///
	legend(off) aspectratio(1) lower

*NB Originally planned to explore acne site, grade, and scarring to see if they were predictors of psychosocial impact scoring, but this overcomplicated the project and could not be included in the report. 
/**Correlation matrix of site of acne with psychosocial impacts
spearman hads_dep_score FaceAffected BackAffected NeckAffected UpperArmsAffected 
*Correlation matrix of acne grade with psychosocial impacts
spearman phq9_score MildSeverity ModerateSeverity NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore
*Correlation matrix of scarring with psychosocial impacts
spearman phq9_score Scars FaceScar ScarringSeverityFace FamilyScar ScarringSeverityFace */
drop FaceAffected BackAffected ChestAffected NeckAffected UpperArmsAffected MildSeverity ModerateSeverity NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore Scars FaceScar ScarringSeverityFace FamilyScar ScarringSeverityFace FamilyDepression
sum

*Linear regression before imputation 
reg hads_dep_score ONSET, beta
reg hads_dep_score Yes_adult, beta
reg hads_anx_score Type_adultAcne if Sex==0, beta
reg hads_anx_score Type_adultAcne, beta

*Calculating effect size 
esize twosample hads_anx_score, by (Yes_adult) glass 
esize twosample hads_dep_score, by (Yes_adult) glass

*Comparing means of psychosocial impact according to type of adult acne (one-way ANOVA)
robvar hads_anx_score, by(Type_adultAcne)
oneway hads_anx_score Type_adultAcne 
oneway hads_dep_score Type_adultAcne /*did not show significant difference between onset groups for any psychosocial impact measures*/

*__________________________________________________________________________________________________________________

**Multiple imputation
*Set imputation to wide format
mi set wide
*Set random seed 
set seed 2024

*Registering variables for imputation
mi register imputed Age Sex smoke cigarettes Alcohol ONSET Duration pt_location pt_urban_loc BMI Yes_adult Socioeconomic_status Type_adultAcne hads_dep_score hads_anx_score 

*Multiple imputation according to type of data (chained) 
mi impute chained (regress) Age cigarettes ONSET Duration hads_dep_score hads_anx_score  BMI (logit, augment) Sex smoke Alcohol Socioeconomic_status, add(10) orderasis nomonotone force noisily augment 
save "Z:\imputed_acne.dta", replace
mi describe 

*Loading imputation dataset (with only main variables)
clear all 
use "Z:\imputed_acne.dta"

*__________________________________________________________________________________________________________________

*Install mibeta to calculate standardised coefficients for multiple imputed data analysed by linear regression (http://www.stata.com/users/ymarchenko)
net install mibeta.pkg, replace

**Univariable regression analysis
*Linear regression model (outcome predictor) (Age as continuous variable)
mi estimate: regress hads_anx_score ONSET
mibeta hads_anx_score ONSET
mi estimate: regress hads_dep_score ONSET
mibeta hads_dep_score ONSET

*Linear regression model (Age as binary >=25)
gen age_adult = (Age > 25)
sum
tab age_adult
mi estimate: regress hads_anx_score age_adult
mibeta hads_anx_score age_adult 
mi estimate: regress hads_dep_score age_adult
mibeta hads_dep_score age_adult 

*Calculating effect size of imputed data by Tiffin, P. A. (2023, Feb). miesize: a Stata .ado package for estimating effect sizes from multiply imputed data. http://repec.org/docs/ssc.php
ssc install miesize, replace
miesize hads_anx_score, by (age_adult) glass
miesize hads_dep_score, by (age_adult) glass

*__________________________________________________________________________________________________________________

*Selecting variables for multivariable analysis
lasso linear hads_anx_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, selection(adaptive) rseed(2024) /*adaptive lasso used for tuning parameters*/
estimates store adaptive /*storing estimates*/
lassocoef /*displaying coefficents after lasso estimation*/
lassogof /*investigating goodness of fit for prediction*/
/*
. lassocoef
------------------------
             | adaptive 
-------------+----------
         Sex |     x    
       _cons |     x    
------------------------
Legend:
  b - base level
  e - empty cell
  o - omitted
  x - estimated

. lassogof
Penalized coefficients
------------------------------------
         MSE    R-squared        Obs
------------------------------------
    25.89948      -0.1248        944
------------------------------------


Only sex is seen as significant predictor for anxiety - not suitable for multivariable linear regression 
*/

lasso linear hads_dep_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, selection(adaptive) rseed(2024)
estimates store adaptive 
lassoknots
lassocoef
lassogof

/*
. lassocoef
--------------------------------
                     | adaptive 
---------------------+----------
           age_adult |     x    
                 Sex |     x    
Socioeconomic_status |     x    
               _cons |     x    
--------------------------------


. lassogof
Penalized coefficients
------------------------------------
         MSE    R-squared        Obs
------------------------------------
    17.62369      -0.2235        813
------------------------------------

Age, sex and socioeconomic status are seen as significant predictors for depression - can be analysed through multivariable linear regression
*/

**Multivariable regression analysis 
mi estimate: reg hads_dep_score age_adult Sex Socioeconomic_status, beta 
mibeta hads_dep_score age_adult Sex Socioeconomic_status, beta

mi estimate: reg hads_anx_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, beta
mibeta hads_anx_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, beta

mi estimate: reg hads_dep_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, beta
mibeta hads_dep_score age_adult Sex smoke cigarettes Alcohol BMI Socioeconomic_status, beta

*__________________________________________________________________________________________________________________