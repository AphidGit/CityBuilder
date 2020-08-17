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
    // house list for a town. 
	
require("DiagonalWalker.nut");
class XHouseList{
	centerTile = 0;
	tid = 0;
	walker = null;
	hlist = null;	
	constructor(townID)
	{
		tid = townID;
		centerTile = GSTown.GetLocation(townID);
		walker = DiagonalWalker(centerTile);
	}
	
	function Populate(n = 16777215, max = 100000);
	function GetList();
	function RemoveHouses(x);	

}
function XHouseList::Populate(n = 16777215, max = 100000)
{		
	// limit populating to the house count.
	local houseCount = GSTown.GetHouseCount(tid);
	n = min(max, houseCount);
	walker.Reset(-1);
	hlist = GSTileList();
	local i = 0; 
	local count = 0;
	local curTile = centerTile;
	local CARGO_PAXID = GSController.GetSetting("metro_cargo");
	while(i++ < max && count < n)
	{
		// is there a house on the current tile?
		// house tiles have to be in the town authority
		// house tiles are buildable
		// house tiles have no owner
		if(GSTile.GetTownAuthority(curTile) == this.tid 
				&& GSTile.IsBuildable(curTile) == true
				&& GSTile.GetOwner(curTile) == -1)
		{
			if(GSTile.GetCargoAcceptance(curTile, CARGO_PAXID,1,1,0) > 0)
			{
				if(GSIndustry.GetIndustryID(curTile) == 65535)
				{
				// we found a house.
					count++;
					hlist.AddTile(curTile);	
				}						
			}
		}
		curTile = walker.Walk();
	}		
}
function XHouseList::GetList()
{
	return this.hlist;
}

function XHouseList::RemoveHouses(x)
{
	local u = 0;
	this.Populate(x);
	foreach(tl, _ in this.hlist)
	{
		if(GSController.GetSetting("debug_level") > 5)
		{
			GSLog.Info("Try to Remove house at X->"+GSMap.GetTileX(tl)+" , Y->"+GSMap.GetTileY(tl));		
		}
		if(GSTile.DemolishTile(tl))
		{
			if(GSController.GetSetting("debug_level") > 5)
			{
				GSLog.Info("Successfully removed this house!");		
			}
			u++;
		}
	}	
	return u;
}
