/*===========================================================
Author:				Sarah Kotb
Do-file:			REAP_Datalib_Ado attempt
Assignment:			Draft 1 main body
Created:			August 9th, 2016
Last Modified:		August 15th, 2016
=============================================================*/
clear
set more off

** Macros ** 
* global repos "/afs/ir.stanford.edu/users/s/k/skotb/private/Datalib/Test_Repository"
global repos "/Users/Sarah/Documents/REAP/Datalib/Test_Repository"
	* NOTE: Change path up here ^^

/*Steps:
	1) Check if option clear is specified
	2) Check if datasets exist
	3) Load datasets
		3.1) If one dataset is requested, load it.
		3.2) If two or more datasets are requested, append and load
	*/

cap program drop datalib 
global repos "/Users/Sarah/Documents/REAP/Datalib/Test_Repository" 
program datalib
	syntax namelist(min=1 max = 4) [,clear]
	local projects "Malawi India"
	local num : word count (`namelist')
	tokenize `namelist'
	local error 0
	
	* Check if option clear is specified correctly
	qui des, short
	if ((r(k) != 0 | r(N) != 0) & "`clear'" == "" ) {
		di as err "Error: Data will be lost. Save and clear current data, or specify the clear option."
		exit 
	}
	
	* Check if dataset exists
	local error 0
	forvalues i =1/`num' {
		if strpos("`projects'", "``i''") == 0 {
			local ++error
		} 
	}
	if `error' != 0 {
		di as err "Error: One or more of the requested projects are not archived."
		exit
	} 
	
	* Check for repetitions
	local error 0
	forvalues i = 1/`num' {
		scalar j = `i'
		while j < `num' {
			scalar j = j + 1
			local j = j
			if ("``i''" == "``j''") {
				di as err "Error: Project ``i'' requested more than once."
				local ++error
				exit
			} 
		}
	}
	if (`error' > 0) {
		exit
	}
	
	
	* Load datasets
	if `num' == 1 {
		use "${repos}/`1'.dta", clear
		di in yellow "Loaded dataset: project `1'"
	} 
	else {
		* For 2 or more datasets, append:
		use "${repos}/`1'.dta", clear
		di in yellow "Loaded dataset: project `1'"
		forvalues i = 2/`num' {
			append using "${repos}/``i''.dta", nolabel force
			di "Loaded dataset: project ``i''"
		}
	} 
end

* TESTS
datalib Egypt // Expected error: Dataset not available 
datalib Malawi // Should work
datalib India // Expected error: have data in memory and did not specify clear
datalib Malawi India, clear // Should work
datalib Malawi India Malawi // Expected error: repeated a dataset.


		
		
/*Things to think of:
	1) subprogram to lookup information (ex survey year - used in which papers)
	2) Github versus local location. 
	3) Add options to load only specific datawaves (ex baseline only) or specific
		provinces
	4) Ado format
	5) Security checks. 
							*/
