*Loading in data
use "Z:\acne_psychosocial.dta"

*Inspecting present age and age of onset
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

*Set imputation to wide format
mi set wide
*Set random seed 
set seed 2024


