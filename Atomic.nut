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

function Atomic(n){
if(n > GSController.GetOpsTillSuspend () + 1){GSController.Sleep(1);}
// Uncomment this to test if it works (spammy!)
//Log.Info("OPS: "+GSController.GetOpsTillSuspend (), Log.LVL_INFO);
}