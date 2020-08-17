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
  
  
require("QSort.nut");

class Demand_Sizes{
da = [];
size_reqs = [];
cargo_promilles = [];
cargo_introduced = [];
nums = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
constructor(intr){
cargo_introduced = intr;
size_reqs = [
GSController.GetSetting("size0"),
GSController.GetSetting("size1"),
GSController.GetSetting("size2"),
GSController.GetSetting("size3"),
GSController.GetSetting("size4"),
GSController.GetSetting("size5"),
GSController.GetSetting("size6"),
GSController.GetSetting("size7"),

GSController.GetSetting("size8"),
GSController.GetSetting("size9"),
GSController.GetSetting("size10"),
GSController.GetSetting("size11"),
GSController.GetSetting("size12"),
GSController.GetSetting("size13"),
GSController.GetSetting("size14"),
GSController.GetSetting("size15"),

GSController.GetSetting("size16"),
GSController.GetSetting("size17"),
GSController.GetSetting("size18"),
GSController.GetSetting("size19"),
GSController.GetSetting("size20"),
GSController.GetSetting("size21"),
GSController.GetSetting("size22"),
GSController.GetSetting("size23"),

GSController.GetSetting("size24"),
GSController.GetSetting("size25"),
GSController.GetSetting("size26"),
GSController.GetSetting("size27"),
GSController.GetSetting("size28"),
GSController.GetSetting("size29"),
GSController.GetSetting("size30"),
GSController.GetSetting("size31")];

cargo_promilles = [
GSController.GetSetting("cargo0"),
GSController.GetSetting("cargo1"),
GSController.GetSetting("cargo2"),
GSController.GetSetting("cargo3"),
GSController.GetSetting("cargo4"),
GSController.GetSetting("cargo5"),
GSController.GetSetting("cargo6"),
GSController.GetSetting("cargo7"),
                                  
GSController.GetSetting("cargo8"),
GSController.GetSetting("cargo9"),
GSController.GetSetting("cargo10"),
GSController.GetSetting("cargo11"),
GSController.GetSetting("cargo12"),
GSController.GetSetting("cargo13"),
GSController.GetSetting("cargo14"),
GSController.GetSetting("cargo15"),
                                  
GSController.GetSetting("cargo16"),
GSController.GetSetting("cargo17"),
GSController.GetSetting("cargo18"),
GSController.GetSetting("cargo19"),
GSController.GetSetting("cargo20"),
GSController.GetSetting("cargo21"),
GSController.GetSetting("cargo22"),
GSController.GetSetting("cargo23"),
                                  
GSController.GetSetting("cargo24"),
GSController.GetSetting("cargo25"),
GSController.GetSetting("cargo26"),
GSController.GetSetting("cargo27"),
GSController.GetSetting("cargo28"),
GSController.GetSetting("cargo29"),
GSController.GetSetting("cargo30"),
GSController.GetSetting("cargo31")
];
}

function Setup();
function Get_Next_Demand(X);
}

function Demand_Sizes::Setup(){
// fix non-required cargoes from showing up!
for(local i = 0; i < 32; ++i)
	{
	if(cargo_promilles[i] == 0) size_reqs[i] = 0;
	}

// setup the demand sizes.
da = QSort(size_reqs,nums);
}

function Demand_Sizes::Get_Amount(id) {
	return size_reqs[id];
}

function Demand_Sizes::Get_Next_Demand(X){
local i = 0;
while((X >= size_reqs[da[i%da.len()]] && i < da.len()) || (cargo_introduced[da[i%da.len()]] > 0 && i < da.len())){ ///< Clever tricks here. 
	++i;
	}
	if(i >= da.len()){return -1;}
	else{
	return da[i];
	}
}