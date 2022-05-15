---:: Half-Life_Renaissance v1.2 ::---
by Silverlan

Installation:
Copy all the folders from the archive into your gmod main directory.

Description:
This pack consists of several new things:
HL1 (S)NPCs:
- Alien Controller
- Alien Slave
- Archer
- Babycrab
- Barney
- Bullsquid
- Cockroach
- Gargantua
- GMan
- Gonarch
- Headcrab
- Houndeye
- Human Assassin
- Human Grunt
- Ichthyosaur
- Nihilanth
- Panthereye
- Scientist
- Snarks
- Stukabat
- Zombie

Opposing Force (S)NPCs:
- Baby Voltigore
- Gonome
- Penguin
- Pit Drone
- Voltigore
- Zombie Guard
- Zombie Soldier

Others:
- Baby Gargantua
- Parasite

SWEPs:
- Barney's Handgun
- MP5
- Egon
- Gauss cannon
- Handgrenade
- Satchel
- Snark Gun
- Hornet Gun
- Penguin SWEP
- Tripmine
- Possessor

Other/Items:
- 9mm ARammo
- 9mm ammo box
- 9mm ammo clip
- 357 ammo
- ar grenade ammo
- buckshot ammo
- crossbow ammo
- gauss ammo
- mp5 ammo
- mp5 grenade ammo
- rpg ammo
- Antidote
- Xen plantlight
- Xen spore small/medium/large
- Xen tree

You can equip NPCs with some of the SWEPs too, by choosing them from the weapon list. (Doesn't work for all of the weapons)
Some of the SWEPs(Barney's Handgun, MP5, etc) also have iron sights. To use it, bind a key to "ironsight" and press it while holding the weapon.

Credits:
- Ring-Ding: I used the hornet sent of his Hornet Gun SWep as base for the Alien Grunt and my own hornet gun swep
- Q42: He made the spit effect for the bullsquid and the gonarch. Thanks a lot!
- SnakeSVx: Helped me with some problems I had
- ralle105: Awesome guy, always helps me when I have problems.
- Synergy mod: Ported the model and material files for the panthereye to the source engine.
- Jinto: Made the code for the custom ammunition types, which I used for some of the SWEPs
- RR_Raptor65: Made the parasite model

--------------------------------------------------------------------------------------------------------

Instructions:
Possessor SWEP:
The possessor SWEP allows you to take control over a NPC. It doesn't work for all of them though.
To use it, just equip yourself with it, aim at the NPC you want to control, and press the primary fire.
You can use your move keys to move the NPC, and your attack keys to make him attack.
Some NPCs have more than two attack. To use the secondary attacks, just hold the duck key and then press an attack key.
You can use the walk key to make them walk instead of run. 
Use the jump key to stop controlling the NPC.
Here's a list with all possessable NPCs and their attacks:
Antlion:
	Primary Attack: Melee(swipe)

Antlionguard:
	Primary Attack: Melee(shove)

Antlion Worker:
	Primary Attack: Melee(swipe)
	Secondary Attack: Melee(swipe)

Zombie/Zombie Torso/Fastzombie Torso:
	Primary Attack: Melee(slash)

Fastzombie:
	Primary Attack: Melee(slash)
	Secondary Attack: Melee(jump)

Poisonzombie:
	Primary Attack: Melee(slash)
	Secondary Attack: Throw headcrab

Zombine:
	Primary Attack: Melee(slash)
	Secondary Attack: Grab Grenade

Headcrab/Fast Headcrab/Poison Headcrab/Babycrab:
	Primary Attack: Melee(jump)
	Secondary Attack: Burrow/Unburrow (Only normal headcrab)

Vortigaunt:
	Primary Attack: Melee(claw)
	Secondary Attack: Zap
	Secondary Attack(+duck): Heal nearby player

Alien Grunt:
	Primary Attack: Hornet Gun
	Secondary Attack: Melee(punch)

Alien Slave:
	Primary Attack: Zap
	Secondary Attack: Melee(claw)

Bullsquid:
	Primary Attack: Spit
	Secondary Attack: Melee(whip)
	Secondary Attack(+duck): Melee(bite)

Cockroach:
	-

Gargantua:
	Primary Attack: Flame
	Primary Attack(+duck): Stomp
	Secondary Attack: Melee(slash)

Gonarch:
	Primary Attack: Spit
	Primary Attack(+duck): Spawn Babycrabs
	Secondary Attack: Melee(slash)

Houndeye:
	Primary Attack: Sonic

Human Assassin:
	Primary Attack: Weapon
	Primary Attack(+duck): Throw Grenade
	Secondary Attack: Jump Backwards
	Secondary Attack(+duck): Melee(kick)

Human Grunt:
	Primary Attack: Weapon
	Secondary Attack: Grenade/grenade launcher, whatever he's equipped with
	Secondary Attack(+duck): Melee(kick)

Panthereye:
	Primary Attack: Melee(claw)
	Secondary Attack: Jump

Parasite:
	Primary Attack: Melee(slash)
	Primary Attack(+duck): Poison Melee(slash)
	Secondary Attack: Climb wall(has to be 380 units in front of a wall)
	


How to use the SNPCs in your map:
- Open Hammer
- Go to Tools/Options, then click on "Add" next to the Game Data Files
- Open the "new_npc_pack" addons folder and choose the "new_npcs.fgd"
- You have to copy the models and materials from the pack into the models/materials folder of the game directory of the game you've set in Hammer. If you don't do that, the SNPCs will show up as errors in Hammer.


Inputs:
To fire an input to a SNPC, you have to look at it, and type one of the ent_fire commands below into the console.


1) followtarget_*
You can use this command, to make the SNPC you're looking at, follow a specific entity. (Can be a prop, NPC, player or any other entity)
If the target to follow is a NPC or player, the SNPC's relationship to the target will be automatically set to D_LI, so it'll never attack its leader.
You can only use this once.
If you want to use this input again, you have to use the "stopfollowtarget" input first.
Both of these inputs are available in Hammer too.

Usage:
"ent_fire !picker followtarget_target" - "target" has to be an entityname. Can be any entity (prop/NPC/player, etc). If there's more than one entity with the targetname, it will automatically choose the closest one. Example: If you want it to follow a npc_zombie called zombie1, use "ent_fire !picker followtarget_zombie1"
"ent_fire !picker followtarget_!player" - Looks for the nearest player and makes the SNPC follow him
"ent_fire !picker followtarget_!playerx" - Looks for the player with the UserID x. Example: If you want it to follow a player with the userID 3, use "ent_fire !picker followtarget_!player3".
"ent_fire !picker followtarget_!self" - Sets yourself as follow target.

2) stopfollowtarget
This command immediately makes the SNPC you're looking at stop following his target.
If the leader entity was a NPC or a player, the SNPCs relationship will be reset to what it was before the "followtarget_*" input was used on it.

Usage:
"ent_fire !picker stopfollowtarget"

NPC specific inputs:
These inputs only work for one or more SNPCs.

Controller:
1) startflyingpath
If a target path corner is set in the properties of a controller in Hammer, this output will make it fly the whole path to the end.

2) stopflyingpath
This will stop the controller flying the path. If it already passed one or more path_corners, it will continue on the next one when you fire the "startflyingpath" input to it.


Console Commands:
// Alien Controller:
sk_controller_health
sk_controller_dmgball
sk_controller_fly_speed

// Alien Grunt:
sk_agrunt_health
sk_agrunt_dmg_punch

// Alien Slave:
sk_islave_health
sk_islave_dmg_claw
sk_islave_dmg_zap

// Archer:
sk_archer_health
sk_archer_dmg_bite
sk_archer_dmg_shoot

// Baby Headcrab (Babycrab):
sk_babycrab_health
sk_babycrab_dmg_bite

// Barney:
sk_barney_hl1_health

// Bullsquid:
sk_bullsquid_health
sk_bullsquid_dmg_whip
sk_bullsquid_dmg_bite
sk_bullsquid_dmg_spit

// Gargantua:
sk_gargantua_health
sk_gargantua_dmg_slash
sk_gargantua_dmg_fire
sk_gargantua_dmg_fire_npc
sk_gargantua_dmg_stomp

// Gonarch (Big Momma):
sk_gonarch_health
sk_bigmomma_dmg_slash
sk_bigmomma_dmg_blast

// Headcrab:
sk_headcrab_hl1_health
sk_headcrab_hl1_dmg_bite

// Houndeye:
sk_houndeye_health
sk_houndeye_dmg_blast

// Human Assassin:
sk_hassassin_health

// Human Grunt:
sk_hgrunt_health
sk_hgrunt_dmg_kick

// Ichthyosaur:
sk_ichthyosaur_health
sk_ichthyosaur_melee_dmg


// Panthereye:
sk_panthereye_health
sk_panthereye_dmg_slash
sk_panthereye_dmg_jump

// Parasite:
sk_parasite_health
sk_parasite_dmg_slash

// Scientist:
sk_scientist_health
sk_scientist_heal

// Snark:
sk_snark_health
sk_snark_dmg_bite
sk_snark_dmg_pop
sk_snark_pop_delay

// Zombie:
sk_zombie_hl1_health
sk_zombie_hl1_dmg_one_slash
sk_zombie_hl1_dmg_both_slash

// Weapons:
ironsight	// Toggles ironsight of the weapon you're holding. Only works for some SWEPs (Mp5, Barney's Handgun, etc)

sk_plr_dmg_9mm_bullet
sk_plr_dmg_mp5_grenade
sk_plr_dmg_gauss
sk_gauss_deathmatch	// Toggle backpush (standard: off)
sk_plr_dmg_grenade
sk_plr_dmg_hornet
sk_plr_dmg_satchel
sk_npc_dmg_hornet
sk_npc_dmg_9mm_bullet
sk_npc_dmg_9mmAR_bullet
sk_npc_dmg_12mm_bullet


Keyvalues/Flags:
I added a bunch of keyvalues for mappers.
Most of them should be self-explanatory, here's a small list:
key: wandering	value: 0/1
key: health	value: integer
key: TriggerTarget	value: string name	// Only for HL1 map compatibility
key: TriggerCondition	value: integer		// Same as above
key: spawnflags	value: 64	// Should NPC ignore players?

Gargantua:
key: immune	value: 0/1	// Invincible for bullets

Snark:
key: blast	value: integer	// Amount of damage done to all NPCs/players around when exploding
key: blasttime	value: integer // Amount of time until the snark explodes. Only works if "Don't self-destruct" flag is unchecked.
key: spawnflags	value: 32768	// If this flag is checked, the snark won't self-destruct

Controller:
key: flyspeed	value: integer	// Speed at which the controller should fly along a path or to the enemies

Scientist/Barney:
key: spawnflags	value: 65536	// Pre-Disaster; NPC won't follow player on use, will speak random pre-disaster sentence instead.


There's a better description for each of the keyvalues in the NPC settings in Hammer.
