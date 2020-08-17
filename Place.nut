class Place {

  static req = GSController.GetSetting("metro_cgg");
  static cities_setting = GSController.GetSetting("cities_setting");
  static paxcargo = GSController.GetSetting("metro_cargo");
  static slow_factor = GSController.GetSetting("slow_factor").tofloat();
  static gametype = GSController.GetSetting("gametype");
  static min_pop = GSController.GetSetting("min_size_tr");
  static regrow = GSController.GetSetting("town_regrow");  
  static tsize = GSController.GetSetting("min_size_tr");
	// carry variables for growth
	carryHouses = 0;
	id = 0;
	is_growing = 0;
	start_population = 0;
	pop = 0;	
	growthRate = 0;
		
	constructor(town_id) {			
		this.id = town_id;
		start_population = GSTown.GetPopulation(town_id);
		pop = start_population;
	}
	
	function ApplyGrowth();
	function DisableDefaultGoals();	
	function GetPop();

} 
/**
 * Note: We may want to replace the IGR carry-over with linear instead of inverse carry over for efficiency. 
 */
function Place::ApplyGrowth() {
	// Get rid of any silly cases. 
	if(growthRate <= 0) {
		GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
		return;
	}
	// if the growth rate is really large, build additional houses. 
	if(growthRate < 2) {
		// the weird number here is the amount of days in an average month. 
		// carry takes care of 'non-whole numbers' nicely without using rand (which is slow). 
		local excessHouses = ((1 / growthRate) - 0.5) * 30.436875 + this.carryHouses;
		local fleH = floor(excessHouses);
		this.carryHouses = excessHouses - fleH;
		GSTown.ExpandTown(this.id, fleH.tointeger());
		GSTown.SetGrowthRate(this.id, 1);
	} else {
		GSTown.SetGrowthRate(this.id, ceil(growthRate).tointeger() - 1);
	}
}

///////////////////////////////////////////////////////////
// Only get population...
///////////////////////////////////////////////////////////
function Place::GetPop(){
	pop = GSTown.GetPopulation(this.id);
	return pop;
}

// Disable the default '1 unit of water' '1 unit of food' goals, etc.
function Place::DisableDefaultGoals(){
GSTown.SetCargoGoal(id,GSCargo.TE_PASSENGERS,0);
GSTown.SetCargoGoal(id,GSCargo.TE_MAIL,0); 	
GSTown.SetCargoGoal(id,GSCargo.TE_WATER,0); 	
GSTown.SetCargoGoal(id,GSCargo.TE_FOOD,0); 	
GSTown.SetCargoGoal(id,GSCargo.TE_GOODS,0); 	 	
}
