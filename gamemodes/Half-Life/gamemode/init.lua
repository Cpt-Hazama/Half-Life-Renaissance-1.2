/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/


// These files get sent to the client

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )
include( 'player.lua' )
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

local weapons = {}

function GM:Initialize()
	game.ConsoleCommand( "mp_falldamage 1\n" )
	game.ConsoleCommand( "ai_ignoreplayers 0\n" )
	for k, v in pairs( player:GetAll() ) do
		if v:IsListenServerHost( ) then
			self.jumpdivider = 3
		end
	end
	if !self.jumpdivider then self.jumpdivider = 1.2 end
	//self:InitPostEntity()
end


function GM:InitPostEntity( )
	self:ReplaceItem( "weapon_mp5", "weapon_9mmAR" )
	self:ReplaceItem( "weapon_glock", "weapon_9mmhandgun" )
	
	for k, v in pairs( ents.FindByClass( "monster_generic" ) ) do
		if v:GetModel() == "models/barney.mdl" then
			v:SetModel( "models/ba_hl1.mdl" )
		end
	end

	for k, v in pairs( ents.FindByClass( "scripted_sequence" ) ) do
		local target_npc_string = ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["m_iszEntity"]
		local target_npc = ents.FindByName( target_npc_string )[1] or ents.FindByClass( target_npc_string )[1]
		if ( target_npc and string.find( target_npc:GetClass(), "monster_" ) and target_npc:GetClass() != "monster_generic" ) or !target_npc then
			local seq = ents.Create( "scripted_monster_sequence" )
			seq:SetPos( v:GetPos() )
			seq:SetAngles( v:GetAngles() )
			for k, v in pairs( ents_kvtable["ent_" .. tostring(v) .. "_kvtable"] ) do
				if type(v) != "table" then
					seq:SetKeyValue( k, v )
				else
					local k_out = k
					for k, v in pairs(v) do
						seq:SetKeyValue( k_out, v )
					end
				end
			end
			seq:SetName( v:GetName() )
			seq:Spawn()
			seq:Activate()
			v:Remove()
		end
	end

	local render_ents = ents.GetAll()
	
	for k, v in pairs( render_ents ) do
		if ents_kvtable and ents_kvtable["ent_" .. tostring(v) .. "_kvtable"] and (tonumber(ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["rendermode"]) == 0 or (!ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["rendermode"] and ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["renderamt"])) and tonumber(ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["renderamt"]) == 0 then
		//if ents_kvtable["ent_" .. tostring(v) .. "_kvtable"] and (tonumber(ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["rendermode"]) == 0 or (!ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["rendermode"] and ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["renderamt"])) then
			//v:SetKeyValue( "renderamt", tostring(255 -tonumber(ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["renderamt"])) )
			v:SetKeyValue( "renderamt", "255" )
		end
	end
	local function RemoveSpawnpoints()
		for k, v in pairs( ents.FindByClass( "info_player_start" ) ) do
			v:Remove()
		end
	end
	if GetConVarNumber( "sv_lan" ) == 1 then self.singleplayer = true end
	
	local cur_map = game.GetMap( )
	local spawnpositions = {}
	if cur_map == "c0a0" then
		spawnpositions[Vector(2944, 2804, 462)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(2999, 2804, 462)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(3062, 2804, 462)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(2872, 2864, 462)] = Angle( 0, 180, 0 )
		self.plystartparent = "train"
		RemoveSpawnpoints()
	elseif cur_map == "c0a0a" then
		local train = ents.FindByName( "train" )[1]
		spawnpositions[train:LocalToWorld(Vector(107, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(192, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(278, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(278, -30, 18))] = train:GetAngles()
		self.plystartparent = "train"
		RemoveSpawnpoints()
		self:RemoveLevelChange( "c0a0" )
	elseif cur_map == "c0a0b" then
		local train = ents.FindByName( "train" )[1]
		spawnpositions[train:LocalToWorld(Vector(57, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(142, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(228, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(228, -30, 18))] = train:GetAngles()
		self.plystartparent = "train"
		self:RemoveLevelChange( "c0a0a" )
		RemoveSpawnpoints()
	elseif cur_map == "c0a0c" then
		local train = ents.FindByName( "train" )[1]
		spawnpositions[train:LocalToWorld(Vector(-23, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(62, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, -30, 18))] = train:GetAngles()
		self.plystartparent = "train"
		self:RemoveLevelChange( "c0a0b" )
		RemoveSpawnpoints()
	elseif cur_map == "c0a0d" then
		local train = ents.FindByName( "train" )[1]
		spawnpositions[train:LocalToWorld(Vector(-23, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(62, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, -30, 18))] = train:GetAngles()
		self.plystartparent = "train"
		self:RemoveLevelChange( "c0a0c" )
		RemoveSpawnpoints()
	elseif cur_map == "c0a0e" then
		local train = ents.FindByName( "train" )[1]
		spawnpositions[train:LocalToWorld(Vector(-23, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(62, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, 28, 18))] = train:GetAngles()
		spawnpositions[train:LocalToWorld(Vector(108, -30, 18))] = train:GetAngles()
		self.plystartparent = "train"
		self:RemoveLevelChange( "c0a0d" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a0" then
		spawnpositions[Vector(466, 358, -191)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(466, 280, -191)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(382, 358, -191)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(382, 280, -191)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "c0a0e" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a0a" then
		spawnpositions[Vector(110, 2112, 784)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(240, 2170, 784)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(240, 2112, 784)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(240, 2054, 784)] = Angle( 0, 0, 0 )
		self:RemoveLevelChange( "c1a0d" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a0b" then
		spawnpositions[Vector(704, 1002, -134)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(704, 952, -134)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(775, 952, -134)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(775, 1002, -134)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "c1a0a" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a0c" then
		spawnpositions[Vector(1644, 333, -345)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(1644, 380, -345)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(1752, 333, -345)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(1752, 380, -345)] = Angle( 0, 0, 0 )
		self:RemoveLevelChange( "c1a0e" )
		RemoveSpawnpoints()
		for k, v in pairs( ents.FindByName( "elebutton1" ) ) do
			if ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["origin"] == "494.5 428.5 -296" then
				v:SetPos( v:GetPos() +v:GetRight() *8 )
			elseif ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["origin"] == "602.5 351.5 -81" then
				v:SetPos( v:GetPos() +v:GetForward() *-1 *8 )
			else
				v:SetPos( Vector(665,435,-311) )
				v:SetAngles( Angle( 0, 90, 0 ) )
				v:Fire( "AddOutput", "OnPressed ele_2:toggle::0:-1", 0 )
			end
			v:SetKeyValue( "origin", tostring(v:GetPos()) )
			v:Spawn()
		end
	elseif cur_map == "c1a0d" then
		spawnpositions[Vector(-1744, 304, -240)] = Angle( 0, 169, 0 )
		spawnpositions[Vector(-1744, 359, -240)] = Angle( 0, 169, 0 )
		spawnpositions[Vector(-1808, 304, -240)] = Angle( 0, 169, 0 )
		spawnpositions[Vector(-1808, 359, -240)] = Angle( 0, 169, 0 )
		self:RemoveLevelChange( "c1a0" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a0e" then
		spawnpositions[Vector(1500, -160, -320)] = Angle( 0, 44, 0 )
		spawnpositions[Vector(1500, -111, -320)] = Angle( 0, 44, 0 )
		spawnpositions[Vector(1500, -58, -320)] = Angle( 0, 316, 0 )
		spawnpositions[Vector(1500, -9, -320)] = Angle( 0, 316, 0 )
		self:RemoveLevelChange( "c1a0b" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a1" then
		spawnpositions[Vector(1016, 656, -80)] = Angle( 0, 101, 0 )
		spawnpositions[Vector(951, 656, -80)] = Angle( 0, 101, 0 )
		spawnpositions[Vector(1016, 708, -80)] = Angle( 0, 101, 0 )
		spawnpositions[Vector(951, 708, -80)] = Angle( 0, 101, 0 )
		self:RemoveLevelChange( "c1a0c" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a1a" then
		spawnpositions[Vector(-2581, -806, -213)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-2581, -722, -213)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-2648, -722, -213)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-2648, -806, -213)] = Angle( 0, 180, 0 )
		//weapons: crowbar
		self:RemoveLevelChange( "c1a1" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a1f" then
		spawnpositions[Vector(-1365, 350, -183)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1365, 284, -183)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1253, 292, -183)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1246, 343, -183)] = Angle( 0, 0, 0 )
		self:RemoveLevelChange( "c1a1a" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a1b" then
		spawnpositions[Vector(-342, -132, -189)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-342, -185, -189)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-282, -185, -189)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-282, -132, -189)] = Angle( 0, 0, 0 )
		self:RemoveLevelChange( "c1a1f" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a1c" then
		if ValidEntity(ents.FindByName( "c1a1bc" )[1]) then
			ents.FindByName( "c1a1bc" )[1]:Remove()
			spawnpositions[Vector(-125, -3192, -179)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-48, -3192, -179)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-48, -3320, -179)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-125, -3320, -179)] = Angle( 0, 270, 0 )
			self:RemoveLevelChange( "c1a1b" )
		else
			spawnpositions[Vector(-1083, 1357, -2699)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-1083, 1303, -2699)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-1083, 1248, -2699)] = Angle( 0, 270, 0 )
			spawnpositions[Vector(-1083, 1209, -2699)] = Angle( 0, 270, 0 )
			self:RemoveLevelChange( "c1a1d" )
		end
		RemoveSpawnpoints()
	elseif cur_map == "c1a1d" then
		spawnpositions[Vector(608, -495, -159)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(608, -426, -159)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(608, -366, -159)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(608, -262, -159)] = Angle( 0, 270, 0 )
		self:RemoveLevelChange( "c1a1c" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a2" then
		spawnpositions[Vector(2274, -909, -511)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(2274, -1028, -511)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(2380, -1028, -511)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(2380, -909, -511)] = Angle( 0, 90, 0 )
		self:RemoveLevelChange( "c1a1c" )
		RemoveSpawnpoints()
	elseif cur_map == "c1a2d" then
		spawnpositions[Vector(1280, -1592, -561)] = Angle( 0, 270, 0 )
		spawnpositions[Vector(1349, -1592, -561)] = Angle( 0, 270, 0 )
		spawnpositions[Vector(1349, -1707, -561)] = Angle( 0, 270, 0 )
		spawnpositions[Vector(1280, -1707, -561)] = Angle( 0, 270, 0 )
		self:RemoveLevelChange( "c1a2" )
		RemoveSpawnpoints()
		local breakables = ents.FindByClass( "func_breakable" )
		for k, v in pairs( breakables ) do
			local globalname = ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["globalname"]
			if globalname == "c1a2_hall_box7" or globalname == "c1a2_hall_box8" or globalname == "c1a2_hall_box9" then
				v:Remove()
			end
		end
	/*elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then
	elseif cur_map == "" then*/
	elseif cur_map == "t0a0" then
		spawnpositions[Vector(-1339, -1906, -24)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(-1339, -1958, -24)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(-1427, -1906, -24)] = Angle( 0, 90, 0 )
		spawnpositions[Vector(-1427, -1958, -24)] = Angle( 0, 90, 0 )
		RemoveSpawnpoints()
	elseif cur_map == "t0a0a" then
		spawnpositions[Vector(580, 176, 40)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(541, 176, 40)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(580, 218, 40)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(541, 218, 40)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "t0a0" )
		RemoveSpawnpoints()
	elseif cur_map == "t0a0b1" then
		spawnpositions[Vector(1789, -1267, -135)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(1881, -1267, -135)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(1789, -1323, -135)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(1881, -1323, -135)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "t0a0a" )
		RemoveSpawnpoints()
	elseif cur_map == "t0a0b2" then
		spawnpositions[Vector(-122, -291, -160)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-122, -386, -160)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-51, -291, -160)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-51, -386, -160)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "t0a0b1" )
		RemoveSpawnpoints()
	elseif cur_map == "t0a0c" then
		spawnpositions[Vector(-1265, -1041, -267)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1176, -1041, -267)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1265, -947, -267)] = Angle( 0, 0, 0 )
		spawnpositions[Vector(-1176, -947, -267)] = Angle( 0, 0, 0 )
		self:RemoveLevelChange( "t0a0b2" )
		RemoveSpawnpoints()
	elseif cur_map == "t0a0d" then
		spawnpositions[Vector(-677, -1481, 48)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-677, -1544, 48)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-791, -1544, 48)] = Angle( 0, 180, 0 )
		spawnpositions[Vector(-791, -1481, 48)] = Angle( 0, 180, 0 )
		self:RemoveLevelChange( "t0a0c" )
		RemoveSpawnpoints()
		
		local button_el = ents.FindByName( "lockedbutton" )[1]
			button_el:Fire( "unlock", "", 0 )
			button_el:Fire( "AddOutput", "OnPressed startele1:Unlock:::-1", 0 )
			button_el:Fire( "AddOutput", "OnPressed startele1:Open::0.1:-1", 0 )
	else return end
	
	for k, v in pairs( spawnpositions ) do
		local ply_spawn = ents.Create( "info_player_start" )
		ply_spawn:SetPos( k )
		ply_spawn:SetAngles( v )
		ply_spawn:Spawn()
		ply_spawn:Activate()
		if self.plystartparent then ply_spawn:Fire( "SetParent", self.plystartparent, 0.5 ) end
	end
end

function GM:ReplaceItem( item, replacement )
	for k, v in pairs( ents.FindByClass( item ) ) do
		local wep_ar = ents.Create( replacement )
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
end

function GM:RemoveLevelChange( map )
	if !self.singleplayer then return end
	for k, v in pairs( ents.FindByClass( "trigger_changelevel" ) ) do
		if ents_kvtable["ent_" .. tostring(v) .. "_kvtable"]["map"] == map then
			v:Remove()
		end
	end
end

function GM:KeyPress( ply, key )
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

function GM:PlayerDeath( victim, Inflictor, killer )
	victim.longjump = false
	GAMEMODE:SetPlayerSpeed( victim, 500, 500 )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

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
	pl:SetJumpPower( 170 )
	
	local rand_ply_start = ents.FindByClass( "info_player_start" )[math.random(table.Count(ents.FindByClass( "info_player_start" )))]
	pl:SetPos( rand_ply_start:GetPos() )
	pl:SetAngles( rand_ply_start:GetAngles() )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout()
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )

	// Remove any old ammo
	pl:RemoveAllAmmo()
	local cur_map = game.GetMap( )
	if table.HasValue( chapter_d, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_handgrenade" )
	elseif table.HasValue( chapter_e, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_handgrenade" )
	elseif table.HasValue( chapter_f, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_handgrenade" )
	elseif table.HasValue( chapter_g, cur_map ) or table.HasValue( chapter_h, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_handgrenade" )
	elseif table.HasValue( chapter_i, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 2,	"satchel", 			true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_handgrenade" )
		pl:Give( "weapon_satchel" )
		pl:Give( "weapon_tripmine" )
	elseif table.HasValue( chapter_j, cur_map ) or table.HasValue( chapter_k, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 2,	"satchel", 			true )
		pl:GiveAmmo( 6,	"XBowBolt", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_handgrenade" )
		pl:Give( "weapon_satchel" )
		pl:Give( "weapon_tripmine" )
	elseif table.HasValue( chapter_l, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 2,	"satchel", 			true )
		pl:GiveAmmo( 6,	"XBowBolt", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_handgrenade" )
		pl:Give( "weapon_satchel" )
		pl:Give( "weapon_tripmine" )
		//pl:Give( "weapon_gauss" )
		pl:Give( "weapon_snark" )
	elseif table.HasValue( chapter_m, cur_map ) or table.HasValue( chapter_n, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 2,	"satchel", 			true )
		pl:GiveAmmo( 6,	"XBowBolt", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_handgrenade" )
		pl:Give( "weapon_satchel" )
		pl:Give( "weapon_tripmine" )
		//pl:Give( "weapon_gauss" )
		pl:Give( "weapon_snark" )
		pl:Give( "weapon_hornetgun" )
		pl:Give( "weapon_rpg" )
	elseif table.HasValue( chapter_o, cur_map ) or table.HasValue( chapter_p, cur_map ) or table.HasValue( chapter_q, cur_map ) or table.HasValue( chapter_r, cur_map ) then
		pl:GiveAmmo( 2,	"Grenades", 	true )
		pl:GiveAmmo( 26,	"9mm", 	true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 2,	"satchel", 			true )
		pl:GiveAmmo( 6,	"XBowBolt", 	true )
	
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_9mmhandgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_9mmAR" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_handgrenade" )
		pl:Give( "weapon_satchel" )
		pl:Give( "weapon_tripmine" )
		//pl:Give( "weapon_gauss" )
		pl:Give( "weapon_egon" )
		pl:Give( "weapon_snark" )
		pl:Give( "weapon_hornetgun" )
		pl:Give( "weapon_rpg" )
	end
	
	local cur_map = game.GetMap( )
	if cur_map == "t0a0b2" or cur_map == "t0a0c" or cur_map == "t0a0d" then
		if cur_map != "t0a0b2" then
			pl:Give( "weapon_9mmAR" )
		end
		pl:Give( "weapon_crowbar" )
	end

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

	// The player should always take damage in single player..
	if ( SinglePlayer() ) then return true end

	// No player vs player damage
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		return false
	end
	
	// Default, let the player be hurt
	return true

end

/*---------------------------------------------------------
   Called once on the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	timer.Simple( 0.2, function() ply:KillSilent(); ply:Spawn() end )
	//return false
	//ply:Spawn()
	//self:PlayerSpawn( ply )
	//PlayerDataUpdate( ply )
	
end
