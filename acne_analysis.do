*Loading in data
clear all
use "Z:\acne_psychosocial.dta"

*Recoding sex binary feature (0=female,1=male)
recode Sex (2=0)
tabulate Sex
save "Z:\acne_psychosocial.dta", replace

**Descriptive stats and exploring data 
*Inspecting present age and age of onset
describe A
sum
tab Age
hist ONSET

*Two-way histogram of present age and age of onset 
twoway (histogram Age, color(red%50) lcolor(none) bin(30)) ///
	   (histogram ONSET, color(green%50) lcolor(none) bin(30)), ///
	   legend(label(1 "Age at PHQ9 scoring") label(2 "Age of acne onset")) ///
	   ytitle("Density") xtitle("Years")
	   
*Correlation matrix of PHQ9 results and demographic characteristics
spearman ResultsPHQ9 Age Sex smoke cigarettes Alcohol New_where_does_the_pt_live New_if_pt_lives_in_urban_environ BMI Socioeconomic_status

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

*Registering variables for imputation
mi register imputed Age Sex smoke cigarettes Alcohol ONSET Duration persistent  NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole CombinedAcneScore Scars FaceScar ScarringSeverityFace FamilyScar pt_location pt_urban_loc WellBeingScale ResultsPHQ9 BMI Socioeconomic_status Type_adultAcne

*Multiple imputation test
mi impute chained (regress) Age ONSET ResultsPHQ9, add(10) orderasis nomonotone force noisily
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

*Bootstrapping 
program define bootstr, rclass 
	mi impute chained (regress) Age ONSET ResultsPHQ9, add(10) 
	mi estimate: regress ResultsPHQ9 Age ONSET
	return scalar b_phq = el()



