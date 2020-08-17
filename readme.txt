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
 
 //////////////////////////////////////////////////////////////////////////////
// 0: INDEX
//////////////////////////////////////////////////////////////////////////
 1 NOTES
 2 QUICKSTART
 3 SERVER SETUP
 4 SETTINGS
 5 TESTING
 //////////////////////////////////////////////////////////////////////////////
// 1: NOTES
//////////////////////////////////////////////////////////////////////////
 
 Please read this file before playing citybuilder. It contains all documentation.
 Because citybuilder is a fairly complicated script, it also has a great deal 
 of customizability.
 Under the default settings, it does not work correctly with a newGRF-less 
 game. This is intentional.
 
 This is the Release version of CB script. The version numbering will match
 the beta version number that gets released. This release requires openTTD 
 1.4.0 or nightly 26156 or newer. It may work on older nightly releases, 
 but this is not guaranteed or tested.
 
//////////////////////////////////////////////////////////////////////////////
// 2: QUICKSTART
//////////////////////////////////////////////////////////////////////////
 
 To set up a game quickly, follow the following procedure.
 - Set your game difficulty to 'custom'.
 - Set the script settings to default.
 - Decide which landscape to use.
 - Create a map with one town and zero industries (funding only). 
 Note that all cargoes can be used. However, to get a town to store a cargo 
 houses do not accept, like with coal, you must build a power plant within the 
 town's authority field (or another industry that accepts it). 
 An industry that is not within the town's authority field, but becomes 
 part of that town's authority due to expansion does NOT count towards 
 citybuilder's town goals. This is a deliberate design choice for optimization.
  
//////////////////////////////////////////////////////////////////////////////
// 3: SERVER SETUP
//////////////////////////////////////////////////////////////////////////
  
 Multiplayer servers will have their own framework built up in most cases. This script
 can integrate with your framework rather easily. If you are already using a gamescript, 
 please first follow the following procedure:

1) Rename "main.nut" into "CityBuilder.nut"
2) include "CityBuilder.nut" in your "main.nut"
3) Add the options in the "info.nut" to your own "info.nut", and discard this one. 
4) During your start function, create a 'CityBuilder' object. 
5) Call CityBuilder.Start_Lib() in your main's start function.
6) Call CityBuilder.Manage() in your main loop. Make sure this is called at least
	once every game day or the script may not work as intended.
7) If you have a game that ends and you want to sync with Citybuilder, check 
	CityBuilder.go for true/false. If it is false the game has ended.
	It is freely accessible so you can end the game manually as well. 
8) Optional: If you are already using a versioning scheme, merge
	the two versions into one version.nut manually. Please do this, for it will 
	help support the content download service quality.

Optionally, you can follow the following steps to ensure that you get access
to CityBuilder's messages to the user for the server. For example, to 
broadcast them over IRC.

9) Include "SendStats.nut" in whatever file you use to broadcast. 
10) Choose whether to use the GSText (continue in step 12), or plaintext (step 9). 
11) Create your own chat function f1 that accepts a company ID and a string.
12) Create a function f2 that returns a cargo suffix for SS.
13) Call SendStatistics(i,f1,f2) with your own chat function. Proceed with step 14.
14) Create your own chat function f that accepts a company ID and a GSText object.
15) Call SendStatisticsGS(i,f) with your own chat function.
16) Resolve any variable name conflicts and related bugs. 
17) Optional: Turn off the default town news messages (see 4: SETTINGS).
18) Done!

If you are not using a gamescript, you can of course write a wrapper to gain the benefits
of SendStats anyway. 
  
///////////////////////////////////////////////////////////////////////////////
// 4: SETTINGS
///////////////////////////////////////////////////////////////////////////////
Setting name: Short version of setting name.
Setting Range: What you can set it to.
Comments: Necessary information.
///////////////////////////////////////////////////////////////////////////////
Setting Name: Debug level
Setting Range: 0-7. The higher you set this, the more diagnostic messages the 
script will output about what it's doing. This uses up system resources, so 
the recommended setting for normal play is 0. 
-------------------------------------------------------------------------------
Setting Name: Point to goal GUI if goals > 3
Setting Range: No/Yes. If turned on the town GUI window will point users to the
goal GUI window if both are available for a town and a fourth goal exists.
-------------------------------------------------------------------------------
Setting Name: Show owner above town name
Setting Range: On/Off
Comments: Adds labels above town name with it's owner. Off by default. Recommend
turning this on for multiplayer games, especially with novice players.
-------------------------------------------------------------------------------
Setting Name: Amt. of tiles per town
Setting Range: 0-65,536
Comments: Set to 0 for no extra towns. The script will spawn extra towns until 
the amt/tiles per town is the specified amount. Non-cities generated in this 
way will always be small towns. 
-------------------------------------------------------------------------------
Setting Name: Amt. of tiles per primary industry
Setting Range: 63-65,536
Comments: Set to 63 for no extra industry. The script will spawn extra primary 
industry until the amt/tiles per industry is the specified amount.
If your Industry GRF contains raw industries that don't spawn by default at 
game start, also set to 63!
-------------------------------------------------------------------------------
Setting Name: Amt. of tiles per secondary industry
Setting Range: 63-65,536
Comments: Set to 63 for no extra industry. The script will spawn extra nonprimary
industry until the amt/tiles per industry is the specified amount.
If your Industry GRF contains nonraw industries that don't spawn by default at 
game start, also set to 63!
-------------------------------------------------------------------------------
Setting Name: Chance of building industry in a town at game start: 
Setting Range: Nil, 1-999, Everything
Comments: Of all industry types, Any types that do NOT create cargo but DO accept
 cargo are deemed town industry types, provided they are not water-based. A town
 will, at the start of the game, try to build one of each of these types, with 
 probability defined by this setting. Thus, at 1,000, each town would try to build 
 a water tower in the normal desert climate. At 500, about half the towns would
have water towers, and about 1/4 both water towers and banks. 
---------------------------------------------------------------------------------
Setting Name: Game Length in years
Setting Range: 0-4,000
Comments: Set to 0 for an infinite game. Set to a finite number for a goal game.
A 12-year game lasts about 3 hours. 
-------------------------------------------------------------------------------
Setting Name: Goal Target
Setting Range: 0-10,000,000 in steps of 500
Comments: Set to 0 for no target. Otherwise, the game ends as soon as a company
hits this target.
-------------------------------------------------------------------------------
Setting Name: Game Type
Setting Range: Freebuilder, Citybuilder, Co-op, Metropolis.
Comments: In freebuilder, companies are free to do whatever, it's merely town be-
haviour that the script affects. Citybuilder is the regular mode, companies claim
a town and grow it. In Co-op all companies work together to get the biggest world
population. In metropolis, all companies work together to grow a random town as 
high as possible. This town will demand high amounts of mail, yet give 
large amounts of passengers. 
-------------------------------------------------------------------------------
Setting Name: Maximum HQ Distance to claim town
Setting Range: 5-32
Comments: The distance is manhattan. If you happen to place your HQ too far, 
you can 'move' the HQ closer by re-plopping it. A helpful warning message pops 
up when you do.
-------------------------------------------------------------------------------
Setting Name: Metropolis cargo multiplier
Setting Range: 1-500
Comments: Making the metropolis require less cargo makes for an interesting game.
Reminder: the metropolis demands you to transport x% of it's cargo!
-------------------------------------------------------------------------------
Setting Name: Metropolis growth multiplier
Setting Range: 1-500
Comments:  The metropolis should grow a little faster. 12x is recommended.
-------------------------------------------------------------------------------
Setting Name: Metropolis transport requirement (MTR)
Setting Range: 30-98%
Comments:  Recommended 65-75. Above 80 is really hard to keep up. 
Mostly because of vehicle ratings. Also used in city behaviour 2 and 3. Used 
by most economies to determine the 'self production fraction' added to the 
supply requirement for passengers and mail. 
-------------------------------------------------------------------------------
Setting name: Subtract local transported passengers.
Setting Range: On/Off
Comments: Turn this on to prevent local transportation from effectively 'counting' 
towards town growth. 
-------------------------------------------------------------------------------
Setting Name: Maximum population
Setting Range: 0-4000
Comments: Set to 0 for infinite. You can't claim towns above this size. 
Of course, an already claimed town, when it grows beyond this, stays claimed. 
Be careful when using this option not to move your HQ away from your town!
Recommend 200-400, depending on the town NewGRF used. 
-------------------------------------------------------------------------------
Setting Name: Unclaimed towns behave as cities.
Setting Range: On/Off
Comments: Can be changed in-game. WARNING: when turning this on make sure that
the Behaviour of Cities setting is not set to Behave like a town. Undefined
behaviour may occur otherwise. Weird things may happen.
-------------------------------------------------------------------------------
Setting Name: Below this population growth is linear
Setting Range: 50-40,000
Comments: Makes really small towns grow at a reasonable rate. Recommended values
are in the range 500-1,500. Default TTD behaviour is around 1,500-4,000.
-------------------------------------------------------------------------------
Below this population all towns grow:
Setting Range: 50-4,000
Comments: Setting this above the above setting may have weird effects. Recommended
to keep at least 100 in temperate and snow setting. Toyland and Desert at least 75.
This is to ensure your town gets to eventually accept passengers (and food in Desert).
-------------------------------------------------------------------------------
Setting Name: Town size at which town grows with one house per day in thousands
Setting Range: 10-1000
Comments: This is a factor in growth speed. Set it twice as high to make towns
grow twice as slow as normally. The recommended factor is 60. For a faster-paced
game, set this lower, and for a slower-paced game set it higher. This is a very
powerful setting, fine-tuning it for your setup is recommended. A setting of 40
means a town of 4,000 has a max growth speed of one house per ten days.
-------------------------------------------------------------------------------
Setting Name: Factor needed to assimilate
Setting Range: 0-1000
Comments: How much larger a town needs to be to absorb a smaller town. The smaller 
town will still have it's own demands, but any population in it counts towards
the score of the company that claimed the larger town. A town can only absorb
other towns that have the center square close enough to their own center square.
-------------------------------------------------------------------------------
Setting Name: Max Growth promillage
Setting Range: 0-65,535
Comments: Above this promillage above the goal, a town grows at full speed.
My recommended value is 500. 0 might behave weirdly.
-------------------------------------------------------------------------------
Setting Name: Town Warehouse Size (months)
Setting Range: 0-360
Comments: How many months' worth of cargo can the town's warehouses hold on top
of the base size? Set to 0 for infinite. 
Recommended values are about 4 for this. Infinite can work as well, as long as
there is at least some decay for all cargoes.
-------------------------------------------------------------------------------
Setting Name: Town Warehouse Size (minimum)
Setting Range: 1-2000
Comments: How many cargo can the town's warehouses hold as a minimum? Recommended
 value is about 200.
-------------------------------------------------------------------------------
Setting Name: Regrow Towns
Setting Range: 100-300
Comments: Regrow any towns when they are below their starting population when 
this setting is set above 100. To prevent towns constantly deleting and rebuilding
houses, towns will not shrink until they reach the indicated percentage of start
population. Set this setting higher when you have fast growth speeds. Otherwise,
110 to 140% will work well with most building sets.
-------------------------------------------------------------------------------
Setting Name: Behaviour of cities
Setting Range: normally / per metro req/ random / as towns (3 variations)
Comments: How do towns with the (city) marker grow? Set to normally for the classic
experience, or set to grow as towns for something new. Of course, in gamemode
citybuilder you usually can't claim them so it tends to mean they don't grow at all. 
The other two settings are best for citybuilder, to make cities grow when you
transport lots of passengers away from them. (MTR == Grow above metro transport
requirement setting). The last setting (6) works quite well too.
-------------------------------------------------------------------------------
Setting Name: City growth Multiplier promillage:
Setting Range: 1-65535
Comments: Set to 1,000 for no change. 2,000 is the default game value (cities
grow twice as fast). Has no effect when you set cities to grow 'normally'.\
-------------------------------------------------------------------------------
Setting Name: Enable Freeze
Setting Range: On/Off
Comments: Enables users to do injections. With this setting on, a user can
stop delivering passengers to their town and the town will not shrink from 
a cargo shortage. 
-------------------------------------------------------------------------------
Setting Name: Industries that produce passengers are Town Industries
Setting Range: On/Off
Comments: Any industry that produces passengers is regarded as a Town Industry, 
even if it is not a tertiary industry. Defaults to 'Off'
-------------------------------------------------------------------------------
Setting Name: Towns in the tropic require no water but more food
Setting Range: Yes/No
Comments: If you do not use NewGRF, setting this to YES allows you to grow
towns in the rainforest in the subtropic climate. Set this to NO only if you 
have a water tower or other building that can accept water that can be built
on rainforest tiles!
-------------------------------------------------------------------------------
Setting Name: Reduced shrink effect:
Setting Range: 0-1000
Comments: Hard to get a descriptive name for this setting since it's kind of weird.
When missing a new cargo (with maybe only one or two units required) by not 
delivering at all, the town won't shrink at full speed, but only a little. 
The higher the setting, the more lax the game is. I recommend a value of ~40 or so.
-------------------------------------------------------------------------------
Setting Name: Introduction Delay
Setting Range: 0 to 60
Comments: Set to 0 to turn automatic cargo introduction off. Warning: Doing this
will mean a town may require unknown cargoes, set up your cargo settings 
appropriately. This will manage the amount of years it takes before a cargo
is automatically introduced when a new industry type is introduced. 
-------------------------------------------------------------------------------
Setting Name: Cargo requirement multiplier
Setting Range: 100 to 5000
Comments: Multiply the cargo requirements in a pre-set economy with a fixed number.
-------------------------------------------------------------------------------
Setting Name: Introduction population multiplier
Setting Range: 250 to 5000
Comments: Modify for cargoes to be introduced faster or slower with a pre-set 
economy. Note that very low values may result in towns wanting goods they can't 
accept yet. 
-------------------------------------------------------------------------------
Setting Name: Use custom Economy
Setting Range: 0-1
Comments: If you use this setting, a 'custom' economy is used instead of the regular
economy. The multipliers above have no effect, instead the requirements are as 
specified with the options below this. 
-------------------------------------------------------------------------------
Setting Name: cargo #xx delivery requirement
Setting Range: 0-2,000
Comments: A town of 1,000 people would monthly require this much cargo delivered 
from it. Set to 0 for unused cargoes.
-------------------------------------------------------------------------------
Setting Name: cargo #xx supply requirement 
Setting Range: 0-2000
Comments: A town of 1,000 people would monthly require this much cargo supplied 
to it. It is recommended for regular citybuilder that you set a town's cargo 
requirements above it's own production values for passengers and similar cargoes. 
Set to 0 for unused cargoes. It is recommended to set the mail requirement low 
for good metropolis games. (just so high that the metropolis can't grow off 
it's own mail). For freebuilder and coop settings below the town's production 
up to slightly above are good choices.
-------------------------------------------------------------------------------
Setting Name: cargo #xx introduction population
Setting Range: 200-1,000,000
Comments: This is an important setting. It determines the flow of the game, 
especially in co-operative, and to a lesser extent freebuilder mode. Ideally, 
the values should be spread out for the different cargoes. My recommended setting
is a fibonacci distribution (200,300,500,...) for the different cargoes, leaving
out the first two numbers, or an exponential progression (200, 300, 450, 675, ...)
Luukland used to use 250,500,1000,1500,2500,4000,5500. 
-------------------------------------------------------------------------------
Setting Name: Cargo #xx full requirement population
Setting Range: 250-1,000,000
Comments: If town population is between intro and full requirement amounts, 
the cargo required will be reduced. For example, with 10 promille requirement, 
1,000 waive, and 3,000 full, a town of 2,000 will only require 0.5% or 10 units
per month. A town of 2,500 would require 0.75% or 19 units per month. This is 
to prevent towns that are slightly above a waive number from suddenly requiring much
more cargo. It's highly recommended to have reasonably large transition lengths for
all cargoes for a better CB experience.
-------------------------------------------------------------------------------
Setting Name: Cargo #xx decay rate:
Setting Range: 0-1000
Comments: Another promillage. Determines the fraction of cargo lost in warehouses 
each month. You should set the decay rate of cargoes required every month to 1000. 
Set to 0 to not have any decay.

//////////////////////////////////////////////////////////////////////////////
// 5: TESTING
//////////////////////////////////////////////////////////////////////////////

IMPORTANT: THIS IS AN UNSTABLE ALPHA TEST OF CITYBUILDER
 CRASHES AND BUGS ARE PRESENT.
 If you find a bug not on this list of known issues, please report at www.tt-forums.net,
 Nogo section, CB Release Topic.
 
 ---Missing features:
 
 - Station cargo decay
 
 This feature will decay cargo sitting in stations at the decay rate for said cargo.
 This will prevent abusing stations to store cargo from lines with insufficient frequency for
 small towns,  for cargoes that should not be abused (passengers, for example, don't like
 sitting in a station for a year!)
 
 Note: this feature would be another .nut file (station.nut), keeping track of all (new) stations, 
 and modifying cargo levels in those stations. Each station would have to (get) the game setting
 of cargo decay array.which has 32 fields.
 
 - Removing Houses
 
 Due to NoGo limitations, houses can't be reliably removed with script. Towns will simply stagnate
 below requirement instead of shrink.
 
 - Proper Fund Town support
 
 Due to NoGo limitations, I can't properly support 'fund town'. Currently it's a cheat button.
 
- Forbidding building near a town.

This is a critical failure. Other companies can still build whatever near your town. 
Claiming a town should of course result in NO BUILDING ALLOWED WHATSOEVER.

- Claim limit setting

When forbidding works, a setting should be added limiting when towns can be claimed. 
I don't want someone claiming a town halfway into the game, or claiming on top of someone else's railroad. 
 
 - Sub: Preventing claims in built-up areas
 
 ---Known bugs and issues:
 
 --Critical (crashes, especially severe issues) bugs.
 
Towns in the Rainforest require water. Unfortunately GSTile::IsDesertTile appears to be broken.
 
 --Major (game-breaking) bugs.
    
- 'Months' are longer than a month on huge maps.

The script has some places where it is highly inefficient. Especially on very large maps, updating your 
city's stats might happen on 2- or 3- of the month. Try increasing the amt. of code lines a script is 
allowed to do. This may impact game performance on slower systems!

- The script can behave weirdly when more than 2,147,483 units of cargo are present in a town.
This is due to integer limits. Fixing it might cause performance issues.
Creator Note: I don't think this number is that easily reached so accept it.
Please feel free to suggest improvements to raise this limit. 

- Minor issues: 

- Settings cannot be modified in-game.
	Most settings are actually cached by the objects to save on precious time. 
	Therefore the settings can't be modified in-game. 
	
- There is a chance of about 1/2533274790395904000 that the script will crash when a company suddenly ceases to exist. 
	It won't happen with normal bankruptcies, only with resets by command. 

----- Testing notes;

Not doing anything should get you the 'you're fired' message after N game years.
Please try meddling with the settings.
The save function needs some stress testing as well on large maps. Try playing for longer periods of time on larger maps and see if the save still works. 
When you do find a bug, please report your findings in the thread at www.tt-forums.net under the AI/NOGO
 section, the release topic. 
 Try this script in longer games, with NewGRFs, and most importantly, in MULTIPLAYER.
