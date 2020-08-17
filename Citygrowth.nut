
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
require("Place.nut");

 
 function _min_size__(){return GSController.GetSetting("min_size_max_growth");}
  //////////////////////////////////////////////////// 
  // Contributors:
  ////////////////////////////////////////////////////
  class City extends Place{
  diff = 0;
  mult = 1.0;
  sign_id = -1;
  transport_pct = 0;
  mode = 0;
  constructor(town_id) {
	::Place.constructor(town_id);
	this.mode = this.cities_setting;
	if(mode == 2){this.mult *= ((GSBase.RandRange(10000).tofloat()) / 5000.0 + 1.0);}
	mult *= (GSController.GetSetting("city_cgg").tofloat()) / 1000.0;
	if(mode > 0){DisableDefaultGoals();}
 }
  
  function SetGrowthRate();
  function Manage();
  function SetRate();
  function DoSigns();
  function SetSigns();
  function GetPop();
  function Set(new_id, new_mult, new_sign_id, new_start_population);
  function _typeof();
  }
function City::_typeof(){return "City";}
  
function City::Set(new_id, new_mult, new_sign_id, new_start_population){
id = new_id;
mult = new_mult;
sign_id = new_sign_id;
start_population = new_start_population;
}
  
function City::GetPop(){
return pop;}
  
function City::Manage() {
	if(mode == 1 || mode == 2) {
		SetGrowthRate();
		DoSigns();
	}
	ApplyGrowth();
}

function City::SetRate() {
	if(mode == 1 || mode == 2) {
		GSTown.SetGrowthRate(id, 30996);
	}
	pop = GSTown.GetPopulation(id);	
}
  
function City::SetGrowthRate(){
	// if regrowth is on:
	this.transport_pct = GSTown.GetLastMonthTransportedPercentage(this.id,this.paxcargo);
	local num_houses = GSTown.GetHouseCount(this.id);
	if(this.regrow > 100) {
		if(pop < start_population) {		
			this.is_growing = 3;
			this.growthRate = this.slow_factor * 1000.0 /  (this.mult * max(this.pop, _min_size__()).tofloat());
			return;
		}
	}
	if( transport_pct < req && this.pop > this.tsize) {
	// don't grow at all.
	this.is_growing = 0;
	this.growthRate = 0;
	} else {
  // grow at full speed.
		this.is_growing = 3;
		this.growthRate = this.slow_factor * 1000.0 /  (this.mult * max(this.pop, _min_size__()).tofloat());
	}
}

function City::DoSigns(){
	switch(mode) {
		case(1): // MTR
			SetSigns();
			break;
		case(2): // MTR, Random
			SetSigns();
			break;
		default:
			break;
	}
}

function City::SetSigns(){
// add a desc to the town window with the actual percentage.
	if(!is_growing) {
		GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CITY_NOGROW, transport_pct, req, 1<<paxcargo));
	} else {
		GSTown.SetText(id, GSText(GSText.STR_CITYBUILDER_CITY_GROW, transport_pct, req, 1<<paxcargo));
	}
}
