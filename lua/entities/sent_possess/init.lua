AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.possess_viewmode = 1

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	
	local class = self.target:GetClass()
	if class == "npc_zombine" then
		self.target.possess_viewpos = Vector( -80, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 120
		self.target.possess_viewheight = 65
		self.primattack_a = true
		self.primattack_a_delay = 1.2
		self.secattack_a = true
		self.secattack_a_delay = 4
		self.movedist = 65
	elseif class == "npc_zombie" then
		self.target.possess_viewpos = Vector( -80, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 120
		self.target.possess_viewheight = 65
		self.primattack_a = true
		self.primattack_a_delay = 1.2
		self.movedist = 65
	elseif class == "npc_zombie_torso" or class == "npc_fastzombie_torso" then
		self.target.possess_viewpos = Vector( -80, 0, 50 )
		self.target.possess_addang = Vector(0,0,45)
		self.target.possess_viewdistance = 80
		self.target.possess_viewheight = 45
		self.primattack_a = true
		self.primattack_a_delay = 0.9
		self.movedist = 65
	elseif class == "npc_fastzombie" then
		self.target.possess_viewpos = Vector( -80, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 120
		self.target.possess_viewheight = 65
		self.primattack_a = true
		self.primattack_a_delay = 2.6
		self.secattack_a = true
		self.secattack_a_delay = 2
		self.movedist = 200
	elseif class == "npc_poisonzombie" then
		self.target.possess_viewpos = Vector( -80, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 120
		self.target.possess_viewheight = 65
		self.primattack_a = true
		self.primattack_a_delay = 1.8
		self.secattack_a = true
		self.secattack_a_delay = 3
		self.movedist = 65
	elseif class == "npc_headcrab" then
		self.target.possess_viewpos = Vector( -75, 0, 32 )
		self.target.possess_addang = Vector(0,0,22)
		self.target.possess_viewdistance = 32
		self.target.possess_viewheight = 22
		self.primattack_a = true
		self.primattack_a_delay = 1.6
		self.secattack_a = true
		self.secattack_a_delay = 2
		self.movedist = 65
	elseif class == "npc_headcrab_fast" then
		self.target.possess_viewpos = Vector( -75, 0, 32 )
		self.target.possess_addang = Vector(0,0,22)
		self.target.possess_viewdistance = 32
		self.target.possess_viewheight = 22
		self.primattack_a = true
		self.primattack_a_delay = 1
		self.movedist = 175
	elseif class == "npc_headcrab_black" or class == "npc_headcrab_poison" then
		self.target.possess_viewpos = Vector( -75, 0, 32 )
		self.target.possess_addang = Vector(0,0,22)
		self.target.possess_viewdistance = 32
		self.target.possess_viewheight = 22
		self.primattack_a = true
		self.primattack_a_delay = 1.8
		self.movedist = 65
	elseif class == "npc_antlionguard" then
		self.target.possess_viewpos = Vector( -75, 0, 120 )
		self.target.possess_addang = Vector(0,0,95)
		self.target.possess_viewdistance = 130
		self.target.possess_viewheight = 85
		self.primattack_a = true
		self.primattack_a_delay = 1.8
		self.movedist = 200
	elseif class == "npc_antlion" then
		self.target.possess_viewpos = Vector( -75, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 90
		self.target.possess_viewheight = 75
		self.primattack_a = true
		self.primattack_a_delay = 0.8
		self.movedist = 200
	elseif class == "npc_antlion_worker" then
		self.target.possess_viewpos = Vector( -75, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 90
		self.target.possess_viewheight = 75
		self.primattack_a = true
		self.primattack_a_delay = 0.8
		self.secattack_a = true
		self.secattack_a_delay = 1.8
		self.movedist = 200
	elseif class == "npc_vortigaunt" then
		self.target.possess_viewpos = Vector( -80, 0, 100 )
		self.target.possess_addang = Vector(0,0,65)
		self.target.possess_viewdistance = 120
		self.target.possess_viewheight = 80
		self.primattack_a = true
		self.primattack_a_delay = 1.4
		self.secattack_a = true
		self.secattack_a_delay = 3
		self.secattack_b = true
		self.secattack_b_delay = 3
		self.movedist = 120
	elseif class == "npc_strider" then
		self.possess_dontchangeview = true
		self.target.possess_viewpos = Vector( -140, 0, 120 )
		self.target.possess_addang = Vector(0,0,-18)
		self.target.possess_viewdistance = 150
		self.target.possess_viewheight = 40
		self.primattack_a = true
		self.primattack_a_delay = 0.13
		self.primattack_b = true
		self.primattack_b_delay = 3
		self.secattack_a = true
		self.secattack_a_delay = 4
		//self.secattack_b = true
		//self.secattack_b_delay = 3
		self.movedist = 400
	end
end

function ENT:AddAttackDelay( delay )
	self.possession_allowdelay = CurTime() +delay
end

function ENT:PossessView()
	if self.master:KeyDown( 2 ) then
		self:EndPossession()
		return false
	end
	if self.master:KeyDown( 131072 ) and ( !self.allowswitchdelay or CurTime() > self.allowswitchdelay ) and !self.possess_dontchangeview then
		self.allowswitchdelay = CurTime() +3
		if self.possess_viewmode == 1 then
			self.possess_viewmode = 2
			local viewent_pos = self.target:LocalToWorld( self.target.possess_viewpos )
			self.target.possess_viewent:SetPos( viewent_pos )
			self.target.possess_viewent:SetAngles((self.target:GetPos() -viewent_pos +self.target.possess_addang):Angle())
		else
			self.possess_viewmode = 1
			self.master:SetEyeAngles( self.target.possess_viewent:GetAngles() +Vector(0,180,0) )
		end
	else
		self.allowswitchdelay = CurTime()
	end
	
	if self.possess_viewmode == 1 then
		local ang = self.master:GetAimVector( ):Angle() +Angle(180,0,180)
		local pos = self.target:GetPos() +self.master:GetAimVector( ) *self.target.possess_viewdistance +Vector(0,0,self.target.possess_viewheight)
		self.target.possess_viewent:SetAngles( ang )
		
		local tracedata = {}
		tracedata.start = self.target:GetPos()
		tracedata.endpos = pos
		tracedata.filter = self.target
		local trace = util.TraceLine(tracedata) 
		if trace.HitWorld then
			self.target.possess_viewent:SetPos( trace.HitPos +trace.HitNormal *12 )
		else
			self.target.possess_viewent:SetPos( pos )
		end
	else
		local pos = self.target:LocalToWorld( self.target.possess_viewpos )
		
		local tracedata = {}
		tracedata.start = self.target:GetPos()
		tracedata.endpos = pos
		tracedata.filter = self.target
		local trace = util.TraceLine(tracedata) 
		if trace.HitWorld then
			self.target.possess_viewent:SetPos( trace.HitPos +trace.HitNormal *12 )
		else
			self.target.possess_viewent:SetPos( pos )
		end
	end
	return true
end

function ENT:PossessMovement( movedist )
	local function MoveToTargetPos( pos, walk )
		local movetarget = ents.Create( "info_target" )
		movetarget:SetPos( pos )
		movetarget:Spawn()
		movetarget:Activate()
		self.target:SetLastPosition( movetarget:GetPos() )
		
		if !walk then
			self.target:SetSchedule( SCHED_FORCED_GO_RUN )
		else
			self.target:SetSchedule( SCHED_FORCED_GO )
		end
		self.target:SetSchedule( SCHED_FORCED_GO_RUN )
		movetarget:Fire( "Kill", "", 1 )
	end
	if self.master:KeyDown( 8 ) then
		local targetpos 
		local trace = {}
		trace.start = self.target:GetPos()
		if self.possess_viewmode == 1 then
			local Pos_a = self.target.possess_viewent:GetPos()
			Pos_a.z = 0
			Pos_a.x = Pos_a.x *10
			Pos_a.y = Pos_a.y *10
			local Pos_b = self.target:GetPos() +Vector(0,0,10)
			Pos_b.z = 0
			Pos_b.x = Pos_b.x *10
			Pos_b.y = Pos_b.y *10
			local normal = (Pos_a -Pos_b):GetNormal()
			trace.endpos = (self.target:GetPos() +normal *movedist) +Vector(0,0,10)
		else
			trace.endpos = self.target:LocalToWorld( Vector( movedist, 0, 10 ) )
		end
		trace.filter = self.target

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			targetpos = tr.HitPos
		else
			if self.possess_viewmode == 1 then
				local Pos_a = self.target.possess_viewent:GetPos()
				Pos_a.z = 0
				Pos_a.x = Pos_a.x
				Pos_a.y = Pos_a.y
				local Pos_b = self.target:GetPos() +Vector(0,0,10)
				Pos_b.z = 0
				Pos_b.x = Pos_b.x
				Pos_b.y = Pos_b.y
				local normal = (Pos_b -Pos_a):GetNormal()
				targetpos = self.target:GetPos() +normal *movedist
			else
				targetpos = self.target:GetPos() +self.target:GetForward() *movedist
			end
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.target:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.target:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.target.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.target.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.possess_viewmode == 1 and self.master:KeyDown( 16 ) then
		local targetpos 
		local trace = {}
		trace.start = self.target:GetPos()
		if self.possess_viewmode == 1 then
			local trace_x = self.master:GetAimVector().x *2
			local trace_y = self.master:GetAimVector().y *2
			trace.endpos = self.target:LocalToWorld( Vector( trace_x, trace_y, 10 ) )
		else
			trace.endpos = self.target:LocalToWorld( Vector( -movedist, 0, 10 ) )
		end
		trace.filter = self.target
		
		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			targetpos = tr.HitPos
		else
			if self.possess_viewmode == 1 then
				targetpos = self.target:GetPos() +self.master:GetAimVector() *200
			else
				targetpos = self.target:GetPos() +self.target:GetForward() *-1 *movedist
			end
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.target:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.target:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.target.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.target.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.master:KeyDown( 512 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self.target:GetPos() +self.target.possess_viewent:GetRight() *-1 *120, walk )
		else
			MoveToTargetPos( self.target:GetPos() +self.target:GetRight() *-1 *1.3 +self.target:GetForward() *4 )
		end
	elseif self.master:KeyDown( 1024 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self.target:GetPos() +self.target.possess_viewent:GetRight() *120, walk )
		else
			MoveToTargetPos( self.target:GetPos() +self.target:GetRight() *1.3 +self.target:GetForward() *4 )
		end
	end
end

function ENT:Think()
	if !self.target or !ValidEntity( self.target ) or self.target:Health() <= 0 then
		self:EndPossession()
		return
	end
	if self.target:GetNPCState() != 0 then self.target:SetNPCState( 0 ) end
	if !self:PossessView() then return end
	self:Possess_SetViewVector()
	if (!self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay )) and !self.targetisburrowed then
		self.possession_allowdelay = nil
		self:PossessMovement( self.movedist )
		if !self.master then return end
		if self.master:KeyDown( 1 ) then
			if self.primattack_a and (!self.master:KeyDown( 4 ) or !self.primattack_b) then
				self:ChooseSchedule( true )
			elseif self.master:KeyDown( 4 ) and self.primattack_b then
				self:ChooseSchedule( false, true )
			end
		elseif self.master:KeyDown( 2048 ) then
			if self.secattack_a and (!self.master:KeyDown( 4 ) or !self.secattack_b) then
				self:ChooseSchedule( false, false, true )
			elseif self.master:KeyDown( 4 ) and self.secattack_b then
				self:ChooseSchedule( false, false, false, true )
			end
		end
	elseif self.targetisburrowed and self.master:KeyDown( 2048 ) then
		self:AddAttackDelay( self.secattack_a_delay )
		self.targetisburrowed = false
		self.target:Fire( "unburrow", "", 0 )
	end
end 

function ENT:Possess_SetViewVector()
	local Vec_a = self.target.possess_viewent:GetPos() *(self.master:GetAimVector( )*12)
	local Vec_b = self.target.possess_viewent:GetForward()
	self.master.aimvector = (Vec_a -Vec_b):Angle()
end

function ENT:ChooseSchedule( primattack_a, primattack_b, secattack_a, secattack_b )
	local class = self.target:GetClass()
	if class == "npc_zombine" or class == "npc_zombie" or class == "npc_zombie_torso" or class == "npc_fastzombie_torso" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.target:Fire( "PullGrenade", "", 0 )
		end
	elseif class == "npc_fastzombie" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.target:SetSchedule( 43 ) 
			self.target:SetLocalVelocity( self.target:GetForward() *1200 +Vector(0,0,280) )
		end
	elseif class == "npc_poisonzombie" or class == "npc_antlionguard" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.target:SetSchedule( 43 )
		end
	elseif class == "npc_headcrab" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 43 )
			//self.target:SetLocalVelocity( self.target:GetForward() *500 +Vector(0,0,240) )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.targetisburrowed = true
			self.target:Fire( "burrowimmediate", "", 0 )
		end
	elseif class == "npc_headcrab_fast" or class == "npc_headcrab_black" or class == "npc_headcrab_poison" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 43 )
		end
	elseif class == "npc_antlion" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		end
	elseif class == "npc_antlion_worker" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.target:SetSchedule( 43 )
		end
	elseif class == "npc_vortigaunt" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			self.target:SetSchedule( 43 )
		elseif secattack_b then
			self:AddAttackDelay( self.secattack_b_delay )
			local playerinrange
			for k, v in pairs( ents.FindInSphere( self.target:GetPos(), 256 ) ) do
				if ValidEntity( v ) and v:IsPlayer() and v:Health() > 0 then
					playerinrange = true
				end
			end
			if playerinrange then
				self.target:Fire( "enablearmorrecharge", "", 0 )
				self.target:Fire( "ChargeTarget", "!player", 0.1 )
			end
		end
	elseif class == "npc_strider" then
		if primattack_a then
			self:AddAttackDelay( self.primattack_a_delay )
			local bullseye = ents.Create( "scripted_target" )
			bullseye:SetKeyValue( "StartDisabled", "0" )
			bullseye:SetKeyValue( "m_iszEntity", "npc_strider" )

			bullseye:SetPos( self.target.possess_viewent:GetPos() +(self.master:GetAimVector( ) *-1 *8000) )
			bullseye:Spawn()
			bullseye:Activate()
			bullseye:SetName( tostring(self.target) .. "_bullseye" .. self:EntIndex() )
			
			self.target:Fire( "SetMinigunTarget", bullseye:GetName(), 0 )
			bullseye:Fire( "Kill", "", 0.15 )
		elseif primattack_b then
			self:AddAttackDelay( self.primattack_b_delay )
			local bullseye = ents.Create( "scripted_target" )
			bullseye:SetKeyValue( "StartDisabled", "0" )
			bullseye:SetKeyValue( "m_iszEntity", "npc_strider" )
			
			local trace = {}
			trace.start = self.target.possess_viewent:GetPos()
			trace.endpos = self.target.possess_viewent:GetPos() +(self.master:GetAimVector( ) *-1 *8000)
			trace.filter = self.target

			local tr = util.TraceLine( trace ) 
			bullseye:SetPos( tr.HitPos )
			bullseye:Spawn()
			bullseye:Activate()
			bullseye:SetName( tostring(self.target) .. "_bullseye" .. self:EntIndex() )
			
			self.target:Fire( "SetCannonTarget", bullseye:GetName(), 0.1 )
			bullseye:Fire( "Kill", "", 3.5 )
		//elseif secattack_a then
		//	self:AddAttackDelay( self.secattack_a_delay )
		//	self.target:SetSchedule( 41 )
		elseif secattack_a then
			self:AddAttackDelay( self.secattack_a_delay )
			if !self.target.crouching then
				self.target.crouching = true
				self.target:Fire( "Crouch", "", 0 )
				self.target.possess_viewpos = Vector( -140, 0, -60 )
				self.target.possess_addang = Vector(0,0,-75)
				self.target.possess_viewdistance = 150
				self.target.possess_viewheight = -150
			else
				self.target.crouching = false
				self.target:Fire( "Stand", "", 0 )
				self.target.possess_viewpos = Vector( -140, 0, 120 )
				self.target.possess_addang = Vector(0,0,-18)
				self.target.possess_viewdistance = 150
				self.target.possess_viewheight = 40
			end
		end
	end
end

function ENT:EndPossession()
	self.target.possessed = false
	
	self.target:SetNetworkedBool( 10, false )
	self.target:SetNetworkedEntity( 11, NULL )
	
	self.possession_allowdelay = nil
	if self.master and ValidEntity( self.master ) then self.master:GetTable().frozen = false; self.master:Spawn(); self.master:SetViewEntity( self.master ) end
	if self.possess_viewent and ValidEntity( self.possess_viewent ) then self.possess_viewent:Remove() end
	self.master = nil
	self:Remove()
end

function ENT:OnRemove()
end
