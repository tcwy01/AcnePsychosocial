*Loading in data
use "Z:\acne_psychosocial.dta"

**Descriptive stats and exploring data 
*Inspecting present age and age of onset
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

*Multiple imputation according to type of data 
mi impute chained (regress) Age cigarettes ONSET Duration NurseLeedsGradeFaceWhole NurseBackLeedsGrade NurseLeedsGradeChestWhole WellBeingScale ResultsPHQ9 BMI (logit, augment) smoke Alcohol persistent Scars FaceScar FamilyScar Socioeconomic_status (ologit) ScarringSeverityFace (mlogit) Sex pt_location pt_urban_loc Type_adultAcne, add(10) orderasis nomonotone force noisily augment

*Saving imputed dataset 
save "Z:\imputed_acne_psychosocial.dta", replace



