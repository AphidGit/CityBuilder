
/*
 * This file is part of CityBuilder, which is a GameScript for OpenTTD
 *
 * CityBuilder is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * CityBuilder is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CityBuilder; If not, see <http://www.gnu.org/licenses/> or
 * write to the Free Software Foundation, Inc., 51 Franklin Street, 
 * Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */
 
  // Contributors:

///////////////////////////////////////////////
// SCRIPT CONSTANTS
// Some values:
// Cargo_promilles: how much promille of the population of each cargo a town wants, per month (30.6 days).
// Pop_reqs: How much pop a town needs to have to enable each cargo type.
// sigma: deviation factor in the requirements 
// minimum: minimum requirement factor (should be between 0.5 and 1 - 2*sigma, 0 for pop.)
// _min_size__: A town below this size grows linearly.

require("QSort.nut");
require("ERPF.nut");
require("send.nut");
require("HouseList.nut");
require("Place.nut");

function GetVersion(){
local V_BINARY = GSController.GetVersion();
local V_MAJOR = V_BINARY >> 28;
local V_MINOR = (V_BINARY >> 24) % 0x08;
local V_REV = (V_BINARY >> 20) % 0x08;
local V = ""+V_MAJOR+"."+V_MINOR + "." +V_REV;
return V;
}
function _pop_sigma_(){return 0.1;}
function _cargo_minfactor_(){return 0.5;}
function _pop_minfactor_(){return 0.0;}
function month_length (month){
switch(month){
case(2): return 28.0;
case(4): return 30.0;
case(6): return 30.0;
case(9): return 30.0;
case(11): return 30.0;
default: return 31.0;
	}
}
///////////////////////////////////////////////////
class Town extends Place {
///////////////////////////////////////////////////
////////// STATIC VARIABLES
//////////////////////////////////////////////////
static gametype = GSController.GetSetting("gametype");
static store_factor = GSController.GetSetting("storefactor");
static store_min = GSController.GetSetting("store_min");
static stagnation_pct = GSController.GetSetting("stagpct").tofloat() / 1000.0;
static slow_factor = GSController.GetSetting("slow_factor").tofloat();
static assim_factor = GSController.GetSetting("assim_factor");
static fullratio = GSController.GetSetting("mgrpct").tofloat() / 1000.0 + 1.0;
static inject = GSController.GetSetting("injection");
static lowcargo = GSController.GetSetting("lowcargo");
static has_news = GSController.GetSetting("info_broadcast");
static min_size = GSController.GetSetting("min_size_max_growth");
static regrow = GSController.GetSetting("town_regrow");
econ = null;
static version = GetVersion();
/////////////////////////////////////////
// END OF STATIC VARS
//////////////////////////////////////////
mail_tr = 0;
pax_tr = 0;

used = false;
req_any = false;
metro = false;
metro_nepax = true;
company = -1;
num_signs = 0;
nwsmsg = "";
transport_pct = 0;
first_demand_size = 200000;
// Use an array for the cargo supply and such (32 elements)
supply_cargo =  [];
take_cargo   =  [];
prod_cargo   =  [];

goal_cargo =    [];
goal_take_cargo = [];

goals = {};


stocked_cargo = [];
cargo_introduced = [];
// user information.
cargo_signs =  [];
basicsign = -1;
// private variables for algorithm.
rh_x = 0;
rh_y = 0;
is_city = false;
house_list = null;

// town_assimilate (V13 feature)
neighbours = [];
muncipalities = [];
ismuncipality = false;

// Goal UI (V15)
GoalID = [];
// StoryBoard (V102)
Story = [];
myStoryPageID = 0;
// working %age pax requirements
lmp_pax = 0;
lmp_mail = 0;
pxr = 0;
mlr = 0;
// Secondary industry correction (V118)
secIndustry = [];
// has_goal temp value for checking town window. (v118)
has_goal = false;

constructor(town_id, intr, myEcon) {	
	::Place.constructor(town_id);
	this.econ = myEcon;
    this.goals = {};
    this.goals.give <- array(econ.num_cargos);
    this.goals.take <- array(econ.num_cargos);
    this.goals.other <- {
        give = 0,
        take = 0,
        gtt = 0,
        frat = 0,
        pop = 0, 
        isGrow = 0,
        supply = 0,
        next = 0    
    };
	this.house_list = XHouseList(town_id);
	this.cargo_introduced = intr;
	this.supply_cargo = array(econ.num_cargos, 0);
	this.take_cargo = array(econ.num_cargos, 0);
	this.prod_cargo = array(econ.num_cargos, 0);
	
	this.goal_cargo = array(econ.num_cargos, 0);
	this.goal_take_cargo = array(econ.num_cargos, 0);
	
	this.stocked_cargo = array(econ.num_cargos, 0);
	this.cargo_signs = array(econ.num_cargos, -1);	
	
	this.is_city = GSTown.IsCity(this.id);
	this.basicsign = -1;
	first_demand_size = this.econ.enable_populations[0]	
    this.DisableDefaultGoals();
	this.SetGoals();
	this.initStoryBook();
}
	// default function overrides	
		function ToString();
		function ToInteger();
		function Set(new_id, new_start_population, new_supply_cargo, new_stocked_cargo, new_company, new_metro, new_num_signs, new_cargo_signs, new_basicsign, new_muncipalities, new_ismuncipality, new_sec_industry);
		function _typeof();
	// neighbours	
		function AddNeighbour();
		function GetNeighbours();
		function Assimilate();
		function Assim(cid);
	// score keeping	
		function GetScore();
	// Game loop extension
		function Manage();	
	// User Interface	
		function News();
		function Metro_News();
	// News helper functions
		function GetNewsGrowLine();
		function GetTownWindowGrowLine();
		function GetNewsCargoLine(i);
		function GetTownWindowCargoLine(i);
		function GetNewsCargoLineMonochrome(i);
		function GetTownWindowCargoLineMonochrome(i);
		function SetGrowthRateAsCity();
		function ManageAsCity();
	// cargo handling
		function AddCargo();
		function TakeCargo(f);
	// establishing goals
		function SetGoals();
		function UpdateGoal();
		function clearGoal();
		function clearGoalStory();
	// growing and shrinking the town
		function SetGrowthRate(mf = 1.0, gf = 1.0);
		function SetGrowthRateMetro();
		function SetRate();
		function CalculateGrowthRate(mf = 1.0, g = 1.0);
		function ExpandMe(ig);
		function ContractMe(ig);
	// miscellaneous	
		function SetMetro();
		
		function addGoalStoryEntriesForDemands();
		function addGoalStoryEntriesForTakes();
}
      
function Town::ManageAsCity(){
	if(cities_setting == 1 || cities_setting == 2) {
		this.SetGrowthRateAsCity();
	}
}

function Town::SetGrowthRateAsCity(){
	// if regrowth is on:
this.transport_pct = GSTown.GetLastMonthTransportedPercentage(this.id,this.paxcargo);
local num_houses = GSTown.GetHouseCount(this.id);
if(this.regrow > 100) {
	if(pop < start_population) {
			this.growthRate = this.CalculateGrowthRate();
			return;
		}
	}
	if( transport_pct < req && this.pop > this.tsize) {
  // don't grow at all.
		this.is_growing = 0;
	} else {
  // grow at full speed.
		this.is_growing = 3;
		this.growthRate = this.CalculateGrowthRate();
	}
}

function Town::_typeof(){return "Town";}

function Town::Set(new_id, new_start_population, new_supply_cargo, new_stocked_cargo, new_company, 
					new_metro, new_num_signs, new_cargo_signs, new_basicsign, new_muncipalities, new_ismuncipality, new_sec_industry) {
	id					=new_id;
	start_population	=new_start_population;
	supply_cargo		=new_supply_cargo;
	stocked_cargo		=new_stocked_cargo;
	company				=new_company;
	metro				=new_metro;
	num_signs			=new_num_signs;
	cargo_signs			=new_cargo_signs;
	basicsign			=new_basicsign;
	muncipalities		=new_muncipalities;
	ismuncipality		=new_ismuncipality;
	secIndustry         =new_sec_industry;
}

///////////////////////////////////////////////////////////
// Get a string representation of the town (the town's name).
///////////////////////////////////////////////////////////
function Town::ToString(){
	return GSTown.GetName(this.id);
}
///////////////////////////////////////////////////////////
// Get an integer representation of the object (it's ID)
///////////////////////////////////////////////////////////
function Town::ToInteger(){
	return this.id;
}
///////////////////////////////////////////////////////////
// Prevent the town growing normally
///////////////////////////////////////////////////////////
function Town::SetRate(){
// we do growth by hand.
// so set the game's growth rate to very slow.
// do this only once to save cycles.
	GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
	this.GetPop();
	this.GetNeighbours(); //<< Get all towns within 64 tiles, and at least up to 8 towns.
							// moved out of the constructor for performance reasons.
}
///////////////////////////////////////////////////////////
// Do all the actions it needs to do at the start of the month.
///////////////////////////////////////////////////////////
function Town::Manage(){
    if(GSController.GetSetting("growascity") && company == -1 && cities_setting < 3) {
        this.ManageAsCity();
    } else {
        this.AddCargo();
        if(metro){this.SetGrowthRateMetro();}
        else{this.SetGrowthRate();}
        // Do the news
        if(this.metro) {this.Metro_News();}
        else {this.News();}	
        this.Assimilate();
        this.SetGoals();
	}
	ApplyGrowth();
}

///////////////////////////////////////////////////////////
// Calculate the maximum growth rate
///////////////////////////////////////////////////////////
function Town::CalculateGrowthRate(mf = 1.0, g = 1.0) {
	return  this.slow_factor * 1000.0 / (g  * mf * max(this.pop, _min_size__()).tofloat());
}

///////////////////////////////////////////////////////////
// Set the growth rate of the town.
///////////////////////////////////////////////////////////
function Town::SetGrowthRate(mf = 1.0, gf = 1.0) { 
    if(GSController.GetSetting("debug_level") > 4)
        GSLog.Info("Setting growth rate");
	this.used = true;
	// if regrowth is on:
	if(this.regrow > 100){
		if(this.pop < start_population){
			is_growing = 3;
			this.growthRate = this.CalculateGrowthRate(mf, 1.0); 
			this.TakeCargo(1.0);	
			return;	
		}	
	}
	// get the least-delivered cargo ratio and store in variable f.
	local f = this.fullratio;
    if(this.pop < tsize) {
        this.TakeCargo(f);
        return;
    } else if (GSTown.GetLastMonthReceived(this.id,GSCargo.TE_PASSENGERS) == 0){
		f = 1.0;
		this.growthRate = 0;
        this.is_growing = 2;
        this.TakeCargo(1.0);	
        return;
	}
	local t = 0;
	local g = 0.0;
	local w = 0.0
	local gc;
    for(local i = 0; i < this.econ.num_cargos; ++i){
    // skip a cargo if population is under minimum to demand it (or it ain't demanded).	
		gc = goal_cargo[i].tofloat();
		if(gc == 0 || this.pop < this.econ.enable_populations[i] ){continue;}
		t = (supply_cargo[i] + stocked_cargo[i]).tofloat() / gc;
		if(gc < lowcargo){ 
		    w = 1.0 - gc / (lowcargo.tofloat());
		    t=t>w?t:w;
		}
		if(f > t){f = t;}
	}
	
// This ratio determines how fast the town grows
// shrink the town below 1 (remove houses) at inverse speed.
	if(f < 1.0) {
		this.is_growing = 0;
		g = (1.0-f) / (fullratio - 1.0);
		if(g != 0.0 && this.pop * 100 > regrow * this.start_population) {
			this.growthRate = -1.0 * this.CalculateGrowthRate(mf, g); 
		} else {
			this.growthRate = 0;
            this.is_growing = 2;
		}
	} else {
// we have the grow case here.
		this.is_growing = 1;
		g = (f-1.0) / (fullratio - 1.0);
		if(g > 1.0){g = 1.0;}
		if(g > 0.0) {
			this.growthRate = this.CalculateGrowthRate(mf, g); 	
		} else {
			this.is_growing = 2;
			this.growthRate = 0;
		}
		if(f == this.fullratio){ 
			this.is_growing = 3;
		}
	}
// now remove and add cargo.
	this.TakeCargo(f>1.0?f:1.0);
}
///////////////////////////////////////////////////////////
// Set the growth rate of the town. Metro Only!
///////////////////////////////////////////////////////////
function Town::SetGrowthRateMetro() {
	// determine if the metro has sufficient service first.
	if(GetLastMonthTransportedPercentage(this.id, paxcargo) < GSController.GetSetting("metro_cgg")) {
	this.metro_nepax = true;
	return;};
	// get the least-delivered cargo ratio and store in variable f.
	this.metro_nepax = false;
	local mf = GSController.GetSetting("metro_mod");
	local gf = GSController.GetSetting("metro_gmod");
	this.SetGrowthRate(mf, gf);
}

///////////////////////////////////////////////////////////
// Set all the cargo goals.
// The commented out code is for debugging purposes.
///////////////////////////////////////////////////////////
function Town::SetGoals() {
	if(this.pop >= this.tsize){	
		local mult = 0.0;
		local t = 0;
		local date = GSDate.GetCurrentDate();
		local month = GSDate.GetMonth(date);
		if(GSController.GetSetting("debug_level") > 4)
			GSLog.Info("Creating cargo Requirement for " + GSTown.GetName(this.id));
		this.econ.deliveryReqs(this.pop, this.prod_cargo, this.goal_cargo, this.goal_take_cargo, this.id);
		local monLength = month_length(month);
		for(local i = 0; i < this.econ.num_cargos; ++i) {
		    // adjust for month length. 
		    this.goal_cargo[i] = ((this.goal_cargo[i] * 31) / monLength).tointeger();
		    this.goal_take_cargo[i] = ((this.goal_take_cargo[i] * 31) / monLength).tointeger();
		    // Special case: Cargo that hasn't been introduced yet. 
		    // E.g. petrol in the 1800s; don't require it (yet). 
		    if(cargo_introduced[this.econ.enable_order[i]] > 0) {
		        this.goal_cargo[i] = 0;
		        this.goal_take_cargo[i] = 0;		        
		    }		    
		}	
	}
    if(req_any == false || this.used && this.pop < this.tsize){
        this.req_any = false;
    } else{
        this.req_any = true;
    } 
//Log.Info("Any Monthly transport service.", Log.LVL_INFO)
if(this.is_city){
	switch(this.cities_setting){
			case(3): break; // no change
			case(4): goal_cargo[this.econ.getPaxCargo()] = 0; break;
			case(5): goal_cargo[this.econ.getMailCargo()] = 0;  break;
			case(6): goal_cargo[this.econ.getMailCargo()] = 0; goal_cargo[this.econ.getPaxCargo()] = 0;  break;
		}
	}
}
///////////////////////////////////////////////////////////
// Add the delivered simple cargoes to the town (stuff that houses accepts)
///////////////////////////////////////////////////////////
function Town::AddCargo(){
    
    
    
    for(local i = 0; i < this.econ.num_cargos; i++){
        supply_cargo[i] = 0;
        take_cargo[i] = 0;
        local cargoID = this.econ.enable_order[i];
        prod_cargo[i] = GSTown.GetLastMonthProduction(this.id, cargoID);
        for (local cid = GSCompany.COMPANY_FIRST; cid < GSCompany.COMPANY_LAST; cid++) {
            if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID) {
                supply_cargo[i] += GSCargoMonitor.GetTownDeliveryAmount(cid, this.econ.enable_order[i], this.id, true);
                take_cargo[i] += GSCargoMonitor.GetTownPickupAmount(cid, this.econ.enable_order[i], this.id, true);
            } 
            // Secondary industry consumption should be removed.  
            if(supply_cargo[i] > 0) {
                for(local j = 0; j < this.secIndustry.len(); ++j) {
                    supply_cargo[i] -= GSCargoMonitor.GetIndustryDeliveryAmount(cid,cargoID,this.secIndustry[j],true);
                }
            }
        }
        // Sanity check
        if(supply_cargo[i] < 0) {
            supply_cargo[i] = 0;
        }
// note: stocked cargo above ~2 billion will not decay, 
// except 100% decay (which is easy to calculate)./
	    if(stocked_cargo[i] < 2147483){
		    stocked_cargo[i] *= this.econ.decay_rates[i];
		    stocked_cargo[i] /= 1000;		  
		} else {
		    stocked_cargo[i] /= 1000;	
		    stocked_cargo[i] *= this.econ.decay_rates[i];	
		}
		stocked_cargo[i] = stocked_cargo[i].tointeger();
	}
}
///////////////////////////////////////////////////////////
//Let the town take up cargo for one day. 
///////////////////////////////////////////////////////////
function Town::TakeCargo(f){
// take cargo from delivered first
    if(GSController.GetSetting("debug_level") > 4) {GSLog.Info("Take cargo");}
    for(local i = 0; i < this.econ.num_cargos; i++) {
	    stocked_cargo[i] += supply_cargo[i];
	    stocked_cargo[i] -= (f * goal_cargo[i]).tointeger();
    // if we took too many that's just rounding errors.
    // so just ignore this if it happens.	
	    if(stocked_cargo[i] < 0){
	        stocked_cargo[i] = 0;
	        }
	    }
    // limit cargo storage.
    if(this.store_factor > 0) {
	    for(local i = 0; i < this.econ.num_cargos; i++) {
		    if((this.goal_cargo[i] * this.store_factor + this.store_min) < stocked_cargo[i]) {
			        stocked_cargo[i] = this.goal_cargo[i] * this.store_factor + this.store_min;
			    }
		    }
	    }
}
///////////////////////////////////////////////////////////
//Set the town as the METROPOLIS!
// the metropolis requires you to transport it's cargo. 
// it requires less cargo transported to it.
///////////////////////////////////////////////////////////
function Town::SetMetro(){
    this.metro = true;
}

function Town::News(){
    // Modify Goal Window
    if(GSController.GetSetting("debug_level") > 4) {GSLog.Info("Goal window & Storybook");}
	this.UpdateGoal();
    if(GSController.GetSetting("debug_level") > 4) {GSLog.Info("Town window");}
    // cargo numbers of goals
    local tgoal_numbers = [];
    local q = 0;
    for(local i = 0; i < this.econ.num_cargos; i++) {
	    if(goal_cargo[i] > 0) {
		    tgoal_numbers.append(i);
		    ++q
		}
	}
    local nwsmsg = "";
    local next = econ.GetNextDemand(this.pop);
    //GSLog.Info(q + " at " + this.pop);
    // Now we have 4 equally sized arrays containing cargo numbers, goal, storage, and delivered.
    // Depending on the length of the arrays, we present it to the user in different ways.
    switch(q) {
	    case(0):
		    if(this.pop < tsize) {
			    if(next != -1) {
					    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT02, 
						    GSText(GSText.STR_CITYBUILDER_TW_HAMLET), 
						    GSText(GSText.STR_CITYBUILDER_TW_NEXT, 1 << econ.enable_order[next], econ.enable_populations[next])));
				    } else {
					    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_TW_HAMLET));
				    }
			    } else {
				    if(next != -1) {
					    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT002,  
							    GetTownWindowGrowLine(), 
							    GSText(GSText.STR_CITYBUILDER_TW_VILLAGE), 
							    GSText(GSText.STR_CITYBUILDER_TW_NEXT, 1 << econ.enable_order[next], econ.enable_populations[next])));
				    }
			    else{
					    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT2,  
							    GetTownWindowGrowLine(), 
							    GSText(GSText.STR_CITYBUILDER_TW_VILLAGE)));
				    }
			    }		
		    break;	
	    case(1):
		    if(next != -1) {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT042, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0]),
						    GSText(GSText.STR_CITYBUILDER_TW_NEXT, 1 << econ.enable_order[next], econ.enable_populations[next])));
			    } else {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT04, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0])));
			    }
		    break;
	    case(2):
		    if(next != -1) {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT0442, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0]), 
						    GetTownWindowCargoLine(tgoal_numbers[1]),
						    GSText(GSText.STR_CITYBUILDER_TW_NEXT, 1 << econ.enable_order[next], econ.enable_populations[next])));
			    } else {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT044, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0]), 
						    GetTownWindowCargoLine(tgoal_numbers[1])));
			    }
		    break;
	    case(3):
		    if(next != -1) {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT04442, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0]), 
						    GetTownWindowCargoLine(tgoal_numbers[1]), 
						    GetTownWindowCargoLine(tgoal_numbers[2]),
						    GSText(GSText.STR_CITYBUILDER_TW_NEXT, 1 << econ.enable_order[next], econ.enable_populations[next])));
			    } else {
				    GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CONCAT0444, 
						    GetTownWindowGrowLine(), 
						    GetTownWindowCargoLine(tgoal_numbers[0]), 
						    GetTownWindowCargoLine(tgoal_numbers[1]), 
						    GetTownWindowCargoLine(tgoal_numbers[2])));
			    }		
		    break;
	    default:
    // point towards the goal window.
		    if(GSController.GetSetting("point_to_goal") == 1) {
			    GSTown.SetText(this.id, GSText(GSText.STR_CITYBUILDER_SEEGOALWINDOW, this.company));
		    } else {
			    local q = 0;
			    nwsmsg = "";
			    switch(this.is_growing) {
				    case(0): 
					    nwsmsg += GSTown.GetName(this.id)+ " is not growing. D/S/R: ";
					    break;
				    case(1):
					    nwsmsg += GSTown.GetName(this.id)+ " is growing slowly. D/S/R: ";
					    break;		
				    case(2):
					    nwsmsg += GSTown.GetName(this.id)+ " is stagnant. D/S/R: ";
					    break;	
				    case(3):
					    nwsmsg +=GSTown.GetName(this.id)+ " is growing! D/S/R: ";
					    break;			
			    }
		    for(local i = 0; i < this.econ.num_cargos; i++) {
			    if(goal_cargo[i] > 0 && this.pop > econ.enable_populations[i]) {
			    if(q) nwsmsg += ", "
			    q = 1;
			    if(this.econ.decay_rates[i] != 0) {
				    nwsmsg += (supply_cargo[i]).tostring() + "/" +(stocked_cargo[i]).tostring() + "/" +
					    ((goal_cargo[i]).tointeger()).tostring() + " " + GSCargo.GetCargoLabel(this.econ.enable_order[i]);
					    } else {
				    nwsmsg += (supply_cargo[i]).tostring() + "/" +
					    ((goal_cargo[i]).tointeger()).tostring() + " " + GSCargo.GetCargoLabel(this.econ.enable_order[i]);
					    }
				    }
			    }
		    nwsmsg += ".";
		    if(q == 0) {
			    if(this.pop < tsize) {
				    nwsmsg += " The town does not have any demands yet."
				    } else {
				    nwsmsg += " Supply a monthly transport service to start growth. ";
				    }
			    }
                //SendAdmin(this.company + nwsmsg);
			    GSTown.SetText(this.id,nwsmsg);							
		    }
	    break;	
	    }
    }

function Town::Metro_News(){
    local q = 0;
    nwsmsg = "";
    if(this.metro_nepax) {
	    nwsmsg += "The metropolis demands additional transport services for its people before it will grow any further!";
	} else {
	    switch(this.is_growing) {
		    case(0): 
			    nwsmsg += GSTown.GetName(this.id)+ " is not growing. Delivered/Storage/Required: ";
			    break;
		    case(1):
			    nwsmsg += GSTown.GetName(this.id)+ " is growing slowly. Delivered/Storage/Required: ";
			    break;		
		    case(2):
			    nwsmsg += GSTown.GetName(this.id)+ " is stagnant. Delivered/Storage/Required: ";
			    break;	
		    case(3):
			    nwsmsg +=GSTown.GetName(this.id)+ " is growing! Delivered/Storage/Required: ";
			    break;			
		    }
	    for(local i = 0; i < this.econ.num_cargos; i++)
		    {
		    if(goal_cargo[i] > 0  && this.pop > this.econ.size_reqs[i])
			    {
			    if(q) nwsmsg += ", "
			    q = 1;
			    nwsmsg +=(supply_cargo[i]).tostring() + "/" +(stocked_cargo[i]).tostring() + "/" +
				    ((goal_cargo[i]).tointeger()).tostring() + " " + GSCargo.GetCargoLabel(this.econ.enable_order[i]);
			    }
		    }
	    }
    if(q == 0) {
	    if(this.pop < tsize)  {
		    nwsmsg += "The town does not have any demands yet."
		} else {
		    nwsmsg += " Supply a monthly transport service to start growth.";
		}
	}
    if(this.pop >= tsize) {
	    nwsmsg += " Deliver additional cargo to grow the town!";
	    this.UpdateGoal();
	    GSTown.SetText(this.id,nwsmsg);
    }
}

function Town::GetNeighbours() {
    local towns = GSTownList(); // Get a list of all towns
    local id2 = towns.Begin();
    local j = 0;
    local d = 0;
    local distances = [];
    local towns_a = [];
    foreach(t, _ in towns) {
	    d = GSTown.GetDistanceSquareToTile(this.id, GSTown.GetLocation(t));
	    distances.append(d);
	    towns_a.append(t);
	}
    // Now we have an array towns_a with all the towns,
    // and a second array with the distances. 
    local towns_s = QSort(distances, towns_a);
    GSLog.Info(GSDate.GetSystemTime() + " Town done:" + GSTown.GetName(this.id));
    // up to 3 are 
    // The first town in the array is itself so we skip it (j starts at 1)
    local _l = towns_a.len();
    while(j < 3 && j < _l) {
	    neighbours.append(towns_s[j]);
	    //d =   GSTown.GetDistanceSquareToTile(this.id, GSTown.GetLocation(towns_s[j]));
	    j++;
	    //Log.Info(GSTown.GetName(this.id) + " nb of " + GSTown.GetName(towns_s[j]), Log.LVL_INFO);
	}
}

function Town::Assimilate() {
    if( GSController.GetSetting("assim_factor") != 0) {
	    local loc = GSTown.GetLocation(this.id);
	    local tid;
	    for(local i = 0; i<this.neighbours.len(); i++) {
		    tid = this.neighbours[i];
		    if(tid != this.id) {
			    if(this.pop > assim_factor * GSTown.GetPopulation(tid) && (cities_setting >= 3 || GSTown.IsCity(tid) == false)) {
	// The test is to see if townzone #3 overlaps the other town's center or zone #3.
				    local f1 = GSTown.GetHouseCount(this.id) / 8 * 5 - 5;
				    if(f1 < 0){f1 = 0;}
				    local f2 = GSTown.GetHouseCount(tid) / 8 * 5 - 5;
				    if(f2 < 0){f2 = 0;}
				    local c = f1 + f2; // + sqrt(f1) * sqrt(f2) * 2 << Removed for optimization...
				    if(GSController.GetSetting("debug_level") > 6) {
				        GSLog.Info("Assim: " GSTown.GetName(tid) + " and "+ GSTown.GetName(this.id) + "req " + c);
				    }
	// optimization: reuse f1
				    f1 = GSTown.GetDistanceSquareToTile(tid,loc);
				    if(c > f1){
	// assimilate the second town
					    this.neighbours.remove(i);
					    this.Assim(tid);
					}	
				} else if(this.pop < GSTown.GetPopulation(tid) / assim_factor  && (cities_setting >= 3 || GSTown.IsCity(this.id) == false)) {
				    local f1 = GSTown.GetHouseCount(this.id) / 8 * 5 - 15;
				    if(f1 < 0){f1 = 0;}
				    local f2 = GSTown.GetHouseCount(tid) / 8 * 5 - 15;
				    if(f2 < 0){f2 = 0;}
				    local c = f1 + f2;  // + sqrt(f1) * sqrt(f2) * 2 << Removed for optimization...
	// optimization: reuse f1
				    f1 = GSTown.GetDistanceSquareToTile(tid,loc);
				    if(c > f1) {
					    this.ismuncipality = true;
					}
				}
			}
		}
	}
}

function Town::Assim(tid){
	GSLog.Info("Merging Towns " + GSTown.GetName(tid) + " to "+ GSTown.GetName(this.id), Log.LVL_INFO);
	for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++) {
		if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID) {
			GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_CITYBUILDER_TAKEOVER, tid, this.id),cid, GSNews.NR_TOWN, this.id);
		}
	}
	this.muncipalities.append(tid);
	// add another neighbour
	this.AddNeighbour();
}

function Town::AddNeighbour() {
    local towns = GSTownList(); // Get a list of all towns
    local id2 = towns.Begin();
    local j = 2 + muncipalities.len();
    local d = 0;
    local distances = [];
    local towns_a = [];
    foreach(t, _ in towns) {
	    d = GSTown.GetDistanceSquareToTile(this.id, GSTown.GetLocation(t));
	    distances.append(d);
	    towns_a.append(t);
	}
// Now we have an array towns_a with all the towns,
// and a second array with the distances. 
    local towns_s = QSort(distances, towns_a);
// NOTE: towns within MD 64 are all checked.
// beyond that, up to 8 are. 
// The first town in the array is itself so we skip it (j starts at 1)
    local _l = towns_s.len();
    if(j < _l) {
	    neighbours.append(towns_s[j]);
	    d =  GSTile.GetDistanceManhattanToTile(GSTown.GetLocation(this.id), GSTown.GetLocation(towns_s[j]));
	    j++;
	}
}

function Town::GetScore() {
    local score = 0;
    foreach(t in this.muncipalities) {
	    score += GSTown.GetPopulation(t);
	}
    score += this.pop;
    return score;
}


function Town::initStoryBook() {
	this.myStoryPageID = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSTown.GetName(this.id));
	GSStoryPage.NewElement(myStoryPageID, GSStoryPage.SPET_LOCATION, GSTown.GetLocation(this.id), GSText(GSText.STR_CITYBUILDER_SB_GOTO));
    this.goals.other.pop = this.addStory(GSText(GSText.STR_CITYBUILDER_SB_POPULATION,this.pop), this.goals.other.pop);
    this.goals.other.isGrow = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_STAGNANT),this.goals.other.isGrow);
    this.goals.other.give = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_DEMANDS_TO),this.goals.other.give);
    for(local i = 0; i < this.econ.num_cargos; i++) {
        if(this.econ.accept_rel[i] > 0) {
            if(this.goal_cargo[i] > 0) {
                has_goal = true;
                local cargo_id = this.econ.enable_order[i];
                this.goals.give[i] = this.addGoalStory(
                    GSText(
                        GSText.STR_CITYBUILDER_GW_C, 
                        1 << cargo_id,  
                        0, 
                        goal_cargo[i],
                        0, 
                        0), 
                    this.goals.give[i]);	
            } else {
                this.goals.give[i] = this.addGoalStory("", this.goals.give[i]);
            }
        }
    }
    
	this.goals.other.take = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_DEMANDS_FROM),this.goals.other.take);	
    for(local i = 0; i < this.econ.num_cargos; i++) {
        if(this.econ.prod_rel[i] > 0) {
            if(this.goal_cargo[i] > 0) {
                has_goal = true;
                local cargo_id = this.econ.enable_order[i];
                this.goals.take[i] = this.addGoalStory(
                    GSText(
                        GSText.STR_CITYBUILDER_GW_C, 
                        1 << cargo_id,  
                        0, 
                        goal_take_cargo[i],
                        0, 
                        0), 
                    this.goals.take[i]);		
            } else {
                this.goals.give[i] = this.addGoalStory("", this.goals.give[i]);
            }
        }
    }
	if(!has_goal) {
	    if(this.pop < tsize) {
	        this.goals.other.gtt = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_HAMLET),this.goals.other.gtt);
	    } else {
	        this.goals.other.gtt = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_VILLAGE),this.goals.other.gtt);
	    }
	}
	local next = econ.GetNextDemand(this.pop);
	if(next != -1) {
		this.goals.other.next = this.addGoalStory(GSText(GSText.STR_CITYBUILDER_GW_NEXT, 1 << (this.econ.enable_order[next]), this.econ.enable_populations[next]),this.goals.other.next);
	} else {
        this.goals.other.next = 0;
    }
}

// Updates the town's goals
function Town::UpdateGoal(){
    this.clearGoalStory();
	if(GSController.GetSetting("debug_level") > 5) {
        GSLog.Info("Cleared goal");
    }
    this.updateStory(GSText(GSText.STR_CITYBUILDER_SB_POPULATION,this.pop), this.goals.other.pop);
    has_goal = false;
// Add new ones.
	this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_GOALS, (fullratio * 100).tointeger() + 1),this.goals.other.frat);
    switch(this.is_growing) {
	    case(0): 		// decrease
		    this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_NOT_GROWING),this.goals.other.isGrow);
		    break;
	    case(1): 		// growth (slow)
		    this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_B_GROWING),this.goals.other.isGrow);
		    break;
	    case(2):		// stagnant
		    this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_STAGNANT),this.goals.other.isGrow);
		    break;
	    case(3):		// growth(fast)
		    this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_A_GROWING),this.goals.other.isGrow);
		    break;
	}
	this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_DEMANDS_TO),this.goals.other.give);
	this.updateGoalStoryEntriesForDemands();
	this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_DEMANDS_FROM),this.goals.other.take);	
	this.updateGoalStoryEntriesForTakes();
	if(!has_goal) {
	    if(this.pop < tsize) {
	        this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_HAMLET),this.goals.other.gtt);
	    } else {
	        this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_VILLAGE),this.goals.other.gtt);
	    }
	}
	local next = econ.GetNextDemand(this.pop);
	if(next != -1) {
		this.updateGoalStory(GSText(GSText.STR_CITYBUILDER_GW_NEXT, 1 << (this.econ.enable_order[next]), this.econ.enable_populations[next]),this.goals.other.next);
	} else {
        this.updateGoalStory("", this.goals.other.next);
    }
}

function Town::updateGoalStoryEntriesForDemands() {
    for(local i = 0; i < this.econ.num_cargos; i++) {
        if(this.econ.accept_rel[i] > 0) {
            local cargo_id = this.econ.enable_order[i];
            if(this.goal_cargo[i] > 0) {
                has_goal = true;
                if(this.econ.decay_rates[i] != 0) {
                    if(supply_cargo[i] >= goal_cargo[i] * fullratio) {
                        this.updateGoalStory(GSText(
                                    GSText.STR_CITYBUILDER_GW_G, 
                                    1 << cargo_id,  
                                    supply_cargo[i], 
                                    goal_cargo[i],
                                    (stocked_cargo[i]), 
                                    min(100 * stocked_cargo[i] / (goal_cargo[i] * store_factor + store_min), 100)), 
                            this.goals.give[i]);		
                    } else if(supply_cargo[i] >= goal_cargo[i]) {
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_A, 
                                    1 << cargo_id,  
                                    supply_cargo[i], 
                                    goal_cargo[i],
                                    (stocked_cargo[i]), 
                                    min(100 * stocked_cargo[i] / (goal_cargo[i] * store_factor + store_min), 100)), 
                            this.goals.give[i]);		
                    } else if(supply_cargo[i] + stocked_cargo[i] >= goal_cargo[i]) {
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_B, 
                                    1 << cargo_id, 
                                    supply_cargo[i], 
                                    goal_cargo[i],
                                    (stocked_cargo[i]), 
                                    min(100 * stocked_cargo[i] / (goal_cargo[i] * store_factor + store_min), 100)), 
                            this.goals.give[i]);		
                    } else {	
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_C, 
                                    1 << cargo_id,  
                                    supply_cargo[i], 
                                    goal_cargo[i],
                                    (stocked_cargo[i]), 
                                    min(100 * stocked_cargo[i] / (goal_cargo[i] * store_factor + store_min), 100)), 
                            this.goals.give[i]);		
                    }
                } else {
                    if(supply_cargo[i] * 1000 >= goal_cargo[i] * (1000 + fullratio)) {
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_F, 
                                    1 << cargo_id,  
                                    supply_cargo[i], 
                                    goal_cargo[i]
                                    ), 
                            this.goals.give[i]);		
                    } else if(supply_cargo[i] + stocked_cargo[i] >= goal_cargo[i]) {
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_D, 
                                    1 << cargo_id,  
                                    supply_cargo[i], 
                                    goal_cargo[i]), 
                            this.goals.give[i]);		
                    } else {	
                        this.updateGoalStory(
                                GSText(
                                    GSText.STR_CITYBUILDER_GW_E, 
                                    1 << cargo_id, 
                                    supply_cargo[i], 
                                    goal_cargo[i]
                                    ),
                            this.goals.give[i]);		
                    }
                }
            } else {
                this.updateGoalStory("", this.goals.give[i]);
            }
        }
    }
}

function Town::updateGoalStoryEntriesForTakes() {
    for(local i = 0; i < this.econ.num_cargos; i++) {
        if(this.econ.prod_rel[i] > 0) {
            local cargo_id = this.econ.enable_order[i];
            if(this.goal_take_cargo[i] > 0) {
                has_goal = true;
                if(take_cargo[i] * 1000 >= goal_take_cargo[i] * (1000 + fullratio)) {
                    this.updateGoalStory(
                        GSText(
                            GSText.STR_CITYBUILDER_GW_J, 
                            1 << cargo_id,  
                            take_cargo[i], 
                            goal_take_cargo[i]), 
                        this.goals.take[i]);		
                } else if(take_cargo[i] >= goal_take_cargo[i]) {
                    this.updateGoalStory(
                        GSText(
                            GSText.STR_CITYBUILDER_GW_H, 
                            1 << cargo_id,  
                            take_cargo[i], 
                            goal_take_cargo[i]
                        ), 
                        this.goals.take[i]);		
                } else {	
                    this.updateGoalStory(
                        GSText(
                            GSText.STR_CITYBUILDER_GW_I, 
                            1 << cargo_id, 
                            take_cargo[i], 
                            goal_take_cargo[i]
                        ), 
                        this.goals.take[i]);			
                }
            } else {
                this.updateGoalStory("", this.goals.take[i]);
            }
        }
	}
}


function Town::clearGoal() {
	// Remove the old goals.
	foreach(ID in GoalID) {
		GSGoal.Remove(ID);
	}
	GoalID = [];	
}

// Clear the storyboard page and goal window for this town
function Town::clearGoalStory() {
	this.clearGoal();
	// Don't need to clear the story book.
	Story = [];
	// Refresh the date in the story book
	GSStoryPage.SetDate(this.myStoryPageID,GSDate.GetCurrentDate()); 	
}
// Add one line of text to the story board and goal window. 
function Town::addGoalStory(goalText, storyBookID) {
	// if we are the metropolis...
	if(this.metro) {
		for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++) {
			if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID) {
				this.GoalID.push(GSGoal.New(cid, goalText, GSGoal.GT_NONE, 0));				
			}
		}
	}
	else if(this.company >= 0) {
		this.GoalID.push(GSGoal.New(company, goalText, GSGoal.GT_NONE, 0));
	}
	// in all cases: update the story board!
	return this.addStory(goalText, storyBookID);
}


function Town::updateGoalStory(goalText, storyBookID) {
	// if we are the metropolis...
	if(this.metro) {
		for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++) {
			if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID) {
				this.GoalID.push(GSGoal.New(cid, goalText, GSGoal.GT_NONE, 0));				
			}
		}
	}
	else if(this.company >= 0) {
		this.GoalID.push(GSGoal.New(company, goalText, GSGoal.GT_NONE, 0));
	}
	// in all cases: update the story board!
    GSStoryPage.UpdateElement(storyBookID, 0, goalText);
}

function Town::addStory(goalText, storyBookID) {
    if(storyBookID) {
        GSStoryPage.UpdateElement(storyBookID, 0, goalText);
        return storyBookID;
    } else {
        local elt = GSStoryPage.NewElement(this.myStoryPageID, GSStoryPage.SPET_TEXT, 0, goalText);
        Story.push(elt);
        return elt;
    } 
}
function Town::updateStory(goalText, storyBookID) {
    GSStoryPage.UpdateElement(storyBookID, 0, goalText);
}
// Create the line of text saying whether the town is growing/not, TW Edition.
function Town::GetTownWindowGrowLine(){
switch(this.is_growing) {
	case(0): 
		return GSText(GSText.STR_CITYBUILDER_TW_NOT_GROWING);
	case(1):
		return GSText(GSText.STR_CITYBUILDER_TW_B_GROWING);
	case(2):
		return GSText(GSText.STR_CITYBUILDER_TW_STAGNANT);
	case(3):
		return GSText(GSText.STR_CITYBUILDER_TW_A_GROWING);
	}
}
function Town::GetNewsGrowLine(){
switch(this.is_growing) {
	case(0): 
		return GSText(GSText.STR_CITYBUILDER_NEWS_NOT_GROWING);
	case(1):
		return GSText(GSText.STR_CITYBUILDER_NEWS_B_GROWING);
	case(2):
		return GSText(GSText.STR_CITYBUILDER_NEWS_STAGNANT);
	case(3):
		return GSText(GSText.STR_CITYBUILDER_NEWS_A_GROWING);
	}
}
// Get the cargo line for the cargo_id. 
function Town::GetTownWindowCargoLine(i){
local cargo_id = this.econ.enable_order[i];
if(this.econ.decay_rates[i] != 0) {
	if(supply_cargo[i] >= goal_cargo[i] * fullratio)
		{
		return GSText(GSText.STR_CITYBUILDER_TW_G,1 << cargo_id,supply_cargo[i],goal_cargo[i],stocked_cargo[i]);
		}
	else if(supply_cargo[i] >= goal_cargo[i])
		{
		return GSText(GSText.STR_CITYBUILDER_TW_A,1 << cargo_id,supply_cargo[i],goal_cargo[i],stocked_cargo[i]);
		}
	else if(supply_cargo[i] + stocked_cargo[i] >= goal_cargo[i])
		{
		return GSText(GSText.STR_CITYBUILDER_TW_B,1 << cargo_id,supply_cargo[i],goal_cargo[i],stocked_cargo[i]);
		}
	else{
		return GSText(GSText.STR_CITYBUILDER_TW_C,1 << cargo_id, supply_cargo[i],goal_cargo[i],stocked_cargo[i]);
		}
	}
else{
	if(supply_cargo[i]  >= goal_cargo[i] * fullratio)
		{
		return GSText(GSText.STR_CITYBUILDER_TW_F,1 << cargo_id,supply_cargo[i],goal_cargo[i], 0); // Extra param to fool the GSText lib.
		}
	else if(supply_cargo[i] + stocked_cargo[i] >= goal_cargo[i])
		{
		return GSText(GSText.STR_CITYBUILDER_TW_D,1 << cargo_id,supply_cargo[i],goal_cargo[i], 0);
		}
	else{
		return GSText(GSText.STR_CITYBUILDER_TW_E,1 << cargo_id, supply_cargo[i],goal_cargo[i], 0);
		}	
	}
}

function Town::GetNewsCargoLine(i){
local cargo_id = this.econ.enable_order[i];
if(this.econ.decay_rates[i] != 0)
	{
	return GSText(GSText.STR_CITYBUILDER_NEWS_A,1 << cargo_id,supply_cargo[i],goal_cargo[i],stocked_cargo[i]);
	}
else{
	return GSText(GSText.STR_CITYBUILDER_NEWS_D,1 << cargo_id,supply_cargo[i],goal_cargo[i], 0); 
	}
}


