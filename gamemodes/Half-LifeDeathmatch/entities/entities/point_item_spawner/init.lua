AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
end


function ENT:Think()
	local item_tbl = ents.FindByClass( "item_*" )
	for k, v in pairs( ents.FindByClass( "ammo_*" ) ) do
		table.insert( item_tbl, v )
	end
	for k, v in pairs( ents.FindByClass( "weapon_*" ) ) do
		table.insert( item_tbl, v )
	end
	self.item_classtbl = {}
	for k, v in pairs( item_tbl ) do
		if !table.HasValue( self.item_classtbl, v:GetClass() ) then
			self.item_classtbl[v] = v:GetClass()
		end
	end
	self:NextThink( CurTime() +2 )
end 

function ENT:RespawnItem( item )
	item:Spawn()
	item:Activate()
	item:Fire( "AddOutput", "OnPlayerPickup " .. self:GetName() .. ":ForceRespawn::0:1", 0.1 )
	item:EmitSound( "items/suitchargeok1.wav", 100, 175 )
end

function ENT:AcceptInput( cvar_name, activator, caller )
	if( cvar_name == "ForceRespawn" and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		/*for k, v in pairs( self.item_classtbl ) do
			if k == caller then
				self.callerclass = v
			end
		end
		local new_ent = ents.Create( self.callerclass )
		local tbl_item_pos = {}
		for k, v in pairs( self.tbl_item_pos ) do
			if k == caller then
				new_ent:SetPos( v )
				tbl_item_pos[new_ent] = v
			else
				tbl_item_pos[k] = v
			end
		end
		self.tbl_item_pos = tbl_item_pos
		tbl_item_pos = nil
		
		tbl_item_ang = {}
		for k, v in pairs( self.tbl_item_ang ) do
			if k == caller then
				new_ent:SetAngles( v )
				tbl_item_ang[new_ent] = v
			else
				tbl_item_ang[k] = v
			end
		end
		self.tbl_item_ang = tbl_item_ang
		tbl_item_ang = nil
		self.callerclass = nil*/
		
		/*for k, v in pairs( ents_kvtable["ent_" .. tostring(caller) .. "_kvtable"] ) do
			if type(v) != "table" then
				new_ent:SetKeyValue( k, v )
			else
				local k_out = k
				for k, v in pairs(v) do
					new_ent:SetKeyValue( k_out, v )
				end
			end
		end*/
		//Msg( "New keyvalues: \n" )
		//PrintTable( ents_kvtable["ent_" .. tostring(new_ent) .. "_kvtable"] )
		timer.Simple( 18, function() self:RespawnItem( new_ent ) end )
	end
end