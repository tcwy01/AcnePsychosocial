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

*Inspecting missingness 
egen miss_count = rowmiss(*)

*Inspecting variables for out-of-place values (e.g. 0.0001 cigarettes smoked)
tab cigarettes
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

*Summing individual HADS scores to calculate overall score 
egen hads_dep = rowtotal(HAD_I_Still_Enjoy HAD_I_Can_Laugh HAD_I_Feel_Cheerful HAD_I_Feel_Slowed_Down HAD_I_Have_Lost HAD_I_look_forward HAD_I_Enjoy_a_good_book)
egen hads_anx = rowtotal(HAD_I_Feel_Tense HAD_I_Frightened_Feeling HAD_Worrying_Thoughts HAD_I_Can_Sit_Relaxed HAD_I_Get_Frightened HAD_I_Feel_restless HAD_I_Get_sudden_panic)
*Inspecting summed PHQ-9 scoring
tab hads_dep
tab hads_anx
qnorm hads_dep

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
drop hads_dep
drop hads_anx
drop hadsdep_missing 
drop hadsanx_missing 
drop dep_av
drop anx_av
drop Results_Had
label variable hads_dep_score "Hospital depression score upon admission"
label variable hads_anx_score "Hospital anxiety score upon admission"

*Saving changes
save "Z:\acne_psychosocial_v3.dta", replace
use "Z:\acne_psychosocial_v3.dta" 

**Descriptive stats and exploring data 
*Inspecting present age and age of onset
sum Sex
sum
tab Age
hist ONSET

*Two-way histogram of present age and age of onset 
twoway (histogram Age, color(red%50) lcolor(none) bin(30)) ///
	   (histogram ONSET, color(green%50) lcolor(none) bin(30)), ///
	   legend(label(1 "Age at PHQ9 scoring") label(2 "Age of acne onset")) ///
	   ytitle("Density") xtitle("Years")
	   
*Correlation matrix of PHQ9 results and demographic characteristics
spearman phq9_score Age ONSET Sex smoke cigarettes Alcohol pt_location pt_urban_loc BMI Socioeconomic_status

*Ensuring only unique patient IDs are included
duplicates drop ID, force
*Dropping patient ID variable   
drop ID
sum

**Multiple imputation
*Set imputation to wide format
mi set wide
*Set random seed 
set seed 2024

*Registering variables for imputation
mi register imputed Age Sex smoke cigarettes Alcohol ONSET Duration persistent  NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore Scars FaceScar ScarringSeverityFace FamilyScar pt_location pt_urban_loc WellBeingScale ResultsPHQ9 BMI Socioeconomic_status Type_adultAcne

*Multiple imputation test
mi impute chained (regress) ONSET ResultsPHQ9, add(10) orderasis nomonotone force noisily
save "Z:\imputed_main_var.dta", replace
mi describe

*Multiple imputation according to type of data (chained) 
*mi impute chained (regress) Age cigarettes ONSET Duration NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole WellBeingScale ResultsPHQ9 BMI (logit, augment) Sex smoke Alcohol persistent Scars FaceScar FamilyScar Socioeconomic_status (ologit) ScarringSeverityFace (mlogit) pt_location pt_urban_loc Type_adultAcne, add(10) orderasis nomonotone force noisily augment

codebook Age Sex smoke cigarettes Alcohol ONSET Duration persistent  NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore Scars FaceScar ScarringSeverityFace FamilyScar pt_location pt_urban_loc WellBeingScale ResultsPHQ9 BMI Socioeconomic_status Type_adultAcne

*Multiple imputation using predictive mean matching
*mi impute pmm Age Sex smoke cigarettes Alcohol ONSET Duration persistent  NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore Scars FaceScar ScarringSeverityFace FamilyScar pt_location pt_urban_loc WellBeingScale ResultsPHQ9 BMI Socioeconomic_status Type_adultAcne, add(10) knn(5)

*Saving imputed dataset 
save "Z:\imputed_acne_psychosocial.dta", replace

*Loading test imputation dataset (with only main variables)
use "Z:\imputed_main_var.dta"

*Linear regression model (outcome predictor) (Age as continuous variable)
mi estimate: regress ResultsPHQ9 Age
mi estimate: regress ResultsPHQ9 ONSET 
mi estimate: regress ResultsPHQ9 Age ONSET

*Linear regression model (Age as binary >=25)
*mi register imputed Yes_adult
*mi impute pmm Yes_adult, add(10) knn(3)
gen age_adult = (Age >= 25)
mi set wide 
mi impute pmm Age, add(10) knn(3)
mi impute pmm ResultsPHQ9, add(10) knn(3)
mi impute pmm ONSET, add(10) knn(3)
mi estimate: regress ResultsPHQ9 age_adult

gen onset_adult = (ONSET > 25)
mi estimate: regress ResultsPHQ9 onset_adult

*Bootstrapping 
program define bootstr, rclass 
	mi impute chained (regress) Age ONSET ResultsPHQ9, add(10) 
	mi estimate: regress ResultsPHQ9 Age ONSET
	return scalar b_phq = el()



