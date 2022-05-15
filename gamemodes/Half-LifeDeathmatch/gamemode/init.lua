/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/


// These files get sent to the client

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )
include( 'player.lua' )
include( 'npc.lua' )
local chapter_a = { "c0a0" }
local chapter_b = { "c1a0" }
local chapter_c = { "c1a1" }
local chapter_d = { "c1a2" }
local chapter_e = { "c1a3" }
local chapter_f = { "c1a4" }
local chapter_g = { "c2a1" }
local chapter_h = { "c2a2" }
local chapter_i = { "c2a3" }
local chapter_j = { "c2a4" }
local chapter_k = { "c2a4d" }
local chapter_l = { "c2a5" }
local chapter_m = { "c3a1" }
local chapter_n = { "c3a2" }
local chapter_o = { "c4a1" }
local chapter_p = { "c4a2" }
local chapter_q = { "c4a1a" }
local chapter_r = { "c4a3" }
local chapter_s = { "c5a1" }

function GM:Initialize()
	game.ConsoleCommand( "mp_falldamage 1\n" )
	sk_wep_gauss_deathmatch_value = 1
	for k, v in pairs( player:GetAll() ) do
		if v:IsListenServerHost( ) then
			self.IsListenServer = true
			self.jumpdivider = 3
		end
	end
	if !self.jumpdivider then self.jumpdivider = 1.2 end
end

function GM:InitPostEntity( )
	for k, v in pairs( ents.FindByClass( "weapon_mp5" ) ) do
		local wep_ar = ents.Create( "weapon_9mmAR" )
		wep_ar:SetPos( v:GetPos() )
		wep_ar:SetAngles( v:GetAngles() )
		for k, v in pairs( ents_kvtable["ent_" .. tostring(v) .. "_kvtable"] ) do
			if type(v) != "table" then
				wep_ar:SetKeyValue( k, v )
			else
				local k_out = k
				for k, v in pairs(v) do
					wep_ar:SetKeyValue( k_out, v )
				end
			end
		end
		v:Remove()
		wep_ar:Spawn()
		wep_ar:Activate()
	end
	
	local item_tbl = ents.FindByClass( "item_*" )
	for k, v in pairs( ents.FindByClass( "ammo_*" ) ) do
		table.insert( item_tbl, v )
	end
	for k, v in pairs( ents.FindByClass( "weapon_*" ) ) do
		table.insert( item_tbl, v )
	end
	
	local tbl_item_pos = {}
	local tbl_item_ang = {}
	
	self.hkit_tbl = {}
	for k, v in pairs( item_tbl ) do
		local temp = ents.Create( "point_item_template" )
			temp.template_ent = v
			temp.temp_class = v:GetClass()
			if ents_kvtable["ent_" .. tostring(v) .. "_kvtable"] then
				temp.temp_keys = ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]
			else
				temp.temp_keys = v:GetKeyValues()
			end
			temp.temp_pos = v:GetPos()
			temp.temp_ang = v:GetAngles()
			temp:Spawn()
			temp:Activate()
	
		local itemclass = v:GetClass()
		if itemclass != "item_battery" and itemclass != "item_healthkit" then
			v:Fire( "AddOutput", "OnPlayerPickup " .. temp:GetName() .. ":ForceSpawn::18:1", 0 )
		else
			self.hkit_tbl[v] = temp
		end
	end
	
	local function CheckSpawnflags()	
		local spawnflags = { 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
		for k, v in pairs( spawnflags ) do
			if v <= self.spawnflags and !self.used then
				local value_a = v
				local value_b = self.spawnflags -v
				if table.HasValue( spawnflags, value_a ) then
					if value_a == 1 then self.startopen = true end
				end
				if self.spawnflags != v then
					if table.HasValue( spawnflags, value_b ) then
						self.used = true
						if value_b == 1 then self.startopen = true end
					else
						self.spawnflags = value_b
						self.used = false
						CheckSpawnflags()
					end
				else
					self.used = true
				end
			end
		end
	end
	
	local render_ents = ents.FindByClass( "func_*" )
	
	for k, v in pairs( render_ents ) do
		if tonumber(ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["renderamt"]) == 0 then
			v:SetKeyValue( "renderamt", "255" )
		end
	end
end

function GM:Think()
	for k, v in pairs( self.hkit_tbl ) do
		if !ValidEntity(k) then
			v:Fire( "ForceSpawn", "", 18 )
			local hkit_tbl = {}
			local medkit = k
			for k, v in pairs( self.hkit_tbl ) do
				if k != medkit then
					hkit_tbl[k] = v
				end
			end
			self.hkit_tbl = hkit_tbl
		end
	end
end

function GM:KeyPress( ply, key )
	//Msg (ply:GetName().." pressed "..key.."\n") 
	if key == 2 and ( !ply:KeyDown( 4 ) or !ply.longjump or !ply:GetGroundEntity():IsWorld() ) then
		ply:SetLocalVelocity( Vector( ply:GetVelocity().x /self.jumpdivider, ply:GetVelocity().y /self.jumpdivider, ply:GetVelocity().z ) )
	elseif key == 2 and ply:KeyDown( 4 ) and ply.longjump and ply:GetGroundEntity():IsWorld() then
		ply:SetLocalVelocity( ply:GetVelocity() *1.8 )
		ply:ViewPunch( Angle( -2, 0, 0 ) )
	end
	
	if key == 131072 then
		GAMEMODE:SetPlayerSpeed( ply, 250, 150 )
		ply.walk = true
	end
end

function GM:KeyRelease( ply, key )
	if key == 131072 and ply.walk then
		GAMEMODE:SetPlayerSpeed( ply, 500, 500 )
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )
	local spawn_table = ents.FindByClass( "info_player_deathmatch" )
	local rand = math.random(1,table.Count(spawn_table))
	pl:SetPos(spawn_table[rand]:GetPos())
	pl:SetAngles(spawn_table[rand]:GetAngles())
	// Stop observer mode
	pl:UnSpectate()

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	// Set the player's speed
	GAMEMODE:SetPlayerSpeed( pl, 500, 500 )
	pl:SprintDisable( )
	//pl:SetFOV( 90, 0 )
	pl:SetJumpPower( 170 )	// 152// 200 = def?
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout()
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )

	// Remove any old ammo
	pl:RemoveAllAmmo()
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )

	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
   Note: This is a shared function - the client will think they can 
	 damage the players even though they can't. This just means the 
	 prediction will show blood.
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker )
	return true
end

/*---------------------------------------------------------
   Called once on the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( ply )

	self.BaseClass:PlayerInitialSpawn( ply )
	
	//PlayerDataUpdate( ply )
	
end
