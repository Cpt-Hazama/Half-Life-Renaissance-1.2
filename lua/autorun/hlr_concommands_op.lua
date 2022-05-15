if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_concommands_op.lua" );
end

// PENGUIN
function sk_penguin_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_penguin_health_value = v
		end
	end
end 
concommand.Add( "sk_penguin_health", sk_penguin_health )

sk_penguin_health_value = 8

function sk_penguin_melee_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_penguin_melee_value = v
		end
	end
end 
concommand.Add( "sk_penguin_dmg_bite", sk_penguin_melee_dmg )

sk_penguin_melee_value = 4

function sk_penguin_blast_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_penguin_blast_value = v
		end
	end
end 
concommand.Add( "sk_penguin_dmg_blast", sk_penguin_blast_dmg )

sk_penguin_blast_value = 85

function sk_penguin_blast_delay( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_penguin_delay_value = v
		end
	end
end 
concommand.Add( "sk_penguin_blast_delay", sk_penguin_blast_delay )

sk_penguin_delay_value = 17

// GONOME
function sk_gonome_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_health_value = v
		end
	end
end 
concommand.Add( "sk_gonome_health", sk_gonome_health )

sk_gonome_health_value = 200

function sk_gonome_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_slash_value = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_slash", sk_gonome_slash_dmg )

sk_gonome_slash_value = 18

function sk_gonome_jump_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_jump_value = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_jump", sk_gonome_jump_dmg )

sk_gonome_jump_value = 30

function sk_gonome_acid_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_acid_value = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_acid", sk_gonome_acid_dmg )

sk_gonome_acid_value = 25

function sk_gonome_claws_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_claws_value = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_claws", sk_gonome_claws_dmg )

sk_gonome_claws_value = 8

// PIT DRONE
function sk_pitdrone_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitdrone_health_value = v
		end
	end
end 
concommand.Add( "sk_pitdrone_health", sk_pitdrone_health )

sk_pitdrone_health_value = 60

function sk_pitdrone_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitdrone_slash_value = v
		end
	end
end 
concommand.Add( "sk_pitdrone_dmg_slash_both", sk_pitdrone_slash_dmg )

sk_pitdrone_slash_value = 18

function sk_pitdrone_spike_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitdrone_spike_value = v
		end
	end
end 
concommand.Add( "sk_pitdrone_dmg_spike", sk_pitdrone_spike_dmg )

sk_pitdrone_spike_value = 24

function sk_pitdrone_claws_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitdrone_claws_value = v
		end
	end
end 
concommand.Add( "sk_pitdrone_dmg_slash", sk_pitdrone_claws_dmg )

sk_pitdrone_claws_value = 8

// VOLTIGORE
function sk_voltigore_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_voltigore_health_value = v
		end
	end
end 
concommand.Add( "sk_voltigore_health", sk_voltigore_health )

sk_voltigore_health_value = 450

function sk_voltigore_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_voltigore_slash_value = v
		end
	end
end 
concommand.Add( "sk_voltigore_dmg_slash", sk_voltigore_slash_dmg )

sk_voltigore_slash_value = 22

function sk_voltigore_shock_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_voltigore_shock_value = v
		end
	end
end 
concommand.Add( "sk_voltigore_dmg_shock", sk_voltigore_shock_dmg )

sk_voltigore_shock_value = 42

// PIT WORM
function sk_pitworm_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitworm_health_value = v
		end
	end
end 
concommand.Add( "sk_pitworm_health", sk_pitworm_health )

sk_pitworm_health_value = 2000

function sk_pitworm_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitworm_slash_value = v
		end
	end
end 
concommand.Add( "sk_pitworm_dmg_slash", sk_pitworm_slash_dmg )

sk_pitworm_slash_value = 65

function sk_pitworm_beam_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_pitworm_beam_value = v
		end
	end
end 
concommand.Add( "sk_pitworm_dmg_beam", sk_pitworm_beam_dmg )

sk_pitworm_beam_value = 11

// SHOCK TROOPER
function sk_strooper_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_strooper_health_value = v
		end
	end
end 
concommand.Add( "sk_strooper_health", sk_strooper_health )

sk_strooper_health_value = 200

function sk_strooper_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_strooper_slash_value = v
		end
	end
end 
concommand.Add( "sk_strooper_dmg_slash", sk_strooper_slash_dmg )

sk_strooper_slash_value = 12

function sk_strooper_bolt_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_strooper_bolt_value = v
		end
	end
end 
concommand.Add( "sk_strooper_dmg_bolt", sk_strooper_bolt_dmg )

sk_strooper_bolt_value = 8

function sk_strooper_grenade_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_strooper_grenade_value = v
		end
	end
end 
concommand.Add( "sk_strooper_dmg_grenade", sk_strooper_grenade_dmg )

sk_strooper_grenade_value = 38

// BABY VOLTIGORE
function sk_babyvoltigore_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_babyvoltigore_health_value = v
		end
	end
end 
concommand.Add( "sk_babyvoltigore_health", sk_babyvoltigore_health )

sk_babyvoltigore_health_value = 130

function sk_babyvoltigore_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_babyvoltigore_slash_value = v
		end
	end
end 
concommand.Add( "sk_babyvoltigore_dmg_slash", sk_babyvoltigore_slash_dmg )

sk_babyvoltigore_slash_value = 10