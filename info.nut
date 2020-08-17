require ("version.nut")
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
 
  // Contributors: lukasz1985

class CityBuilder extends GSInfo {
	function GetAuthor()		{ return "Aphid"; }
	function GetName()			{ return "CityBuilder"; }
	function GetDescription() 	{ return "Luukland style Citybuilder"; }
	function GetVersion()		{ return SELF_VERSION; }
	function GetDate()			{ return "2020-07-25"; }
	function CreateInstance()	{ return "CityBuilder"; }
	function GetShortName()		{ return "CBGS"; }
	function GetAPIVersion()	{ return "1.5"; }
	function GetUrl()			{ return ""; }
	function GetSettings() {	
		AddSetting({name = "debug_level", description = "debug level", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME, min_value = 0, max_value = 7});
		AddLabels("debug_level", {_0 = "Off", _1 = "Minimal", _2 = "Low", _3 = "Medium", _4 = "High", _5 = "Very High", _6 = "Verbose", _7 = "Everything" });
		AddSetting({name = "point_to_goal", description = "Point to goal GUI > 3 goals: ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_INGAME, min_value = 0, max_value = 1});
		AddLabels("point_to_goal", {_0 = "No", _1 = "Yes"});
		AddSetting({name = "Town_Labels", description = "Show owner above town name", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME, min_value = 0, max_value = 1});
		AddLabels("Town_Labels", {_0 = "Off", _1 = "On"});
		AddSetting({name = "Town_Density", description = "Amount of tiles per town: ", easy_value = 12288, medium_value = 12288, hard_value = 12288, custom_value = 12288, flags = CONFIG_INGAME, min_value = 0, max_value = 65536, step_size = 1024});
		AddLabels("Town_Density", {_0 = "Don't spawn extra towns"});
		AddSetting({name = "Industry_Density", description = "Amount of tiles per primary industry: ", easy_value = 512, medium_value = 512, hard_value = 512, custom_value = 512, flags = CONFIG_INGAME, min_value = 63, max_value = 65536, step_size = 1});
		AddLabels("Industry_Density", {_63 = "Don't spawn extra primary industry"});
		AddSetting({name = "Industry_S_Density", description = "Amount of tiles per secondary industry: ", easy_value = 4096, medium_value = 4096, hard_value = 4096, custom_value = 4096, flags = CONFIG_INGAME, min_value = 63, max_value = 65536, step_size = 1});
		AddLabels("Industry_S_Density", {_63 = "Don't spawn extra secondary industry"});
		AddSetting({name = "Industry_Water", description = "Build industries on water: ", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME, min_value = 0, max_value = 1});
		AddLabels("Industry_Water", {_0 = "No", _1 = "Yes"});
		AddSetting({name = "Industry_Town", description = "Chance of building industry in a town at game start", 
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME, min_value = 0, max_value = 1000, step_size = 1});
			AddLabels("Industry_Town", {_0 = "Nil", _1000 = "One of everything"});
		AddSetting({name = "gametime", description = "Game Length in years: "
			easy_value = 4, medium_value = 8, hard_value = 12, custom_value = 16, flags= CONFIG_INGAME, min_value = 0, max_value = 1000});
		AddLabels("gametime", {_0 = "Indefinite"});
		AddSetting({name = "gamegoal", description = "Goal Target: "
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags= CONFIG_INGAME, min_value = 0, max_value = 10000000, step_size = 500});
		AddLabels("gamegoal", {_0 = "Disabled"});			
		AddSetting({name = "gametype", description = "Game Type: "
			easy_value = 0, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_INGAME, min_value = 0, max_value = 3});
		AddLabels("gametype", {_0 = "FreeBuilder", _1 = "CityBuilder", _2 = "CityBuilder Co-Op", _3 = "Metropolis"});
		AddSetting({name = "hqmaxdist", description = "Maximum HQ distance to claim town: "
			easy_value = 20, medium_value = 15, hard_value = 12, custom_value = 10, flags=0, min_value = 5, max_value = 32});
		AddSetting({name = "metro_mod", description = "Metropolis cargo multiplier: "
			easy_value = 5, medium_value = 3, hard_value = 2, custom_value = 1, flags = CONFIG_INGAME, min_value = 1, max_value = 500});
		AddSetting({name = "metro_gmod", description = "Metropolis growth multiplier:"
			easy_value = 3, medium_value = 2, hard_value = 1, custom_value = 1, flags = CONFIG_INGAME, min_value = 1, max_value = 500});			
		AddSetting({name = "metro_cgg", description = "Metropolis transport requirement (MTR): "
			easy_value = 50, medium_value = 65, hard_value = 75, custom_value = 80, flags = CONFIG_INGAME, min_value = 30, max_value = 98});		
		AddSetting({name = "local_to_req", description = "Subtract local transported passengers "
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME | CONFIG_BOOLEAN});
		AddSetting({name = "maxclaimsize", description = "Maximum population of a claimable town: ", 
			easy_value = 750, medium_value = 500, hard_value = 250, custom_value = 200, flags = CONFIG_INGAME, min_value = 0, max_value = 4000, step_size = 25});	
		AddLabels("maxclaimsize", {_0 = "Infinite"});
		AddSetting({name = "growascity", description = "Unclaimed towns behave as cities: ", 
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME | CONFIG_BOOLEAN});	
		AddSetting({name = "min_size_max_growth", description = "Below this population growth is linear: ", 
			easy_value = 1200, medium_value = 800, hard_value = 600, custom_value = 400, flags = CONFIG_INGAME, min_value = 50, max_value = 8000, step_size = 25});
		AddSetting({name = "min_size_tr", description = "Below this population all towns grow: ", 
			easy_value = 150, medium_value = 125, hard_value = 100, custom_value = 100, flags = CONFIG_INGAME, min_value = 50, max_value = 40000, step_size = 25});	
		AddSetting({name = "slow_factor", description = "Town size at which town grows with one house per day in thousands: ", 
			easy_value = 60, medium_value = 60, hard_value = 60, custom_value = 60, flags = CONFIG_INGAME, min_value = 10, max_value = 1000});
		AddSetting({name = "mgrpct", description = "Max growth promillage:", 
			easy_value = 400, medium_value = 500, hard_value = 600, custom_value = 700, flags = CONFIG_INGAME, min_value = 100, max_value = 65535});				
		AddSetting({name = "assim_factor", description = "factor needed to assimilate: "
			easy_value = 2, medium_value = 2, hard_value = 3, custom_value = 4, flags=0, min_value = 0, max_value = 1000});	
		AddLabels("assim_factor", {_0 = "infinite"});	
		AddSetting({name = "storefactor", description = "Town warehouse size (months): "
			easy_value = 8, medium_value = 6, hard_value = 4, custom_value = 2, flags=0, min_value = 0, max_value = 360});
		AddLabels("storefactor", {_0 = "infinite"});	
		AddSetting({name = "store_min", description = "Town warehouse size (minimum): "
			easy_value = 780, medium_value = 390, hard_value = 200, custom_value = 288, flags=0, min_value = 1, max_value = 2000});
		AddSetting({name = "town_regrow", description = "Regrow towns, (% of starting pop): "
			easy_value = 140, medium_value = 120, hard_value = 120, custom_value = 100, flags=0, min_value = 100, step_size = 10, max_value = 300});
		AddLabels("town_regrow", {_100 = "Do NOT regrow"});
		AddSetting({name = "cities_setting", description = "Behaviour of cities: ",
			easy_value = 0, medium_value = 0, hard_value = 6, custom_value = 6, flags = CONFIG_INGAME, min_value = 0, max_value = 6});
		AddLabels("cities_setting", {_0 = "cities grow normally", _1= "cities grow above MTR", _2 = "cities grow randomly above MTR",_3 = "cities grow per citybuilder rules", 
		_4 = "citybuilder rules, but no passengers required", _5 = "CB, no mail", _6 = "CB, no passengers nor mail"} );
		AddSetting({name = "city_cgg", description = "City growth Multiplier promillage: "
			easy_value = 2400, medium_value = 2200, hard_value = 2000, custom_value = 1400, flags = CONFIG_INGAME, min_value = 1, max_value = 65535});
		// CARGO SETTINGS
		AddSetting({name = "injection", description = "Enable Freeze:", easy_value = 0, medium_value = 0, hard_value = 1, custom_value = 0, 
		    flags = CONFIG_INGAME, min_value = 0, max_value = 1});
		AddLabels("injection", {_0 = "Off", _1 = "On"});
		AddSetting({name = "paxcargo_istownind", description = "Industries that produce Passengers are Town Industries", 
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_INGAME | CONFIG_BOOLEAN});					
		AddSetting({name = "swapfw", description = "Towns in the tropic require no water but more food: ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_INGAME, min_value = 0, max_value = 1});
		AddLabels("swapfw", {_0 = "No", _1 = "Yes"});
		AddSetting({name = "lowcargo", description = "Reduced shrink effect:",
			easy_value = 360, medium_value = 180, hard_value = 20, custom_value = 0, flags = CONFIG_INGAME, min_value = 0, max_value = 1000, step_size = 20});
		AddLabels("lowcargo", {_0 = "Disabled"});
		AddSetting({name = "introdelay", description = "Introduction Delay (yrs): ",
			easy_value = 5, medium_value = 3, hard_value = 2, custom_value = 2, flags = CONFIG_INGAME, min_value = 0, max_value = 60});	
		AddLabels("introdelay", {_0 = "Disabled"});
		AddSetting({name = "cargomul", description = "Cargo Requirement Multiplier",
			easy_value = 1000, medium_value = 1100, hard_value = 1200, custom_value = 1250, flags=0, min_value = 100, max_value = 5000});		
		AddSetting({name = "intromul", description = "Introduction Population Multiplier",
			easy_value = 1000, medium_value = 900, hard_value = 800, custom_value = 700, flags=0, min_value = 250, max_value = 5000});
		AddSetting({name = "econ_custom", description = "Use custom Economy: ", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_BOOLEAN});
		for(local i = 0; i < 32; ++i){		
		   AddSetting({name = "cargo_dlv["+i+"]", description = "Cargo #"+i+" delivery requirement", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags=0, min_value = 0, step_size = 1, max_value = 2000});  
		    AddSetting({name = "cargo_sup["+i+"]", description = "Cargo #"+i+" supply requirement", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags=0, min_value = 0, step_size = 1, max_value = 2000});
		    AddSetting({name = "cargo_int["+i+"]", description = "Cargo #"+i+" introduction population", easy_value = 200, medium_value = 200, hard_value = 200, custom_value = 200, flags=0, min_value = 200, step_size = 50, max_value = 1000000});
		    AddSetting({name = "cargo_max["+i+"]", description = "Cargo #"+i+" full requirement population", easy_value = 500, medium_value = 500, hard_value = 500, custom_value = 500, flags=0, min_value = 250, step_size = 50, max_value = 1000000});
		    AddSetting({name = "cargo_dcr["+i+"]", description = "Cargo #"+i+" decay rate", easy_value = 50, medium_value = 50, hard_value = 50, custom_value = 50, flags=0, min_value = 0, step_size = 1, max_value = 1000}); 
		    AddLabels("cargo_dcr["+i+"]", {_1000 = "No storage"});
        }
    }	
}
RegisterGS(CityBuilder());
