
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

require("Towngrowth.nut");
require("Citygrowth.nut");
require("IC.nut");
require("comp.nut");
require("version.nut");
require("send.nut");
require("Atomic.nut");
require("QSort.nut");
require("econ/econ.nut");


/* Import SuperLib for GameScript */
import("util.superlib", "SuperLib", 39);
Result <- SuperLib.Result;
Log <- SuperLib.Log;
//Helper <- SuperLib.Helper;
ScoreList <- SuperLib.ScoreList;
Tile <- SuperLib.Tile;
Direction <- SuperLib.Direction;
//Town <- SuperLib.Town; // conflicts with Town class of this GS
// Industry <- SuperLib.Industry; // conflicts with Industry class. Causes GSText Problem?

class CityBuilder extends GSController 
{
	constructor()
	{
	
	// Get executive rights immediately.
	//mode = GSExecMode();
	}
	on_load = false;
		data = null;
		mode = null;
		towns = [];
		cities = [];
		town_access = [];
		city_access = [];
		industries = null;
		stations = null;
		companies =  [];
		registered_companies = [];
		intro = [];	// Cargo Introduction Dates
		go = true;
		metro_town_id = 0;
		last_date = 0;
		month = 1;
		year = 0;
		game_length = 0;
		start_year = 1950;
		Score_List = 0;
		// sort towns alphabetically
		townSort = [];
		citySort = [];
		// Temporary arrays for towns, cities, companies.
		val_to = [];
		val_ci = [];
		val_co = [];
		// Economy object.
		myEcon = null;
	
	function SetMetroTown();
	function Init();
	function addIndustry(ev);
	function remIndustry(ev);
	}
	

// for testing sendstats
//require("sendstats.nut");	
	
	function CityBuilder::Save()
{
	if(GSController.GetSetting("debug_level") > 0)
		Log.Info("Saving data", Log.LVL_INFO);
	data = {	sv_mode = mode,
				sv_registered_companies = registered_companies,
				sv_go = go,
				sv_last_date = last_date,
				sv_month =month,
				sv_year = year,
				sv_game_length = game_length,
				sv_start_year = start_year,
				sv_intro = intro,
				sv_metro_town_id = metro_town_id,
				sv_companies = [],
				// these four are heavy!
				sv_town_access = town_access,
				sv_city_access = city_access, 
				sv_towns = [],
				sv_cities = []
};
	for(local l = 0; l < companies.len(); ++l)
		{
		data.sv_companies.append(companies[l].tzgt);
		data.sv_companies.append(companies[l].tzgtwns);
		data.sv_companies.append(companies[l].id);
		data.sv_companies.append(companies[l].my_town);
		data.sv_companies.append(companies[l].gametype);
		data.sv_companies.append(companies[l].score.tointeger());
		data.sv_companies.append(companies[l].score_quarter.tointeger());
		data.sv_companies.append(companies[l].hq);
		data.sv_companies.append(companies[l].townsign);
		}
	for(local l = 0; l < towns.len(); ++l)
		{		
		if(typeof towns[l] == "Town"){
		data.sv_towns.append(towns[l].id);
		data.sv_towns.append(towns[l].start_population);
		data.sv_towns.append(towns[l].supply_cargo);
		data.sv_towns.append(towns[l].stocked_cargo);
		data.sv_towns.append(towns[l].company);
		data.sv_towns.append(towns[l].metro);
		data.sv_towns.append(towns[l].num_signs);
		data.sv_towns.append(towns[l].cargo_signs);
		data.sv_towns.append(towns[l].basicsign);
		data.sv_towns.append(towns[l].muncipalities);
		data.sv_towns.append(towns[l].ismuncipality);
		data.sv_towns.append(towns[l].secIndustry);
			}
		}
	for(local l = 0; l < cities.len(); ++l)
		{
		if(typeof cities[l] == "City"){
		data.sv_cities.append(cities[l].id);
		data.sv_cities.append((cities[l].mult * 65536).tointeger());
		data.sv_cities.append(cities[l].sign_id);
		data.sv_cities.append(cities[l].start_population);
			}
		}
	return data;
}

function CityBuilder::Load(version, tbl)
{
	if(GSController.GetSetting("debug_level") > 0)
		Log.Info("Loading data from savegame made with version " + version + " of the game script", Log.LVL_INFO);
	local templist = GSTownList();
	local templist_length = templist.Count();	
	if(GSController.GetSetting("debug_level") > 1)
		Log.Info(templist_length + " towns found.", Log.LVL_INFO);
	this.towns = array(templist_length + 10,0);
	cities = array(templist_length + 10, 0);
foreach(key, val in tbl)
	{	
	//////////////////////////////////////////////////// SIMPLE VARS
	if(key == "sv_mode") 					mode = val;	
	if(key == "sv_last_date") 				last_date = val;
	if(key == "sv_go") 						go = val;		
	if(key == "sv_month") 					month = val;
	if(key == "sv_year") 					year = val;
	if(key == "sv_game_length") 			game_length = val;
	if(key == "sv_start_year") 				start_year = val;	
	if(key == "sv_metro_town_id") 			metro_town_id = val;			
	if(key == "sv_town_access")				town_access = val;
	if(key == "sv_city_access")				city_access = val;
	if(key == "sv_registered_companies") 	registered_companies = val;
	if(key == "sv_intro")					intro = val;
	}
	///////////////////////////////////////////////// COMPLEX VARS
foreach(key, val in tbl)
	{	
	if(key == "sv_companies") 				
		{		
		if(GSController.GetSetting("debug_level") > 1)
			Log.Info("Loading company data, " + val.len() + " fields", Log.LVL_INFO);
		val_co = val;
		}
	if(key == "sv_towns")
		{
		if(GSController.GetSetting("debug_level") > 1)
			Log.Info("Loading town data, " + val.len() + " fields", Log.LVL_INFO);
		val_to = val;
		}
	if(key == "sv_cities")	
		{
		if(GSController.GetSetting("debug_level") > 1)
			Log.Info("Loading city data, " + val.len() + " fields", Log.LVL_INFO);
		val_ci = val;
		}
	}
if(registered_companies.len() == 0){ registered_companies = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];}
if(GSController.GetSetting("debug_level") > 1)
	Log.Info("Reloading Towns...", Log.LVL_INFO);
foreach(company in companies){company.ReloadTown();}
if(GSController.GetSetting("debug_level") > 0)
	Log.Info("Succesfully loaded!", Log.LVL_INFO);
this.on_load = true;
if(start_year + GSController.GetSetting("gametime") >  GSDate.GetYear(GSDate.GetCurrentDate()) || GSController.GetSetting("gametime") == 0) go = true;
if(go) {if(GSController.GetSetting("debug_level") > 1){Log.Info("Recomputing reqs next month.", Log.LVL_INFO);}}
}

function CityBuilder::Second_Load(){
if(GSController.GetSetting("debug_level") > 0)
	GSLog.Info("Recreating Towns");
for(local i = 0; i < val_to.len(); i+=12)
	{	
	if(GSController.GetSetting("debug_level") > 2)
		GSLog.Info("Found Town:" + GSTown.GetName(val_to[i]));
	this.towns[val_to[i]] = Town(val_to[i], intro.weakref(), myEcon);
	this.towns[val_to[i]].Set(val_to[i],val_to[i+1],val_to[i+2],val_to[i+3],val_to[i+4],val_to[i+5],val_to[i+6],val_to[i+7],val_to[i+8], val_to[i+9], val_to[i+10], val_to[i+11]);
	}
if(GSController.GetSetting("debug_level") > 0)
	GSLog.Info("Recreating Cities");
for(local i = 0; i < val_ci.len(); i+=4)
	{
	cities[val_ci[i]] = City(val_ci[i]);
	cities[val_ci[i]].Set(val_ci[i],val_ci[i+1] / 65536.0,val_ci[i+2], val_ci[i+3]);
	}
if(GSController.GetSetting("debug_level") > 0)
	GSLog.Info("Recreating Companies");
companies = [];
local j = 0;
for(local i = 0; i < val_co.len(); i+=9){
	companies.append(Company(val_co[i], towns.weakref(), town_access.weakref()));
	companies[j].Set(val_co[i],val_co[i+1],val_co[i+2],val_co[i+3],val_co[i+4],val_co[i+5],val_co[i+6],val_co[i+7],val_co[i+8]);
	j++;
	}
}

function CityBuilder::SetupEconomy() {    
    // Note: This is hacky code -- We use to detect FIRS/ECS/YETI
    // Todo: Improve this
    // Detect FIRS via recyclables
    local landscape = null;
    GSLog.Info("Initializing economy. Cargo labels: ");
	if(GSController.GetSetting("debug_level") > 1) {
	    for(local i = 0; i < 32; ++i) { 
		    GSLog.Info("Cargo Label: " + i + ": " + GSCargo.GetCargoLabel(i)) ;
		}
	}
    if(GSController.GetSetting("econ_custom") == 1) {
        require("econ/econ_custom.nut");
        this.myEcon = econ_custom();
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(3) == "VBOD") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.PLAIN);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(19) == "PEAT") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.ARCTIC);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(16) == "NITR") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.TROPIC);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(30) == "VBOD") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.STEEL);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(8) == "JAVA") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.HOT);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(24) == "RCYC") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.EXTREME);
        this.myEcon.init();
        return;
    }
    if(GSCargo.GetCargoLabel(28) == "BDMT") {
        require("econ/econ_firs.nut");
        this.myEcon = econ_firs(econ_firs.ONEFOUR);
        this.myEcon.init();
        return;
    }
    // Detect YETI
    if(GSCargo.GetCargoLabel(16) == "YETI") {
        require("econ/econ_yeti.nut");
        this.myEcon = econ_yeti();
        this.myEcon.init();
        return;
    }
    // Detect ECS
    if(GSCargo.GetCargoLabel(31) == "TOUR") {
        require("econ/econ_ecs.nut");
        this.myEcon = econ_ecs();
        this.myEcon.init();
        return;
    }
    
    landscape = GSGame.GetLandscape(); 
    switch(landscape) {
        case(GSGame.LT_TEMPERATE):
            this.myEcon = econ();        
            break;    
        case(GSGame.LT_ARCTIC):
            require("econ/econ_arctic.nut");
            this.myEcon = econ_arctic(); 
            break;
        case(GSGame.LT_TROPIC):
            require("econ/econ_desert.nut");
            this.myEcon = econ_desert(); 
            break;
        case(GSGame.LT_TOYLAND):
            require("econ/econ_toyland.nut");
            this.myEcon = econ_toyland(); 
            break;    
    }
    this.myEcon.init();
        return;
}

function CityBuilder::SetupTowns(){
	if(GSController.GetSetting("debug_level") > 1) {
		Log.Info("Setting City Signs ...", Log.LVL_INFO);
	}
	local temp_list = GSTownList();
	foreach(t, _ in temp_list) {
		if(GSTown.IsCity(t)) GSSign.BuildSign(GSTown.GetLocation(t), GSText(GSText.STR_CITYBUILDER_CITY));
	}
	if(GSController.GetSetting("debug_level") > 1)
		GSLog.Info(GSDate.GetSystemTime() + " Creating town list ...");
	if(GSController.GetSetting("cities_setting") >= 3) {
	    if(GSController.GetSetting("debug_level") > 1) {
		    GSLog.Info(GSDate.GetSystemTime() +" Combining cities and towns in list...");
		}
	    CreateCombiList();
	} else {
	    CreateTownAndCityList(); 
	}
	// check if we have a decent number of claimable towns.
	// else pop a warning message in log..
	local num_claimable_towns = 0;
	local max_claim_pop = GSController.GetSetting("maxclaimsize");
    for(local j = 0; j < town_access.len(); j++) {
	    if(towns[town_access[j]].pop <= max_claim_pop && (!(towns[town_access[j]].is_city))) {
		    num_claimable_towns++;
		    } else if (max_claim_pop == 0) {
		    num_claimable_towns++;
		}
	}
	// Set the secondary industries in the towns.
    if(num_claimable_towns < 16) {
	    Log.Warning("Warning! Low number ("+num_claimable_towns+") of claimable towns!", Log.LVL_INFO);
	}
    if(GSController.GetSetting("debug_level") > 1) {
	    Log.Info(GSDate.GetSystemTime() + " Creating Industry list ...", Log.LVL_INFO);	
	}
    industries = this.CreateIndustryList();
    if(GSController.GetSetting("gamemode") == 3) {
	    this.SetMetroTown();
	}
    if(GSController.GetSetting("debug_level") > 1) {
	    Log.Info(GSDate.GetSystemTime() + " Setting initial growth rates ...", Log.LVL_INFO);	
	}
	// Set initial time the towns will grow & set monitoring.
	for(local j = 0; j < town_access.len(); j++) {
	    for(local i = 0; i < 32; i++) {
	        for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++) {
		        if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID) {
	                GSCargoMonitor.GetTownDeliveryAmount(cid, i,town_access[j],true);
	            }   
	        }   
	    }
	}
}

function CityBuilder::InitNewCompany(cid)
{
local metro_town_id = this.metro_town_id;
switch(GSController.GetSetting("gametype"))
	{
	case(0):
	if(GSController.GetSetting("gametime") == 0) GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_I_FREEBUILDER_START), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	else GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_FREEBUILDER_START, GSController.GetSetting("gametime")), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	break;
	case(1):
	if(GSController.GetSetting("gametime") == 0) GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_I_START), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	else GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_START, GSController.GetSetting("gametime")), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	break;
	case(2):
	if(GSController.GetSetting("gametime") == 0) GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_I_COOP_START), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	else GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_COOP_START, GSController.GetSetting("gametime")), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	break;
	case(3):
	if(GSController.GetSetting("gametime") == 0) GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_I_METROPOLIS_START, metro_town_id), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	else GSGoal.Question(8001, cid, GSText(GSText.STR_CITYBUILDER_METROPOLIS_START, metro_town_id, GSController.GetSetting("gametime")), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
	break;
	}
local nwsstr = "REQS: ";
local temp = false;
local cess;
companies.append(Company(cid, towns.weakref(), town_access.weakref()));
}
// THIS FUNCTION IS DEPRECATED.
function CityBuilder::HandleEvents()
{
local id = 0;
local x = 0;
local temptown = 0;
	while(GSEventController.IsEventWaiting())
	{
		local ev = GSEventController.GetNextEvent();
		
	// New industry Opens.
	// (this shouldn't matter...)
	
		if(ev.GetEventType == GSEvent.ET_INDUSTRY_OPEN)
		{
		if(GSController.GetSetting("debug_level") > 3)
			Log.Info("New Industry Opens", Log.LVL_INFO);	
		id = ev.GetIndustryID();
		temptown = GSTile.GetTownAuthority(GSIndustry.GetLocation(id));
		if(GSTown.IsValidTown(temptown))
			{
			industries.append(Industry(id, temptown));			
			if(GSController.GetSetting("debug_level") > 4)
				Log.Info("Adding industry to list", Log.LVL_INFO);	
			for(local i = 0; i < 32; i++)
				{
				for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++)
					{
					if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID)
						{
						GSCargoMonitor.GetIndustryDeliveryAmount(cid, i, id,true)
						}	
					}	
				}	
			}
		}
	// An Industry closes down!
		else if (ev.GetEventType == GSEvent.ET_INDUSTRY_CLOSE){
		id = ev.GetIndustryID();
		x = 0;
		for(local i = 0; i < 32; i++){
			for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++)
			{
				if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID)
					{
				GSCargoMonitor.GetIndustryDeliveryAmount(cid, i, id,true)
		}}}
		if(industries != null){
			foreach(industry in industries)
			{
			if(industry.id == id)
				{
				industries.remove(x);
				}
			x++;	
			}}
		} else
		
	// new company. 
	
		if (ev.GetEventType == GSEvent.ET_COMPANY_NEW){
		DetectCompanies;	
		}
		else if (ev.GetEventType == GSEvent.ET_COMPANY_BANKRUPT){
		DetectCompanies;
		}
		else if (ev.GetEventType == GSEvent.ET_COMPANY_MERGER){
		DetectCompanies;
		}		
		if(ev == null)
			return;
	}
}
//////////////////////////////////// Program entry point
function CityBuilder::Start()
{
	GSGame.Pause();
	if(!this.on_load)
		{
		this.Init_Industry();
		}
	Sleep(1);
	LoadIntroductionDates();
	Score_List = SList();
	if(!this.on_load)
		{
		this.Init();
		}
	else{
		for(local i = 0; i < 550; ++i){GSGoal.Remove(i);}
		this.SetupEconomy();
		Second_Load();
		}		
	if(GSController.GetSetting("debug_level") > 2)
		Log.Info(GSDate.GetSystemTime() +" Finding Neighbours", Log.LVL_INFO);
	foreach(t in this.town_access){
	towns[t].SetRate();}	
	if(GSController.GetSetting("debug_level") > 0)
		Log.Info(GSDate.GetSystemTime() + " Loading complete", Log.LVL_INFO);
	GSGame.Unpause();

while (go == true) 
	{
	this.Manage();
	}
	EndGame();
}
//////////////////////////////////// If you want to use CB as part of another script, 
// Call this function on game start, and 
// Connect the load and save functions, and
// Make sure to call my Manage() at least once per day.
function CityBuilder::Start_Lib()
{
	GSGame.Pause();
	if(!this.on_load)
		{
		this.Init_Industry();
		}
	Sleep(1);
	LoadIntroductionDates();
	Score_List = SList();
	if(!this.on_load)
		{
		this.Init();
		}
	else{
		for(local i = 0; i < 550; ++i){GSGoal.Remove(i);}
		Second_Load();
		}		
	if(GSController.GetSetting("debug_level") > 2)
		Log.Info(GSDate.GetSystemTime() +" Finding Neighbours", Log.LVL_INFO);
	foreach(t in this.town_access){
	towns[t].SetRate();}	
	if(GSController.GetSetting("debug_level") > 0)
		Log.Info(GSDate.GetSystemTime() + " Loading complete", Log.LVL_INFO);
	GSGame.Unpause();
}
/////////////////////////////////////// Creating Lists.
	function CityBuilder::CreateIndustryList() {
    local result = [];
    local the_industries = GSIndustryList();
    local t = 0;
    foreach(i, _ in the_industries) {
        this.addIndustryToTown(i);
    }
	return result;
}
	
	
function CityBuilder::CreateTownAndCityList() {
	/* Make a squirrel table of all towns.
	// Make a squirrel table of all cities.
	// notation is a bit funky.
	 */
	local the_towns = GSTownList();
	local name_list = [];
	local id_list = [];
	local name_list2 = [];
	local id_list2 = [];
	foreach(t, _ in the_towns)
	{
		if(GSTown.IsCity(t) == false){	
			name_list.push(GSTown.GetName(t));
			id_list.push(t);
		} else {
			name_list2.push(GSTown.GetName(t));
			id_list2.push(t);		
		}
	}
	this.townSort = QSort(name_list, id_list);
	this.citySort = QSort(name_list2, id_list2);	
	foreach(t in this.townSort) {
		towns[t] = Town(t, intro.weakref(), myEcon); 
		town_access.append(t);
	}
	foreach(t in this.citySort) {
		cities[t] = City(t); 
		city_access.append(t);
	}

	return;
}

	function CityBuilder::CreateCombiList()
{
	/* Make a squirrel table of all cities.
	 */
	local the_towns = GSTownList();
	local name_list = [];
	local id_list = [];
	foreach(t, _ in the_towns)
	{
		name_list.push(GSTown.GetName(t));
		id_list.push(t);
	}
	this.townSort = QSort(name_list, id_list);
	foreach(t in this.townSort) {
		towns[t] = Town(t, intro.weakref(), myEcon); 
		town_access.append(t);
	}
	return;
}
/////////////////////////////////////// Finishing...
// Note: the gamescript stays in this function, disabling itself, after the game ends.
function CityBuilder::EndGame()
{
// Game's done.
GSGame.Pause();
local total_pop_gain = 0;	
// special case for normal cb and metro: add in muncipalities!
if(GSController.GetSetting("gametype") % 2 == 1)
	{
	foreach(company in companies)
		{
		foreach(X in town_access)
			{
			if(company.my_town == towns[X].id)
				{
				// company company has town t.
				company.SetRawScore(towns[X].GetScore());
				}	
			}
		}
	}	
// get the highest score
// A score of 0 is always a failure though.
local highscore = 1;
foreach(company in companies)
	{
	if(company.score > highscore){highscore = company.score;}
	}
switch(GSController.GetSetting("gametype"))
	{
case(0):
	// freebuilder
	foreach(X in town_access)
		{
		total_pop_gain += towns[X].pop-towns[X].start_population;
		}
	// do this to prevent integer overflows.
	// integer overflows can now only really happen at 4,000,000+ score.
	// which doesn't realistically occur. Score is limited at around 400 per year.
	total_pop_gain /= 10000;
	if(total_pop_gain = 0){total_pop_gain++;}
	foreach(company in companies){
	company.score *= total_pop_gain;
	company.RateMe_type0(highscore * total_pop_gain);	
	SendAdmin("Score: " + company.id + ":" + company.score);
	}	
	// exit out of the script.
	go = false;	
	break;
case(1):
	// citybuilder
	// present players' scores
	foreach(company in companies){
	company.RateMe_type1(highscore);
	SendAdmin("Score: " + company.id + ":" + company.score);	}
	// exit out of the script.
	go = false;
	break;
case(2):
	// coop
	for(local i = 0; i < town_access.len(); i++){
	total_pop_gain += GSTown.GetPopulation(town_access[i])-towns[town_access[i]].start_population;}
	foreach(company in companies){
	company.RateMe_type0(total_pop_gain);
	SendAdmin("Score: " + company.id + ":" + company.score);	}		
	// exit out of the script.
	go = false;	
	break;
case(3):
	// metropolis
	total_pop_gain += GSTown.GetPopulation(metro_town_id);
	foreach(company in companies){
	company.RateMe_type2(total_pop_gain);
	SendAdmin("Score: " + company.id + ":" + company.score);	}	
	// exit out of the script.
	go = false;	
	break;
	}
// Until quitting is fixed (OpenTTD bug) we instead loop infinitely.
while(true)
	{
	towns = null;
	cities = null;
	town_access = [];
	city_access = [];
	companies =  [];
	registered_companies = [];
	GSLog.Info("Script succesfully exited");
	Sleep(1000000);
	}	
}
/////////////////////////////////// Main game loop
	function CityBuilder::Manage()
	
{
	/* Main Town Loop starts here
	*  Run Only once a day
	*/
this.HandleEvents();
local date = GSDate.GetCurrentDate();
if(GSController.GetSetting("gametime") > 0)
	{
	if(year - start_year >= GSController.GetSetting("gametime"))
		{
		this.EndGame();
		}
	}
local high_score = 0;
foreach(company in companies)
	{
	if(high_score < company.score)
		high_score = company.score;
	}
local target = GSController.GetSetting("gamegoal");
if(high_score > target && target != 0)
	this.EndGame();
local diff = date - last_date;
last_date = date;
if (diff == 0) return;	
//HandleEvents();

for(local i = 0; i < town_access.len(); i++)
	{
	towns[town_access[i]].GetPop();
	}
if(city_access.len() > 0)
	{
	for(local i = 0; i < city_access.len(); i++)
		{
	cities[city_access[i]].SetRate();
		}	
	}
// Now (each day!) detect new companies and update them; 

	// Ensure atomic for 1500 ops (estimate upper limit) 
	Atomic(1500);
this.TestForRemovedCompanies();
this.DetectCompanies();	
for (local i = 0; i < companies.len(); ++i) 
	{
	companies[i].ManageDaily();			
	}
// On the first day of the month, manage the towns, industries, detect new companies:
	
if(GSDate.GetMonth(date) != month)
	{
	// Log performance.	
	if(GSController.GetSetting("debug_level") > 2)
		GSLog.Info("Starting manage. Last Month:" + month);
	// Log (test) sendfnc
	//SendStatistics(0, test_sendfnc, test_cargo_suffix_fnc);
	/*
	if(industries != null)
		{
		foreach(industry in industries)
			{
			industry.AddCargo();
			}
		}*/
	month = GSDate.GetMonth(date);
	for(local i = 0; i < town_access.len(); i++)
		{
		// incremental performance log.		
		if(GSController.GetSetting("debug_level") > 3)
			GSLog.Info("Town manage: " + GSTown.GetName(town_access[i]));
		towns[town_access[i]].Manage();
		}
	for(local i = 0; i < city_access.len(); i++)
		{
		cities[city_access[i]].Manage();
		}
if(companies != null)
	{
	this.TestForRemovedCompanies();
	Atomic(7000);
	foreach(comp in companies)
		{
		comp.ManageMonthly();	
		}
	Score_List.Manage(companies);
	}
	// Log total performance	
	if(GSController.GetSetting("debug_level") > 2)
		GSLog.Info("End of manage. This Month:" + month);	
	}
if(GSDate.GetYear(date) != year)
	{
	year = GSDate.GetYear(date);
	ManageIntroductionDates();	
	}
	Sleep(1);
}
/////////////////////////////////// For when new companies join the game
function CityBuilder::DetectCompanies(){
	// company detection
for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++)
	{
		if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID && registered_companies[cid] == 0)
		{			
			if(GSController.GetSetting("debug_level") > 2)
				GSLog.Info("Company Found");
			InitNewCompany(cid);
			registered_companies[cid] = 1;
		}
		else this.TestForRemovedCompanies();
	}	
}
// Set one town as metropolis at random.	
function CityBuilder::SetMetroTown(){
if(metro_town_id == 0){
local numtowns = town_access.len();
local metro = GSBase.RandRange(numtowns);
metro_town_id = town_access[metro];
towns[metro_town_id].SetMetro();}
else{	// for loading a saved game
towns[metro_town_id].SetMetro();
}
}
function CityBuilder::Init_Industry(){
    if(GSController.GetSetting("Town_Density") > 0) SpawnExtraTowns();
	if(GSController.GetSetting("Industry_Town") > 0) CreateExtraTownIndustry();
	else Log.Info(GSDate.GetSystemTime() + " No industries spawned in towns", Log.LVL_INFO);
	CreateExtraSecondaryIndustry();
	CreateExtraIndustry();	
	if(GSController.GetSetting("debug_level") > 2)
		Log.Info(GSDate.GetSystemTime() + " Industry creation (if any) succesful.", Log.LVL_INFO);
}

////////////////////////////// Initialization function.
function CityBuilder::Init(){

	// we need max. performance!
	this.SetCommandDelay (0);
	GSGameSettings.SetValue("script.ops_till_suspend", 250000);
	GSGoal.New(GSCompany.COMPANY_INVALID, "Company Scores:", GSGoal.GT_NONE, 0);
	for (local cid = GSCompany.COMPANY_FIRST; cid <= GSCompany.COMPANY_LAST; cid++) {
	    registered_companies.append(0);
	}
	// get the number of towns.
	// town ID's are always 1-n. Abuse this fact.a
	local templist = GSTownList();
	local templist_length = templist.Count();	
	if(GSController.GetSetting("debug_level") > 1)
		Log.Info(templist_length + " towns found.", Log.LVL_INFO);
	towns = array(templist_length + 10);
	cities = array(templist_length + 10);
	this.HandleEvents();
	local start_tick = GSController.GetTick();
	start_year = GSDate.GetYear(GSDate.GetCurrentDate());
	GSGameSettings.SetValue("economy.found_town", 0);
	// Setup all towns.
	this.SetupEconomy();
	this.SetupTowns();
	// Fetch companies 
if(GSController.GetSetting("debug_level") > 0)
	Log.Info(GSDate.GetSystemTime() + " Fetching companies", Log.LVL_INFO);
this.DetectCompanies();
if(GSCompany.ResolveCompanyID(GSCompany.COMPANY_SELF) != GSCompany.COMPANY_INVALID)
	{	
	if(GSController.GetSetting("debug_level") > 1)
		Log.Info("Company Found", Log.LVL_INFO);
	this.InitNewCompany(GSCompany.COMPANY_SELF);
	}

}
/*
function CityBuilder::test_sendfnc(msg,cmp){
Log.Info(msg, Log.LVL_INFO);}

function CityBuilder::test_cargo_suffix_fnc(i){
return "sfx";
}*/
function CityBuilder::TestForRemovedCompanies(){
for(local i = 0; i < companies.len(); i++)
	{
	if(this.registered_companies[companies[i].id] == 1 && GSCompany.ResolveCompanyID(companies[i].id) == GSCompany.COMPANY_INVALID)
		{
		this.registered_companies[companies[i].id] = 0;		
		if(GSController.GetSetting("debug_level") > 1)
			Log.Info("Company Removed", Log.LVL_INFO);
		if(companies[i].my_town != -1)
			{
			towns[companies[i].my_town].company = -1;	//< A bit hacky, but works well.
			towns[companies[i].my_town].CleanupGoals(); //< Removes goals. 
			}
		companies[i].OnDestroy();
		companies[i].my_town = -1;
		companies.remove(i);
		}
	}
}
// NOTE: Has to be called from the HandleEvents of main.
function CityBuilder::HandleEvents()
{
	while(GSEventController.IsEventWaiting())
	{
		local ev = GSEventController.GetNextEvent();
		
		switch(ev)
		{
		case(GSEvent.ET_COMPANY_BANKRUPT):
			this.TestForRemovedCompanies();
			break;
		case(GSEvent.ET_COMPANY_MERGER):
			this.TestForRemovedCompanies();
			break;
		case(GSEvent.ET_INDUSTRY_OPEN):
		    this.addIndustry(ev);
		    break;
		case(GSEvent.ET_INDUSTRY_CLOSE):
		    this.remIndustry(ev);
		    break;
		}

		if(ev == null)
			return;
	}
}

function CityBuilder::addIndustry(ev){
    local i = ev.GetIndustryID();
    this.addIndustryToTown(i);
}

function CityBuilder::addIndustryToTown(i) {
    local t = GSTile.GetTownAuthority(GSIndustry.GetLocation(i));
    if(GSTown.IsValidTown(t) && "secIndustry" in this.towns[t] && GSIndustryType.IsProcessingIndustry(GSIndustry.GetIndustryType(i))) {
        this.towns[t].secIndustry.append(i);
        Log.Info("Secondary Industry Found", 6);	
    }
}
function CityBuilder::remIndustry(ev) {
    local i = ev.GetIndustryID();
    local t = GSTile.GetTownAuthority(GSIndustry.GetLocation(i));
    k = -1;
    if(GSTown.IsValidTown(t) && "secIndustry" in this.towns[t] && GSIndustryType.IsProcessingIndustry(GSIndustry.GetIndustryType(i))) {
        for(local j = 0; j < this.towns[t].secIndustry.len(); ++j) {
            if(this.towns[t].secIndustry[j] == i) {
                k = j;
            }
        }
        if(k != -1) {
            Log.Info("Removing a secondary industry", 6);	
            this.towns[t].secIndustry.remove(k);
        }
    }

}


// Load the introduction dates up; any cargo that is introduced gets a date.

function CityBuilder::LoadIntroductionDates(){
local Havenot = GSList();
for(local i = 0; i < 32; ++i)
	Havenot.AddItem(i, i);
local Cargouse = GSList();
Cargouse.AddList(Havenot);
local Industries = GSIndustryList();
local Indlist = GSList();
local Cargoes = null;
local t = 0;
foreach(ind, _ in Industries) {
	t = GSIndustry.GetIndustryType(ind);
	if(!Indlist.HasItem(t))
		Indlist.AddItem(t, 0);
	}
foreach (type, _ in Indlist) {
		if(GSIndustryType.IsValidIndustryType(type))
		{
		Cargoes = GSIndustryType.GetProducedCargo(type);
		foreach(item, dummy in Havenot) 
			{
			if(Cargoes.HasItem(item))
				{
				Havenot.RemoveValue(item);
				if(Havenot.IsEmpty())
					break;
				}
			}
		}
	}
local Townlist = GSTownList();
foreach (town, _ in Townlist) {
   foreach (item, dummy in Havenot) {
      if(GSTown.GetLastMonthProduction(town, item) > 0) { 
			Havenot.RemoveValue(item);  
			if (Havenot.IsEmpty()) 
				break; 
			}
      }
   }
Cargouse.RemoveList(Havenot);
for(local i = 0; i < 32; ++i){
	if(Havenot.HasItem(i)){
		intro.append(GSController.GetSetting("introdelay"));		
		if(GSController.GetSetting("debug_level") > 2)
			GSLog.Info("Cargo " + i + " delayed");
		} else {
		intro.append(0);
		}
	}
}
// change the introduction dates.

function CityBuilder::ManageIntroductionDates(){
    local Havenot = GSList();
    for(local i = 0; i < 32; ++i) {
	    Havenot.AddItem(i, i);
	}
    local Cargouse = GSList();
    Cargouse.AddList(Havenot);
    local Industries = GSIndustryList();
    local Indlist = GSList();
    local Cargoes = null;
    local t = 0;
    foreach(ind, _ in Industries) {
	    t = GSIndustry.GetIndustryType(ind);
	    if(!Indlist.HasItem(t)) {
		    Indlist.AddItem(t, 0);
	    }
	}
    foreach (type, _ in Indlist) {
		if(GSIndustryType.IsValidIndustryType(type)) {
		    Cargoes = GSIndustryType.GetProducedCargo(type);
		    foreach(item, dummy in Havenot) {
			    if(Cargoes.HasItem(item)) {
				    Havenot.RemoveValue(item);
				    if(Havenot.IsEmpty()) {
					    break;
				    }
				}
			}
		}
    }
    local Townlist = GSTownList();
    foreach (town, _ in Townlist) {
        foreach (item, dummy in Havenot) {
            if(GSTown.GetLastMonthProduction(town, item) > 0) { 
			    Havenot.RemoveValue(item);  
			    if (Havenot.IsEmpty()) {
				    break; 
				}
			}
        }
    }
    Cargouse.RemoveList(Havenot);
    // TODO: News about cargo introductions.
}
