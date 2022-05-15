AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/stuka_bat.mdl"
ENT.MinDistance		= 100

ENT.SpawnRagdollOnDeath = false
ENT.FadeOnDeath = false
ENT.BloodType = "red"
ENT.Pain = true
ENT.DeathSkin = false
ENT.DeathSequence = true

ENT.possess_viewpos = Vector( -130, 0, 58 )
ENT.possess_addang = Vector(0,0,55)
ENT.possess_viewmode = 1

ENT.possess_viewdistance = 175
ENT.possess_viewheight = 75

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"npc/stukabat/stkb_fire1.wav"}
ENT.DSounds["Claw"] = {"npc/stukabat/stkb_fire2.wav"}
ENT.DSounds["ClawHit"] = {"npc/ichthyosaur/snap.wav"}
ENT.DSounds["ClawMiss"] = {"npc/ichthyosaur/snap_miss.wav"}
ENT.DSounds["Alert"] = {"npc/stukabat/stkb_deploy1.wav", "npc/stukabat/stkb_deploy2.wav"}
ENT.DSounds["Death"] = {"npc/stukabat/stkb_die1.wav"}
ENT.DSounds["Fly"] = {"npc/stukabat/stkb_flying1.wav"}
ENT.DSounds["Pain"] = {"npc/ichthyosaur/ichy_pain1.wav", "npc/ichthyosaur/ichy_pain2.wav", "npc/ichthyosaur/ichy_pain3.wav", "npc/ichthyosaur/ichy_pain4.wav"}
ENT.DSounds["Idle"] = {"npc/stukabat/stkb_idletpick1.wav", "npc/stukabat/stkb_idletpick2.wav", "npc/stukabat/stkb_idle1.wav"}

local schdAttackMelee = ai_schedule.New( "Attack Enemy" ) 
schdAttackMelee:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdTakeOff = ai_schedule.New( "TakeOff" ) 
schdTakeOff:EngTask( "TASK_PLAY_SEQUENCE", ACT_LEAP )

local schdLand = ai_schedule.New( "Land" ) 
schdLand:EngTask( "TASK_PLAY_SEQUENCE", ACT_LAND )

local schdHover = ai_schedule.New( "Hover" ) 
schdHover:EngTask( "TASK_PLAY_SEQUENCE", ACT_HOVER )

local schdFlySlow = ai_schedule.New( "Fly" ) 
schdFlySlow:EngTask( "TASK_PLAY_SEQUENCE", ACT_FLY )

local schdFlyFast = ai_schedule.New( "Fly to Enemy" ) 
schdFlyFast:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK2 )

local schdWander = ai_schedule.New( "Wander" ) 
schdWander:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 140 )
schdWander:EngTask( "TASK_WALK_PATH", 0 )

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_INNATE_MELEE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD )
	self:SetMaxYawSpeed( 5000 )


	if !self.health then
		self:SetHealth(sk_stukabat_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	self:InitSounds()
	
	self:SetUpEnemies({"player"})
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self:SetSchedule( 1 )
	self.init = true
	
	self.onground = true
	self:StartIdleTakeOffTimer()
	//timer.Simple(0.3, function() if ValidEntity(self) then self:TakeOff() end end)
end

function ENT:DmgAdd(dmg)
	local attacker = dmg:GetAttacker()
	if attacker:IsPlayer() then
		table.insert(self.enemyTable, "player")
		self:AddEntityRelationship( attacker, 1, 100 )
	end
end

function ENT:StartIdleTakeOffTimer()
	timer.Create(tostring(self) .. "_takeofftimer", math.Rand(8,80),1,function() if ValidEntity(self) then self:TakeOff() end end)
end

function ENT:StopIdleTakeOffTimer()
	timer.Destroy(tostring(self) .. "_takeofftimer")
end

function ENT:StartIdleLandTimer()
	timer.Create(tostring(self) .. "_landtimer", math.Rand(8,80),1,function() if ValidEntity(self) then self.trytoland = true end end)
end

function ENT:StopIdleLandTimer()
	self.trytoland = false
	timer.Destroy(tostring(self) .. "_landtimer")
end

function ENT:CanFlyTo(ent)
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = ent:GetPos()
	tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if trace.HitWorld then return false end
	return true
end

function ENT:Think()
	//self:ResetSequence(self:LookupSequence("Subtle_fidget_on_ground"))
	if GetConVarNumber("ai_disabled") == 1 or self:WaterLevel() > 0 or self.takeoff then self:SetLocalVelocity( Vector( 0, 0, 0 ) ); return end
	if self.landed then self:SetVelocity(self.oldvelocity) end
	if self.trytoland then self:LandStart() end
	if self.onground and !self.possessed then return end
	if self.dead then
		if !self.test then
			self:ClearSchedule() 
			self.test = true
		end
	
		self:SetAngles(Angle(0,self:GetAngles().y,0))
		/*if self:GetAngles().p != 0 or self:GetAngles().r != 0 then
			self:SetAngles( Angle( self:GetAngles().p /1.2, self:GetAngles().y, self:GetAngles().r /1.2 ) )
		end*/
		if !self:OnGround() then
			self:SetLocalVelocity( self:GetVelocity() /1.2 -Vector( 0, 0, 250 ) )
		else
			self:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
		return
	end
	if self.hover_back then
		local vlcity = (self:GetForward() *-1) *100 +self:GetUp() *45
		//if self:GetVelocity().x > 0 and self:GetVelocity().y > 0 then
		//	vlcity = vlcity +self:GetVelocity()
		//end
		self:SetLocalVelocity(vlcity)
		if CurTime() >= self.hover_back then
			self.hover_back = nil
		end
		return
	end
	
	//self:SwimToSurface()
	self.swimveloc = Vector( 0, 0, 0 )
	self:SelectSchedule()
	if !self.possessed then
		if ValidEntity(self.enemy) and !self:CanFlyTo(self.enemy) then self.enemy = nil end
		if ValidEntity( self.enemy ) and self.enemy:Health() > 0 and self:GetPos():Distance( self.enemy:GetPos() ) > self.MinDistance and !self.attacking then
			if self.enemy:WaterLevel() > 0 then self.enemy = NULL; return end
			self:UseEnemySwimMovement()
			//self:SelectSchedule()
		elseif self.enemy and ValidEntity( self.enemy ) and self.attacking then
			local enemy_pos = self.enemy:OBBCenter()
			local enemy_ang = self.enemy:GetAngles()
			local enemy_pos_center = self.enemy:GetPos() + enemy_ang:Up() * enemy_pos.z + enemy_ang:Forward() * enemy_pos.x + enemy_ang:Right() * enemy_pos.y
			local enemy_vec = (enemy_pos_center -self:GetPos()):GetNormalized()
			self:SetAngles( enemy_vec:Angle() )
			self.vel_divisor = 1.04
			local trace = {}
			trace.start = self:LocalToWorld( Vector( 0, 0, 120 ) )
			trace.endpos = self:GetPos()
			trace.mask = MASK_WATER
			trace.filter = self

			local tr = util.TraceLine( trace ) 
			if tr.HitWorld and trace.start != tr.HitPos and (self:GetPos():Distance( trace.start ) -trace.start:Distance( tr.HitPos )) <= 75 then
				self.vel_divisor = 1.4
			end
			self:SetLocalVelocity( self:GetVelocity() /self.vel_divisor )
			self.vel_divisor = nil
			
		elseif !ValidEntity( self.enemy ) then
			self:UseDefaultSwimMovement()
		end
	else
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.attacking and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			if self.onground then
				self:PossessMovement( 100 )
			else
				self:PossessMovementAir( 100 )
			end
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				self:Attack(true)
			elseif self.onground and !self.takeoff and self.master:KeyDown( 2048 ) then
				self:TakeOff()
				if self.possess_viewmode == 2 then
					self.allowswitchdelay = CurTime() +99999
					self.possess_viewmode = 1
					self.master:SetEyeAngles( self.possess_viewent:GetAngles() +Vector(0,180,0) )
				end
			elseif !self.onground and !self.landing and self.master:KeyDown( 2048 ) then
				self:LandStart()
				self.allowswitchdelay = CurTime() +2
			end
		end
		return
	end
	if self.efficient then return end
	
	self:ValidateRelationships()
	
	if self.possessed then
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.attacking and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			if self.onground then
				self:PossessMovementAir( 128 )
			else
				self:PossessMovementAir( 128 )
			end
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				self:Attack( true )
			end
		end
	end
end

function ENT:ChangeDirection( direction, degree, divisor )
	if direction == "left" then
		local turn_direction = ((self:GetRight() *-1) /12) +self:GetForward()
		self:SetLocalVelocity( turn_direction )
		self:SetAngles( turn_direction:GetNormal():Angle() )
	elseif direction == "right" then
		local turn_direction = (self:GetRight() /12) +self:GetForward()
		self:SetLocalVelocity( turn_direction )
		self:SetAngles( turn_direction:GetNormal():Angle() )
	elseif direction == "up" then
		//local turn_direction = (self:GetUp() /12) +self:GetForward()
		//self:SetLocalVelocity( turn_direction )
		//self:SetAngles( turn_direction:GetNormal():Angle() )
		
		//local hitnormal = tr.HitNormal
		//local hitnormal_ang = tr.HitNormal:Angle()
		
		if !self.forward then self.forward = self:GetForward() end
		//local swim_vec = (self.forward +Vector( 0, 0, 0.8 )):GetNormalized()
		//if self.forward:GetNormalized() +degree > self:GetForward():GetNormalized() +degree then
			local swim_vec = self:GetForward():GetNormalized() +(degree /12)
			self:SetAngles( swim_vec:Angle() )
			self:SetLocalVelocity( swim_vec *180 )
		//end
	elseif direction == "down" then
		if !self.forward then self.forward = self:GetForward() end
		local swim_vec = ((self:GetUp() *-1) /divisor) +self:GetForward()
		self:SetAngles( swim_vec:GetNormal():Angle() )
		self:SetLocalVelocity( swim_vec )
	end
end

function ENT:SwimToSurface()
	if self:WaterLevel() <= 1 then 
		self:SetLocalVelocity( self:WorldToLocal( Vector( 0, 1, 0 ) ):GetNormalized() *180 )
		return
	end
	
	if !self.forward then self.forward = self:GetForward() end
	local swim_vec = (self.forward +Vector( 0, 0, 0.8 )):GetNormalized()
	self:SetAngles( swim_vec:Angle() )
	self:SetLocalVelocity( swim_vec *180 )
end

function ENT:UseEnemySwimMovement()
	local ang_y = self:GetAngles().y -(self.enemy:GetPos() -self:GetPos()):Angle().y
	if ang_y > 180 then
		ang_y = ang_y -360
	elseif ang_y < -180 then
		ang_y = ang_y +360
	end
	if ang_y < -5 then
		self:ChangeDirection( "left" )
	end
	if ang_y > 5 then
		self:ChangeDirection( "right" )
	end
	
	/*local ang_p = self:GetAngles().p -(self.enemy:GetPos() -self:GetPos()):Angle().p
	if ang_p > 180 then
		ang_p = ang_p -360
	elseif ang_p < -180 then
		ang_p = ang_p +360
	end
	
	if ang_p < -5 and ang_y >= -5 and ang_y <= 5 then
		self:ChangeDirection( "down", false, 6 )
	end
	
	if ang_p > 5 then
		self:ChangeDirection( "up" )
	end*/
	
	local enemy_pos = self.enemy:OBBCenter()
	local enemy_ang = self.enemy:GetAngles()
	local enemy_pos_center = self.enemy:GetPos() + enemy_ang:Up() * enemy_pos.z + enemy_ang:Forward() * enemy_pos.x + enemy_ang:Right() * enemy_pos.y
	local swim_vec = (enemy_pos_center -self:GetPos()):GetNormalized()
	local ang = self:GetAngles()
	ang.p = swim_vec:Angle().p
	self:SetAngles(ang)
	
	if self:GetPos().z >= self.enemy:GetPos().z then
		self:SetLocalVelocity( self:GetForward() *350 )
		self:StartSchedule( schdFlyFast )
	else
		self:SetLocalVelocity( self:GetForward() *300 )
		self:StartSchedule( schdFlySlow )
	end
end

function ENT:UseDefaultSwimMovement()
	if self:Land() then return end
	// UP trace
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + Vector( 0, 0, 75 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		self.swimveloc = self.swimveloc + Vector( 0, 0, -50 )
		self.UpTrace = true
		self.tr_up_cur = CurTime() +math.Rand(0.6, 1.8)
		local tr_distance = self:GetPos():Distance( trace.start ) -trace.start:Distance( tr.HitPos )
		if !self.DownTrace and !self.ForwardTrace and tr_distance <= 120 and tr_distance > 76 then
			//local dir_normal = self:LocalToWorld( Vector( 50, 0, -40 ) )
			self:ChangeDirection( "down", false, 12 )
		elseif tr_distance <= 76 then
			//local dir_normal = ( self:LocalToWorld( Vector( 50, 0, -128 ) ) ):GetNormal()
			self:ChangeDirection( "down", false, 6 )
		end
	elseif self:GetAngles().p > 0.5 and self:GetAngles().p < 180 and ( ( self.tr_up_cur and CurTime() >= self.tr_up_cur ) or !self.tr_up_cur ) then
		self.tr_up_cur = nil
		self:SetAngles( Angle( (self:GetAngles().p -1.5), self:GetAngles().y, self:GetAngles().r ) )
		if self:GetAngles().p < 1 then
			self:SetAngles( Angle( 0, self:GetAngles().y, self:GetAngles().r ) )
		end
	end
	if !tr.HitWorld or trace.start == tr.HitPos then self.UpTrace = false end
		
	// DOWN trace
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + Vector( 0, 0, -75 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		if !self.UpTrace then
			self.swimveloc = self.swimveloc + Vector( 0, 0, 50 )
			self.DownTrace = true
			self:ChangeDirection( "up", tr.HitNormal )
			self.tr_down_cur = CurTime() +math.Rand(1.2, 2.2)
		/*else
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = self:LocalToWorld( Vector( 0, 380, 0 ) )
			trace.filter = self

			local tr_right = util.TraceLine( trace ) 
			trace.endpos = self:LocalToWorld( Vector( 0, -380, 0 ) )
			local tr_left = util.TraceLine( trace ) 
			if tr_right and !tr_left then
				self:TurnBack( "left" )	//direction
			elseif tr_left and !tr_right then
				self:TurnBack( "right" )
			elseif tr_right and tr_left then
				local Pos = self:GetPos()
				if Pos:Distance( tr_right.HitPos ) < Pos:Distance( tr_left.HitPos ) then
					self:TurnBack( "left" )
				else
					self:TurnBack( "right" )
				end
			else
				local rand = math.random(1,2)
				if rand == 1 then
					self:TurnBack( "right" )
				else
					self:TurnBack( "left" )
				end
			end*/
		end
	elseif self:GetAngles().p > 0.5 and self:GetAngles().p >= 180 and ( ( self.tr_down_cur and CurTime() >= self.tr_down_cur ) or !self.tr_down_cur ) then
		self.tr_down_cur = nil
		self:SetAngles( Angle( (self:GetAngles().p +1.5), self:GetAngles().y, self:GetAngles().r ) )
		if self:GetAngles().p > 359 then
			self:SetAngles( Angle( 0, self:GetAngles().y, self:GetAngles().r ) )
		end
	end
	if !tr.HitWorld then self.DownTrace = false end
		
	// BACKWARD trace
	/*local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos() + Vector( -380, 0, 0 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		self.swimveloc = self.swimveloc + Vector( 50, 0, 0 )
		self.BackwardTrace = true
	end*/ // No need for this?
		
	// LEFT trace
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:LocalToWorld( Vector( 0, 650, 0 ) )//self:GetPos() + Vector( 0, 380, 0 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		self.swimveloc = self.swimveloc + Vector( 0, -50, 0 )
		self.LeftTrace = true
		self.TurnRight = true
		self.LeftTraceRCur = CurTime() +2
	end
	
	if self.TurnRight and self.LeftTraceRCur <= CurTime() then
		self.TurnRight = false
	end
		
	// RIGHT trace
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:LocalToWorld( Vector( 0, -650, 0 ) )//self:GetPos() + Vector( 0, -380, 0 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		self.swimveloc = self.swimveloc + Vector( 0, 50, 0 )
		self.RightTrace = true
		self.TurnLeft = true
		self.RightTraceRCur = CurTime() +2
	end
	
	if self.TurnLeft and self.RightTraceRCur <= CurTime() then
		self.TurnLeft = false
	end
	/*if !self.TurnLeft and !self.TurnRight then
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:LocalToWorld( Vector( 0, -800, 0 ) )
		trace.filter = self

		local tr_right = util.TraceLine( trace ) 
	
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:LocalToWorld( Vector( 0, 800, 0 ) )
		trace.filter = self

		local tr_left = util.TraceLine( trace ) 
	
		if ( tr_right.HitWorld and tr_left.HitWorld ) then
			local Pos = self:GetPos()
			if Pos:Distance( tr_right.HitPos ) <= Pos:Distance( tr_left.HitPos ) then
				self.TurnLeft = true
				self.RightTraceRCur = CurTime() +2
			else
				self.TurnRight = true
				self.LeftTraceRCur = CurTime() +2
			end
		elseif ( !tr_right.HitWorld and !tr_left.HitWorld ) then
			local rand = math.random(1,2)
			if rand == 1 then
				self.TurnRight = true
				self.LeftTraceRCur = CurTime() +2
			else
				self.TurnLeft = true
				self.RightTraceRCur = CurTime() +2
			end
		elseif tr_right.HitWorld then
			self.TurnLeft = true
			self.RightTraceRCur = CurTime() +2
		elseif tr_left.HitWorld then
			self.TurnRight = true
			self.LeftTraceRCur = CurTime() +2
		end
	end*/
	
		if self.TurnLeft then
			self:ChangeDirection( "left" )
		elseif self.TurnRight then
			self:ChangeDirection( "right" )
		end
	
	// FORWARD trace
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:LocalToWorld( Vector( 380, 0, 0 ) )//self:GetPos() + Vector( 380, 0, 0 )
	trace.filter = self

	local tr = util.TraceLine( trace ) 
	if tr.HitWorld then 
		self.ForwardTrace = true
		if self.TurnLeft then
			self:ChangeDirection( "left" )
		elseif self.TurnRight then
			self:ChangeDirection( "right" )
		end
	else
		self.ForwardTrace = false
	end
	self:StartSchedule( schdFlySlow )
	self:SetLocalVelocity( self:GetForward() *150 )
	if !self.change_dir_delay then
		self.change_dir_delay = CurTime() +math.Rand(4,6)
	end
	if self.turndirection_y or self.change_dir_delay <= CurTime() then
		if self.ForwardTrace or self.DownTrace or self.UpTrace then
			self.change_dir_delay = nil
		else
			if !self.turndirection_y then
				self.turndegree = math.Rand(35, 80)
			end
			if self.RightTrace and !self.LeftTrace then
				self:TurnDirection( self.turndegree, "left" )
			elseif self.LeftTrace and !self.RightTrace then
				self:TurnDirection( self.turndegree, "right" )
			else	// if both or none??
				local rand = math.random(1,2)
				if rand == 1 then
					self:TurnDirection( self.turndegree, "left" )
				else
					self:TurnDirection( self.turndegree, "right" )
				end
			end
		end
	end
	self.LeftTrace = false
	self.RightTrace = false
end

function ENT:Land()
	if self.landing then
		if (self:GetAngles().p < 30 or self:GetAngles().p > 90) and !self.landed then
			local trace = {}
			trace.start = self:GetPos()
			local ang = self:GetAngles()
			ang.p = 30
			trace.endpos = self:GetPos() +ang:Forward() *8000
			trace.filter = self

			local function CheckNormal(normal)
				if normal.x <= 0.0003 and normal.y <= 0.0003 and normal.z <= 1 and normal.x >= -0.0003 and normal.y >= -0.0003 and normal.z >= 0.98 then return true else return false end
			end
			
			local tr = util.TraceLine( trace ) 
			if tr.HitWorld and CheckNormal(tr.HitNormal) then
				self:ChangeDirection( "down", false, 6 )
				self:SetLocalVelocity( self:GetForward() *300 )
			else
				self.landing = false
				return true
			end
			self:StartSchedule( schdFlyFast )
		elseif !self.onground and !self.landed then
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = self:GetPos() -Vector(0,0,180)
			trace.filter = self

			local tr = util.TraceLine( trace ) 
			if tr.HitWorld then
				local ang = self:GetAngles()
				ang.p = 0
				ang.r = 0
				self:SetAngles(ang)
				self:LandEnd()
			end
		end
		return true
	end
	return false
end

function ENT:PossessMovementAir( movedist )
	if self.onground or self:Land() then return end
	local function MoveToTargetPos( pos, walk )
		local swim_vec = (pos -self:GetPos()):GetNormalized()
		if self:GetAngles().p > 30 or self:GetAngles().p < 90 then
			self:SetLocalVelocity( swim_vec *350 )
			self:StartSchedule( schdFlyFast )
		else
			self:SetLocalVelocity( swim_vec *300 )
			self:StartSchedule( schdFlySlow )
		end
		self:SetAngles( swim_vec:Angle() )
	end
	if self.master:KeyDown( 8 ) then
		if self.possess_viewmode == 1 then
			local Pos_a = self.possess_viewent:GetPos()
			local Pos_b = self:GetPos()
			local normal = (Pos_b -Pos_a):GetNormal()
			targetpos = self:GetPos() +normal *movedist
		else
			targetpos = self:GetPos() +self:GetForward() *movedist
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.possess_viewmode == 1 and self.master:KeyDown( 16 ) then
		local targetpos 
		local trace = {}
		trace.start = self:GetPos()
		if self.possess_viewmode == 1 then
			local trace_x = self.master:GetAimVector().x *2
			local trace_y = self.master:GetAimVector().y *2
			trace.endpos = self:LocalToWorld( Vector( trace_x, trace_y, 10 ) )
		else
			trace.endpos = self:LocalToWorld( Vector( -movedist, 0, 10 ) )
		end
		trace.filter = self
		
		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			targetpos = tr.HitPos
		else
			if self.possess_viewmode == 1 then
				targetpos = self:GetPos() +self.master:GetAimVector() *200
			else
				targetpos = self:GetPos() +self:GetForward() *-1 *movedist
			end
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.master:KeyDown( 512 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self:GetPos() +self.possess_viewent:GetRight() *-1 *120, walk )
		else
			MoveToTargetPos( self:GetPos() +self:GetRight() *-1 *1.3 +self:GetForward() *4 )
		end
	elseif self.master:KeyDown( 1024 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self:GetPos() +self.possess_viewent:GetRight() *120, walk )
		else
			MoveToTargetPos( self:GetPos() +self:GetRight() *1.3 +self:GetForward() *4 )
		end
	end
	self:SetAngles(Angle((self.possess_viewent:GetAngles().p -180) *-1,self.possess_viewent:GetAngles().y -180,0))
	if self:GetAngles().p < -90 then
		self:SetLocalVelocity( self:GetForward() *350 )
		self:StartSchedule( schdFlyFast )
	else
		self:SetLocalVelocity( self:GetForward() *300 )
		self:StartSchedule( schdFlySlow )
	end
end

function ENT:TurnDirection( degree, direction )
	if direction == "left" and !self.turndirection then
		self.turndirection_y = self:GetAngles().y +degree
	elseif direction == "right" and !self.turndirection then
		self.turndirection_y = self:GetAngles().y -degree
	end
	
	if direction == "right" and self:GetAngles().y >= self.turndirection_y then
		self:SetAngles( Angle( self:GetAngles().p, ( self:GetAngles() +Angle( 0, 1.5, 0 ) ).y, self:GetAngles().r ) )
		return true
	elseif direction == "left" and self:GetAngles().y <= self.turndirection_y then
		self:SetAngles( Angle( self:GetAngles().p, ( self:GetAngles() -Angle( 0, 1.5, 0 ) ).y, self:GetAngles().r ) )
		return true
	else
		self.turndegree = nil
		self.turndirection_y = nil
		return false
	end
end

function ENT:LandStart()
	local trace = {}
	trace.start = self:GetPos()
	local ang = self:GetAngles()
	ang.p = 30
	trace.endpos = self:GetPos() +ang:Forward() *8000
	trace.filter = self

	local function CheckNormal(normal)
		if normal.x <= 0.0003 and normal.y <= 0.0003 and normal.z <= 1 and normal.x >= -0.0003 and normal.y >= -0.0003 and normal.z >= 0.98 then return true else return false end
	end
			
	local tr = util.TraceLine( trace ) 
	if !tr.HitWorld or !CheckNormal(tr.HitNormal) then return end
	self.trytoland = false
	self.landed = false
	self.landing = true
end

function ENT:LandEnd()
	self.oldvelocity = self:GetVelocity()
	self.landed = true
	self:StartSchedule( schdLand )
	//self:SetNPCState( NPC_STATE_ALERT )
	timer.Simple(0.6, function() if ValidEntity(self) then self.landing = false; self.landed = false; self.onground = true; self.oldvelocity = nil; self:SetMoveType( MOVETYPE_STEP ); self:StartIdleTakeOffTimer() end end)
end

function ENT:TakeOff()
	self:StopMoving()
	self:SetMoveType( MOVETYPE_FLY )
	self.takeoff = true
	self:StartSchedule( schdTakeOff )
	self.onground = false
	timer.Simple(2.5, function() if self and ValidEntity(self) then self.takeoff = false; self:SetPos(self:GetPos() +Vector(0,0,10)); self:StartIdleLandTimer(); end end)
end

function ENT:Attack( poss )
	self.attacking = true
	self.idle = 0
	//self:SetLocalVelocity( self:GetVelocity() /2 )
	self:StartSchedule( schdAttackMelee )

	self:PlayRandomSound("Claw")

	local function attack_dmg()
		local victim = ents.FindInBox( self:LocalToWorld(Vector( 28, 33, -16 )), self:LocalToWorld(Vector( 67, -30, 35 )) )
		for k, v in pairs(victim) do
			if( ( ( ( v:IsPlayer() and v:Alive() ) or v:IsNPC() ) and ( self:Disposition( v ) == 1 or self:Disposition( v ) == 2 ) ) or v:GetClass() == "prop_physics" ) then
				if v:IsNPC() and v:Health() - sk_stukabat_claw_value <= 0 then
					self.killicon_ent = ents.Create( "sent_killicon" )
					self.killicon_ent:SetKeyValue( "classname", "sent_killicon_stukabat" )
					self.killicon_ent:Spawn()
					self.killicon_ent:Activate()
					self.killicon_ent:Fire( "kill", "", 0.1 )
					self.attack_inflictor = self.killicon_ent
				else
					self.attack_inflictor = self
				end
				v:TakeDamage( sk_stukabat_claw_value, self, self.attack_inflictor )  
				if v:IsPlayer() then
					v:SetEyeAngles( Angle( ( v:GetAimVector():Angle().p +math.Rand(-20,20) ), ( v:GetAimVector():Angle().y +math.Rand(-20,20) ), 0 ) ) //Angle( 0, math.Rand(-40,40), 0 ).y
				end
			end
		end
		
		self.hover_back = CurTime() +1
		self:StartSchedule(schdHover)
		
		local function attack_end()
			self.attacking = false
			
			if !ValidEntity(self.enemy) then
				self:StartIdleLandTimer()
			end
		end
		timer.Create( "attack_end_timer" .. self.Entity:EntIndex( ), 0.3, 1, attack_end )
	end
	timer.Create( "attack_blastdelay_timer" .. self.Entity:EntIndex( ), 0.4, 1, attack_dmg )
	if poss then self.possession_allowdelay = CurTime() +1.4 end
end

function ENT:AcceptInput( cvar_name, activator, caller )
	if cvar_name == "setsquad" then
		timer.Simple( 0.01, function() self.squad = self:GetKeyValue( self, "squadname" ); self:SetupSquad() end )
		self.squadtable = {}
	end
	if cvar_name == "land" then
		self:LandStart()
	end
	if cvar_name == "takeoff" then
		self:TakeOff()
	end
	if( string.find( cvar_name,"followtarget_" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) and !self.following ) then
		self.follow_target_string = string.Replace(cvar_name,"followtarget_","") 
		if( self.follow_target_string != "!self" and !string.find( cvar_name,"followtarget_!player" ) ) then
			self.follow_target_t = ents.FindByName( self.follow_target_string )
		elseif( self.follow_target_string == "!self" ) then
			if ValidEntity( caller ) then
				self.follow_target = caller
			end
		elseif( string.find( cvar_name,"followtarget_!player" ) ) then
			if( self.follow_target_string == "!player" ) then
				self.follow_closest_range = 9999
				for k, v in pairs( player:GetAll() ) do
					self.follow_closest = v:GetPos():Distance( self:GetPos() )
					if( self.follow_closest < self.follow_closest_range ) then
						self.follow_closest_range = v:GetPos():Distance( self:GetPos() )
						self.follow_target = v
					end
				end
			else
				self.follow_target_userid = string.Replace(cvar_name,"followtarget_!player","") 
				for k, v in pairs( player:GetAll() ) do
					if( tostring(v:UserID( )) == self.follow_target_userid ) then
						self.follow_target = v
					end
				end
			end
		end
		
		if( self.follow_target or ( self.follow_target_t and table.Count( self.follow_target_t ) == 1 ) ) then
			self.following = true
			if !ValidEntity( self.follow_target ) and self.follow_target_t then
				for k, v in pairs( self.follow_target_t ) do
					if( v != self ) then
						self.follow_target = v
					else
						self.following = false
						caller:PrintMessage( HUD_PRINTCONSOLE, "Can't follow itself! \n" )
					end
				end
			end
			
			if( self.follow_target:IsPlayer() or self.follow_target:IsNPC() ) then
				self.following_disp = self:Disposition( self.follow_target )
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
		elseif( self.follow_target_t and table.Count( self.follow_target_t ) > 1 ) then
			self.following = true
			self.follow_closest_range = 9999
			for k, v in pairs( self.follow_target_t ) do
				self.follow_closest = v:GetPos():Distance( self:GetPos() )
				if( self.follow_closest < self.follow_closest_range ) then
					if( v != self ) then
						self.follow_closest_range = v:GetPos():Distance( self:GetPos() )
						self.follow_target = v
					end
				end
			end
				
			if( self.follow_target:IsPlayer() or self.follow_target:IsNPC() ) then
				self.following_disp = self:Disposition( self.follow_target )
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
		elseif caller:IsPlayer() then
			caller:PrintMessage( HUD_PRINTCONSOLE, "No entity called '" .. self.follow_target_string .. "' found! \n" )
		end
	end
	
	if( cvar_name == "stopfollowtarget" and self.following and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self.following = false
		if self.following_disp then
			self:AddEntityRelationship( self.follow_target, self.following_disp, 10 )
		end
		timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
		self:StartSchedule( schdReset )
		self.follow_target = NULL
	end
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end

	local convar_ai = GetConVarNumber("ai_disabled")
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.attacking and !self.hover_back and convar_ai == 0 ) then
		self:StopIdleTakeOffTimer()
		self:StopIdleLandTimer()
		if !self.searchdelay then
			self.searchdelay = CurTime() +0.15
		end
		local enemy_tbl
		if self.searchdelay < CurTime() then
			enemy_tbl = self:FindInCone( 9999 )
			self.searchdelay = nil
		end
		if enemy_tbl then self:UpdateMemory(enemy_tbl) end
		local Pos = self:GetPos()
		if self.enemy then self:CheckEnemy( 1 ) end
		if self.enemy_fear then self:CheckEnemy( 3 ) end
		if self.onground and ValidEntity(self.enemy) then
			if !self.takeoff then
				self:TakeOff()
			end
			return
		end
		if( self.enemy and ValidEntity( self.enemy ) and self.enemy:GetPos():Distance( self:GetPos() ) <= self.closest_range ) then
			local enemy_inrange
			if self.enemy:GetPos():Distance( Pos ) < self.MinDistance then
				enemy_inrange = true
			else
				local tracedata = {}
				tracedata.start = self:GetPos()
				tracedata.endpos = self:GetPos() +(self:LocalToWorld(self:GetVelocity()) -self:GetPos()):GetNormal() *300
				tracedata.filter = self
				local trace = util.TraceLine(tracedata) 
				if trace.Entity and trace.Entity == self.enemy then enemy_inrange = true end
			end
			if( enemy_inrange and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:Attack()
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 800 ) or !self.following ) then
				timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
				self:SetEnemy( self.enemy, true )
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				//self:StartSchedule( schdChase )
			end
		elseif( ( !self.enemy or !ValidEntity(self.enemy) ) and self.enemy_fear and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			//self:StartSchedule( schdHide ) 
		else
			self.closest_range = 9999
		end
		
	self:SetEnemy( NULL )	
	elseif( self.idle == 0 and convar_ai == 0 ) then
		self.idle = 1
		self:SetSchedule( SCHED_IDLE_STAND )
		self:SelectSchedule()
	elseif( !self.FoundEnemy and !self.FoundEnemy_fear and table.Count( self.table_fear ) > 0 ) then
		local enemies = ents.FindByClass( "npc_*" ) 
		table.Add( enemies, ents.FindByClass( "monster_*" ) )
		table.Add( enemies, player.GetAll() )
		for i, v in ipairs(enemies) do
			if( v:Health() > 0 and self:Disposition( v ) == 3 and !self:HasCondition( 7 ) ) then
				if( table.HasValue( self.table_fear, v ) ) then
					self:AddEntityRelationship( v, 2, 10 )
					local table_en_li = {}
					local en_li = v
					for k, v in pairs( self.table_fear ) do
						if( v != en_li ) then
							table.insert( table_en_li, v )
						end
					end
					self.table_fear = table_en_li
				end
			end
		end
	end
	
	if( self.following ) then
		if ValidEntity( self.follow_target ) then
			if( self:Disposition( self.follow_target ) != 3 ) then
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
			
			if( self:GetPos():Distance( self.follow_target ) > 175 and ( ( ValidEntity( self.enemy ) and self.enemy != self.follow_target and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) > 800 ) or !ValidEntity( self.enemy ) ) and !self.attacking and convar_ai == 0 ) then
						self:SetEnemy( self.follow_target, true )
						self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
						//self:StartSchedule( schdFollow )
						//timer.Create( "self_select_schedule_timer" .. self:EntIndex(), 1, 1, function() self:StartSchedule( schdReset ) end )
			elseif( self.enemy == self.follow_target ) then
				self.enemy = NULL
			end
		else
			self.following = false
			self.follow_target = NULL
		end
	end
	
	local function play_idle()	
		local convar_ai = GetConVarNumber("ai_disabled")
		if( convar_ai == 0 and !self.possessed ) then
			self:PlayRandomSound("Idle")
			
			if !self.TurnLeft and !self.TurnRight and !self.onground then
				local trace = {}
				trace.start = self:GetPos()
				trace.endpos = self:LocalToWorld( Vector( 0, -800, 0 ) )
				trace.filter = self

				local tr_right = util.TraceLine( trace ) 
			
				local trace = {}
				trace.start = self:GetPos()
				trace.endpos = self:LocalToWorld( Vector( 0, 800, 0 ) )
				trace.filter = self

				local tr_left = util.TraceLine( trace ) 
				
				local Pos = self:GetPos()
				local distance_r = Pos:Distance( tr_right.HitPos )
				local distance_l = Pos:Distance( tr_left.HitPos )
				local turn_time = math.Rand(0.8,2.4)
				if distance_r < 790 and distance_l < 790 then
					if distance_l >= distance_r then
						self.TurnLeft = true
						self.RightTraceRCur = CurTime() +turn_time
					else
						self.TurnRight = true
						self.LeftTraceRCur = CurTime() +turn_time
					end
				else
					local rand = math.random(1,2)
					if rand == 1 then
						self.TurnRight = true
						self.LeftTraceRCur = CurTime() +turn_time
					else
						self.TurnLeft = true
						self.RightTraceRCur = CurTime() +turn_time
					end
				end
			elseif self.onground then
				self:StartSchedule( schdWander )
			end
		end
		timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
	end
	
	if( ( !self.enemy or !ValidEntity( self.enemy ) ) and convar_ai == 0 and !self.attacking ) then
		if( !self.timer_created ) then
			self.timer_created = true
			timer.Create( "wandering_timer" .. self:EntIndex( ), math.random(7,10), 1, play_idle )
		end
	end
end 


/*---------------------------------------------------------
Name: OnRemove
Desc: Called just before entity is deleted
//-------------------------------------------------------*/
function ENT:OnRemove()
	self:StopSounds()
	self:EndPossession()
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "entity_index_remove_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_blastdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "self.ghide_reset_timer" .. self.Entity:EntIndex( ) )
end