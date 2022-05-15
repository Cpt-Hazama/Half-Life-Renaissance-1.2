if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_npc_spawnmenu_op.lua" );
end

local Category = "Opposing Force"
local NPC = { 	Name = "Penguin", 
				Class = "monster_penguin",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		


local NPC = { 	Name = "Gonome", 
				Class = "monster_gonome",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		

local NPC = { 	Name = "Pit Drone", 
				Class = "monster_pitdrone",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		

local NPC = { 	Name = "Voltigore", 
				Class = "monster_alien_voltigore",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		

local NPC = { 	Name = "Baby Voltigore", 
				Class = "monster_alien_babyvoltigore",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )			

local NPC = { 	Name = "Zombie Guard", 
				Class = "monster_zombie_barney",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		

local NPC = { 	Name = "Zombie Soldier", 
				Class = "monster_zombie_soldier",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )		