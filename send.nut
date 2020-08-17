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
 
  // Contributors: XfrankX, Aphid
  
  
  // This sends a message to the admin. 
  // Multiplayer servers can use this for databases (highscores etc.)
  // They can also use this to inform their users via chat by relaying the message, stripping formatting.
  // Only works in multiplayer
  
function SendAdmin(message)
{
if(GSGame.IsMultiplayer()){
	local T = {CBMSG = message};
	if(!GSAdmin.Send(T))
		{
		GSLog.Error("Error sending message to admin interface!");
		}
	}
}
