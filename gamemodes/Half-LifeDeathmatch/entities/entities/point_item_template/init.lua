AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	self:SetName( tostring(self.template_ent) .. "_template" .. self:EntIndex() )
end


function ENT:Think()
end 

function ENT:SpawnItem( )
	local item = ents.Create( self.temp_class )
	for k, v in pairs( self.temp_keys ) do
		if type(v) != "table" then
			item:SetKeyValue( k, v )
		else
			local k_out = k
			for k, v in pairs(v) do
				item:SetKeyValue( k_out, v )
			end
		end
	end
	item:SetPos( self.temp_pos )
	item:SetAngles( self.temp_ang )
	item:Spawn()
	item:Activate()
	local itemclass = item:GetClass()
	if itemclass != "item_battery" and itemclass != "item_healthkit" then
		item:Fire( "AddOutput", "OnPlayerPickup " .. self:GetName() .. ":ForceSpawn::18:1", 0 )
	else
		item:Fire( "AddOutput", "OnCacheInteraction " .. self:GetName() .. ":ForceSpawn::18:1", 0 )
	end
	item:EmitSound( "items/suitchargeok1.wav", 100, 175 )
end

function ENT:KeyValue( key, value )
	if key == "Template01" then
		self.template_ent = ents.FindByName( value )[1]
		self.temp_pos = self.template_ent:GetPos()
		self.temp_ang = self.template_ent:GetAngles()
		self.temp_class = self.template_ent:GetClass()
		self.temp_keys = ents_kvtable["ent_" .. tostring(self.template_ent) .. "_kvtable"]
	end
end

function ENT:AcceptInput( cvar_name, activator, caller )
	if( cvar_name == "ForceSpawn" and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self:SpawnItem()
	end
end
