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
  
  // a clockwise diagonal walker that starts going up. 
  // TODO: make starting direction variable without significantly increasing #ops.
class DiagonalWalker{
	start = 0;
	tile = 0;
	tileX = 0;
	tileY = 0;
	steps = 0;
	steps_per_direction = 1;
	num_dir_changes = 0;
	currentDirection = 0;
  
	constructor(start_tile)
	{
		// test
		tile = start_tile;
		tileX = GSMap.GetTileX(tile);
		tileY = GSMap.GetTileY(tile);
		start = start_tile;
	}
	
	function Walk(MAX = 2048, nW = 0);
	function Reset(tl = -1);
	function GetCurrentTile();
	function GetNumberOfSteps();
}
function DiagonalWalker::Reset(tl)
{
	tile = tl == -1 ? start : tl;
	tileX = GSMap.GetTileX(tile);
	tileY = GSMap.GetTileY(tile);
	steps = 0;
	steps_per_direction = 1;
	num_dir_changes = 0;
	currentDirection = 0;
}
  
function DiagonalWalker::GetNumberOfSteps()
{
	return this.steps;
}

function DiagonalWalker::GetCurrentTile()
{
	return this.tile;
}

  // Walk
  // Walk one tile with our walker.
  // Returns true when it can find a tile, false when it cannot. 
  // Will by default try a total of 2048 attempts.
function DiagonalWalker::Walk(MAX = 2048, nW = 0)
{
	do
	{
	  // compute the direction to walk in.
		switch(this.currentDirection)
		// walk in that direction
		{
			case(0):
			// up
				tileY--;			
				break;
			case(1):
			// down-right
				tileY++;
				tileX++;
				break;
			case(2):
			// down-left
				tileY++;
				tileX--;
				break;
			case(3):
			// up-left
				tileY--;
				tileX--;
				break;			
			case(4):
			// up-right 
				tileY--;
				tileX++;
				break;
		}
		tile = GSMap.GetTileIndex(tileX, tileY);
		nW++;
		// increase step counter
		steps++;
		steps_per_direction--;
		if(steps_per_direction <= 0)
		{
		// change direction
			num_dir_changes++;
			currentDirection++;
			currentDirection %= 5;
			// case 0
			if(currentDirection)
			{
				steps_per_direction = ceil(num_dir_changes / 5);
			}
			else
			{
				steps_per_direction = 1;
			}
		}
	}
	// are we outside the map?
	while(!GSMap.IsValidTile(tile));	
	if(nW > MAX) return false;
	else
	{
		return tile;	
	}
}
  
  
  