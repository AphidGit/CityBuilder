

// Note: This is a simplification of Road Pathfinder V4 
// It only navigates existing roads!
// It tries to avoid tunnels, bridges for CB purposes.

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

class RPF{

_aystar = import("graph.aystar", "", 6);
// PRIVATE
function _Cost(self, path, new_tile, new_direction);
function _Estimate(tile, direction, goal_nodes, estimate_callback_param);
function _Neighbours(self, path, cur_node);
function _CheckDirection(self, tile, existing_direction, new_direction);
function GetDirection(from, to, is_bridge);
function CheckTunnelBridge(current_tile, new_tile);
	max_cost = 65535;   ///< Maximum route costs we're willing to accept.
	bridge_cost = 10;  ///< The cost per tile of a new bridge, this is added to 1.
	tunnel_cost = 10;  ///< The cost per tile of a new tunnel, this is added to 1.
	_running = null;
	_pathfinder = null;
constructor(){
this._pathfinder = this._aystar(this, this._Cost, this._Estimate, this._Neighbours, this._CheckDirection);
	this._running = false;
	this.bridge_cost = 10;
	this.tunnel_cost = 10;
	this.max_cost = 65535;
}
// PUBLIC
	/**
	 * Initialize a path search between sources and goals.
	 * @param sources The source tiles.
	 * @param goals The target tiles.
	 * @see AyStar::InitializePath()
	 */
	function InitializePath(sources, goals) {
		local nsources = [];

		foreach (node in sources) {
			nsources.push([node, 0xFF]);
		}
		this._pathfinder.InitializePath(nsources, goals);
	}
	
	/**
	 * Try to find the path as indicated with InitializePath with the lowest cost.
	 * @param iterations After how many iterations it should abort for a moment.
	 *  This value should either be -1 for infinite, or > 0. Any other value
	 *  aborts immediatly and will never find a path.
	 * @return A route if one was found, or false if the amount of iterations was
	 *  reached, or null if no path was found.
	 *  You can call this function over and over as long as it returns false,
	 *  which is an indication it is not yet done looking for a route.
	 */
	function FindPath(iterations);
}


function RPF::FindPath(iterations)
{
	local ret = this._pathfinder.FindPath(iterations);
	this._running = (ret == false) ? true : false;
	return ret;
}

function RPF::_Cost(self, path,new_tile,new_dir){
	local bridge_cost = 10;
	/* path == null means this is the first node of a path, so the cost is 0. */
	if (path == null) return 0;
	local prev_tile = path.GetTile();
	/* If the new tile is a bridge / tunnel tile, check whether we came from the other
	 * end of the bridge / tunnel or if we just entered the bridge / tunnel. */
	if (GSBridge.IsBridgeTile(new_tile)) {
		if (GSBridge.GetOtherBridgeEnd(new_tile) != prev_tile) return path.GetCost() + bridge_cost;
		return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * bridge_cost;
	}
	if (GSTunnel.IsTunnelTile(new_tile)) {
		if (GSTunnel.GetOtherTunnelEnd(new_tile) != prev_tile) return path.GetCost() + this.tunnel_cost;
		return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * this.tunnel_cost;
	}
	
// Costs of moving in any direction is always 1.	
return 1;	
}
// Simple manhattan distance estimate.
function RPF::_Estimate(self, cur_tile, cur_direction, goal_tiles)
{
	local min_cost = self.max_cost;
foreach (tile in goal_tiles) {
		min_cost = min(GSMap.DistanceManhattan(cur_tile, tile) , min_cost);
	}
	return min_cost;
}
function RPF::_Neighbours(self, path, cur_node)
{
	/* self._max_cost is the maximum path cost, if we go over it, the path isn't valid. */
	if (path.GetCost() >= self.max_cost) return [];
	local tiles = [];

	/* Check if the current tile is part of a bridge or tunnel. */
	if ((GSBridge.IsBridgeTile(cur_node) || GSTunnel.IsTunnelTile(cur_node)) &&
	     GSTile.HasTransportType(cur_node, GSTile.TRANSPORT_ROAD)) {
		local other_end = GSBridge.IsBridgeTile(cur_node) ? GSBridge.GetOtherBridgeEnd(cur_node) : GSTunnel.GetOtherTunnelEnd(cur_node);
		local next_tile = cur_node + (cur_node - other_end) / GSMap.DistanceManhattan(cur_node, other_end);
		if (GSRoad.AreRoadTilesConnected(cur_node, next_tile)) {
			tiles.push([next_tile, self.GetDirection(cur_node, next_tile, false)]);
		}
		/* The other end of the bridge / tunnel is a neighbour. */
		tiles.push([other_end, self.GetDirection(next_tile, cur_node, true) << 4]);
	} else if (path.GetParent() != null && GSMap.DistanceManhattan(cur_node, path.GetParent().GetTile()) > 1) {
		local other_end = path.GetParent().GetTile();
		local next_tile = cur_node + (cur_node - other_end) / GSMap.DistanceManhattan(cur_node, other_end);
		if (GSRoad.AreRoadTilesConnected(cur_node, next_tile)) {
			tiles.push([next_tile, self.GetDirection(cur_node, next_tile, false)]);
		}
	} else {
		local offsets = [GSMap.GetTileIndex(0, 1), GSMap.GetTileIndex(0, -1),
		                 GSMap.GetTileIndex(1, 0), GSMap.GetTileIndex(-1, 0)];
		/* Check all tiles adjacent to the current tile. */
		foreach (offset in offsets) {
			local next_tile = cur_node + offset;
			/* We add them to the to the neighbours-list if one of the following applies:
			 * 1) There already is a connections between the current tile and the next tile.
			 * 2) We DONT add when we can build a road.
			 * 3) The next tile is the entrance of a tunnel / bridge in the correct direction. */
			if (GSRoad.AreRoadTilesConnected(cur_node, next_tile)) {
				tiles.push([next_tile, self.GetDirection(cur_node, next_tile, false)]);
			} else if (self.CheckTunnelBridge(cur_node, next_tile)) {
				tiles.push([next_tile, self.GetDirection(cur_node, next_tile, false)]);
			}
		}
		if (path.GetParent() != null) {
			local bridges = self.GetTunnelsBridges(path.GetParent().GetTile(), cur_node, self.GetDirection(path.GetParent().GetTile(), cur_node, true) << 4);
			foreach (tile in bridges) {
				tiles.push(tile);
			}
		}
	}
	return tiles;
}


function RPF::_CheckDirection(self, tile, existing_direction, new_direction)
{
	return false;
}

function RPF::GetDirection(from, to, is_bridge)
{
	if (!is_bridge && GSTile.GetSlope(to) == GSTile.SLOPE_FLAT) return 0xFF;
	if (from - to == 1) return 1;
	if (from - to == -1) return 2;
	if (from - to == GSMap.GetMapSizeX()) return 4;
	if (from - to == -GSMap.GetMapSizeX()) return 8;
}

function RPF::CheckTunnelBridge(current_tile, new_tile)
{
	if (!GSBridge.IsBridgeTile(new_tile) && !GSTunnel.IsTunnelTile(new_tile)) return false;
	local dir = new_tile - current_tile;
	local other_end = GSBridge.IsBridgeTile(new_tile) ? GSBridge.GetOtherBridgeEnd(new_tile) : GSTunnel.GetOtherTunnelEnd(new_tile);
	local dir2 = other_end - new_tile;
	if ((dir < 0 && dir2 > 0) || (dir > 0 && dir2 < 0)) return false;
	dir = abs(dir);
	dir2 = abs(dir2);
	if ((dir >= GSMap.GetMapSizeX() && dir2 < GSMap.GetMapSizeX()) ||
	    (dir < GSMap.GetMapSizeX() && dir2 >= GSMap.GetMapSizeX())) return false;
	return true;
}


