
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
  
require ("Towngrowth.nut")

class Industry{
id = 0;
my_town = 0;
constructor(industry_id,mytown){
this.id = industry_id;
this.my_town = mytown.weakref();
	}
	
function AddCargo();
function SetTown(newtown);
}
function SpawnExtraTowns();
function CreateExtraTownIndustry();
function TryToBuildIndustry(type, location);
function GetRandomTileInRB(X, Y, D);

function Industry::AddCargo(){
// ask the manager function the cargo, give it to the town!
local j;
		for(local i = 0; i < 32; i++){
			for (local cid = GSCompany.COMPANY_FIRST; cid < GSCompany.COMPANY_LAST; cid++)
			{
				if (GSCompany.ResolveCompanyID(cid) != GSCompany.COMPANY_INVALID)
					{
				j = GSCargoMonitor.GetIndustryDeliveryAmount(cid, i, this.id,true)
				my_town.AddAdvancedCargo(j,i);
		}}}}

function Industry::SetTown(newtown){
this.my_town = newtown.weakref();}

function SpawnExtraTowns() {
    local TownDensity = GSController.GetSetting("Town_Density");
    local X = GSMap.GetMapSizeX() * GSMap.GetMapSizeY() / TownDensity;
    towns = GSTownList();
    local n = X - towns.Count();
	GSLog.Info("I will spawn "+n+" more towns");
    local attempts = 0;
    local cityChance = GSGameSettings.GetValue("economy.larger_towns");
    if(cityChance == 0) {
        cityChance = 2147483647;
    }
    while(n > 0 && attempts < 1000000) {
        local isCity = GSBase.Rand() % cityChance == 0 ? true : false;
        local size = 0;
        if(isCity) {
            if(GSBase.Rand() % 3 == 0) {
                size = GSTown.TOWN_SIZE_LARGE;
            } else {
                size = GSTown.TOWN_SIZE_MEDIUM;
            }
        } else {
            size = GSTown.TOWN_SIZE_SMALL;
        }
        local layout = 0;
        switch(GSBase.Rand() % 4) {
            case(0):
                layout = GSTown.ROAD_LAYOUT_ORIGINAL;
                break;
            case(0):
                layout = GSTown.ROAD_LAYOUT_BETTER_ROADS;
                break;
            case(0):
                layout = GSTown.ROAD_LAYOUT_2x2;
                break;
            case(0):
                layout = GSTown.ROAD_LAYOUT_3x3;
                break;
        }
        local tx = GSBase.Rand() % GSMap.GetMapSizeX();
        local ty = GSBase.Rand() % GSMap.GetMapSizeY();
        local randomTile = GSMap.GetTileIndex(tx, ty);
        if(GSTown.FoundTown(randomTile, size, isCity, layout, null)) {
            --n;
        }
        ++attempts;
    }
    
    
}


function CreateExtraIndustry(){
if(GSController.GetSetting("debug_level") > 0)
	GSLog.Info("I will spawn some more primary industry");
 local industries = null;
 local fromLoad = false;
 local buildonwater = GSController.GetSetting("Industry_Water");
 // DENSITY PARAMETER. LOWER = MORE INDUSTRIES
 local Density = GSController.GetSetting("Industry_Density");
 if(Density != 63){
 local IndustryTypeList = GSIndustryTypeList();	
	
local OldConstr = GSGameSettings.GetValue("construction.raw_industry_construction");
GSGameSettings.SetValue("construction.raw_industry_construction", 2);
// get industry list
industries = GSIndustryList();
industries.Sort(GSList.SORT_BY_ITEM, true);
local IndustryDensity = Density;
// Determine the map size
local X = GSMap.GetMapSizeX() * GSMap.GetMapSizeY() / IndustryDensity;
local j = 0; 
foreach(ind in industries){if(GSIndustryType.IsRawIndustry(GSIndustry.GetIndustryType(ind))) j++; }
local j_old = j;
local n = 0;
local types = [];
local CPY = false;
GSCompanyMode(0);
// Loop through the industry type list.
// Can we prospect anything at all? (if not, just do nothing)
if(IndustryTypeList.IsEmpty()==false)
	{
	foreach(i, _ in IndustryTypeList)
		{
		if(GSIndustryType.CanProspectIndustry(i) && GSIndustryType.IsRawIndustry(i) && (buildonwater || !GSIndustryType.IsBuiltOnWater(i)))
			{
				CPY = true;
				types.append(i);
				if(GSController.GetSetting("debug_level") > 2)
					Log.Info("type found: " + GSIndustryType.GetName(i), Log.LVL_INFO);
			}
		}
	}
if(CPY)
	{
if(GSController.GetSetting("debug_level") > 0)
	GSLog.Info("Prospecting available");
// Loop through majorly
	while(j < X)
		{
			n++;
// Loop through the industry type list.
// Can we prospect this industry?
// Can we not build this industry with prospecting mode? This captures all processing industries and lumber mills.
// Prospect one of these industries!
		foreach(type in types)
			{ 
			if(GSIndustryType.ProspectIndustry(type))	
			j++;
			if(j>=X) break;
			}
// if we wind up in an infinite loop here, quit out of it.
		if(n > 1000000)
			{
			Log.Error("Prospecting failed.", Log.LVL_INFO);
			break;
			}				
		}
		if(GSController.GetSetting("debug_level") > 2)
			GSLog.Info("Prospected number of industries: "+(j - j_old).tostring());	

	}
	else
	{GSLog.Info("No Industry Types Exist. Aborting"); j = X;}
// Now set industry method back.	
GSGameSettings.SetValue("construction.raw_industry_construction", OldConstr);

}
}


function CreateExtraSecondaryIndustry(){
if(GSController.GetSetting("debug_level") > 1)
	GSLog.Info("I will spawn some more secondary industry");
 local industries = null;
 local fromLoad = false;
 local buildonwater = GSController.GetSetting("Industry_Water");
 // DENSITY PARAMETER. LOWER = MORE INDUSTRIES
 local Density = GSController.GetSetting("Industry_S_Density");
 if(Density != 63){
 local IndustryTypeList = GSIndustryTypeList();	
	
local OldConstr = GSGameSettings.GetValue("construction.raw_industry_construction");
GSGameSettings.SetValue("construction.raw_industry_construction", 2);
// get industry list
industries = GSIndustryList();
local j = 0; 
foreach(ind in industries){if(!GSIndustryType.IsRawIndustry(GSIndustry.GetIndustryType(ind)) &&  !(GSIndustryType.GetProducedCargo(GSIndustry.GetIndustryType(ind))).IsEmpty()) j++; }
industries.Sort(GSList.SORT_BY_ITEM, true);
local IndustryDensity = Density;
// Determine the map size
local X = GSMap.GetMapSizeX() * GSMap.GetMapSizeY() / IndustryDensity;
local j_old = j;
local n = 0;
local types = [];
local CPY = false;
GSCompanyMode(0);
// Loop through the industry type list.
// Can we prospect anything at all? (if not, just do nothing)
if(IndustryTypeList.IsEmpty()==false){
for(local i = 0; i < 64; i++){
	// Do only those types that are not primary and produce 'something'. 
	if(GSIndustryType.CanProspectIndustry(i) && !GSIndustryType.IsRawIndustry(i) && (buildonwater || !GSIndustryType.IsBuiltOnWater(i))  &&  !(GSIndustryType.GetProducedCargo(i)).IsEmpty()){
		CPY = true;
		types.append(i);
		if(GSController.GetSetting("debug_level") > 2)
			Log.Info("type found: " + GSIndustryType.GetName(i), Log.LVL_INFO);
			}
		}
	}
if(CPY)
	{
	GSLog.Info("Prospecting Secondaries available");
// Loop through majorly
	while(j < X)
		{
			n++;
// Loop through the industry type list.
// Can we prospect this industry?
// Can we not build this industry with prospecting mode? This captures all processing industries and lumber mills.
// Prospect one of these industries!
		foreach(type in types)
			{ 
			if(GSIndustryType.ProspectIndustry(type))
			j++;
			}
// if we wind up in an infinite loop here, quit out of it.
		if(n > 1000000)
			{
			Log.Error("Prospecting failed.", Log.LVL_INFO);
			break;
			}				
		}		
		if(GSController.GetSetting("debug_level") > 2)
			GSLog.Info("Prospected number of industries: "+(j - j_old).tostring());	

	}
	else
	{GSLog.Info("No Industry Types Exist. Aborting"); j = X;}
// Now set industry method back.	
GSGameSettings.SetValue("construction.raw_industry_construction", OldConstr);

}
}



function CreateExtraTownIndustry(){
Log.Info("Creating Town-based Industries", Log.LVL_INFO);
local p = GSController.GetSetting("Industry_Town");
local itlist = GSIndustryTypeList();
local itypes = [];
foreach(type, _ in itlist)
	{
	if(GSIndustryType.IsValidIndustryType(type))
		{
		if((!GSIndustryType.IsBuiltOnWater(type)) && (GSIndustryType.GetProducedCargo(type)).IsEmpty() || GSController.GetSetting("paxcargo_istownind") && GSIndustryType.GetProducedCargo(type).HasItem(GSController.GetSetting("metro_cargo")))
			{
			Log.Info("type found: " + GSIndustryType.GetName(type), Log.LVL_INFO);
			itypes.append(type);
			}
		}
	}

local townlist = GSTownList();
local ind_unique = GSGameSettings.GetValue("economy.multiple_industry_per_town")
GSGameSettings.SetValue("economy.multiple_industry_per_town", 0);
local try_var;
foreach(t, _ in townlist)
	{
	foreach(itype in itypes)
		{
		if((GSBase.Chance(p,1000) || p == 1000) && GSIndustryType.CanBuildIndustry(itype))
			{
			try_var = TryToBuildIndustry(itype, GSTown.GetLocation(t));
			//if(!try_var) Log.Info("Failed to build " + GSIndustryType.GetName(itype) + " in " + GSTown.GetName(t), Log.LVL_INFO);
			//else Log.Info("Built " + GSIndustryType.GetName(itype) + " in " + GSTown.GetName(t), Log.LVL_INFO);
			}
		}
	}
	
GSGameSettings.SetValue("economy.multiple_industry_per_town", ind_unique);
return;
}

function TryToBuildIndustry(type, location){
// try to build an industry in the town
local success = false;
local X = GSMap.GetTileX(location);
local Y = GSMap.GetTileY(location);
local attempts = 0;
local rv;
local try_tile;
local Tiles_X = [];
local Tiles_Y = [];
// start at 12 tiles from the town center, move in slowly.
local range = 12;
while(range > 0 && !success)
	{
// append tiles in this range.
	Tiles_X = [];
	Tiles_Y = [];
	for(local i = 0; i < range * 2; ++i)
		{
		Tiles_X.append(X-range);
		Tiles_X.append(X-range+i);	
		Tiles_X.append(X-range+i+1);
		Tiles_X.append(X+range);
		Tiles_Y.append(Y-range+i);
		Tiles_Y.append(Y+range);
		Tiles_Y.append(Y-range);
		Tiles_Y.append(Y-range+i+1);
		}
	local attempts = 0;
	while(attempts < 8 * range  && !success)
		{
// get a random tile from the array.
		rv = GSBase.RandRange(Tiles_X.len());
		try_tile = GSMap.GetTileIndex(Tiles_X[rv], Tiles_Y[rv]);
		Tiles_X.remove(rv);
		Tiles_Y.remove(rv);
		success = GSIndustryType.BuildIndustry(type, try_tile);
		//GSLog.Info("tried to build industry at: " + try_tile);
		attempts++;
		}
	range--;
	}
return success;
}

function GetRandomTileInRB(X, Y, D)
{
	// get a random tile on the square boundary at distance D from [X,Y]. 
	// the square has a total of 8D tiles.
	local nX;
	local nY;
	local tkey = GSBase.RandRange(8*D);
	// take tkey mod 4 as the side. 
	switch(tkey%4)
	{
		case(0): nX = X - D + tkey/4; nY = Y - D; break;
		case(1): nX = X - D + tkey/4; nY = Y + D; break;
		case(2): nY = Y - D + tkey/4; nX = Y - D; break;
		case(3): nY = Y - D + tkey/4; nX = Y + D; break;
	}
	return GSMap.GetTileIndex(nX, nY);
}
