AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/controller.mdl"
ENT.RangeDistance		= 1250 // def: 1250

ENT.SpawnRagdollOnDeath = true
ENT.FadeOnDeath = false
ENT.BloodType = "yellow"
ENT.Pain = true
ENT.DeathSkin = false

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"npc/controller/con_attack1.wav", "npc/controller/con_attack2.wav", "npc/controller/con_attack3.wav"}
ENT.DSounds["Alert"] = {"npc/controller/con_alert1.wav", "npc/controller/con_alert2.wav", "npc/controller/con_alert3.wav"}
ENT.DSounds["Death"] = {"npc/controller/con_die1.wav", "npc/controller/con_die2.wav"}
ENT.DSounds["Pain"] = {"npc/controller/con_pain1.wav", "npc/controller/con_pain2.wav", "npc/controller/con_pain3.wav"}
ENT.DSounds["Idle"] = {"npc/controller/con_idle1.wav", "npc/controller/con_idle2.wav", "npc/controller/con_idle3.wav", "npc/controller/con_idle4.wav", "npc/controller/con_idle5.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdRangeAttack_a = ai_schedule.New( "Attack Enemy range a" ) 
schdRangeAttack_a:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_a:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdRangeAttack_b = ai_schedule.New( "Attack Enemy range b" ) 
schdRangeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_b:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK2 )

local schdRecharge = ai_schedule.New( "Recharge" ) 
schdRecharge:EngTask( "TASK_STOP_MOVING", 0 )
schdRecharge:AddTask( "PlaySequence", { Name = "idle2", Speed = 1 } )

local schdWandering = ai_schedule.New( "Wander" ) 
schdWandering:AddTask( "wandering" )
schdWandering:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 384 )
schdWandering:EngTask( "TASK_WALK_PATH", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

//local schdFlyUp = ai_schedule.New( "Fly up" ) 
//schdFlyUp:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_CONTROLLER_UP )

local schdDodge = ai_schedule.New( "Dodge" ) 
schdDodge:EngTask( "TASK_FIND_BACKAWAY_FROM_SAVEPOSITION", 0 ) 

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_SMALL_FLINCH", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

local schdIdle = ai_schedule.New( "Idle" ) 
schdIdle:EngTask( "TASK_STOP_MOVING", 0 )
schdIdle:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_IDLE )

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_FLY )

	self:CapabilitiesAdd( CAP_MOVE_FLY | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD | CAP_SKIP_NAV_GROUND_CHECK )

	self:SetMaxYawSpeed( 10 )

	if !self.health then
		self:SetHealth(sk_controller_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	if !self.h_flyspeed then
		self.h_flyspeed = sk_controller_fly_speed_value
	end
	
	self:SetUpEnemies( {"monster_alien_grunt", "monster_alien_slave", "monster_nihilanth"} )
	//self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }

	self:InitSounds()
	
	self.enemyTable_enemies_e = {}
	
	self:SetSchedule( 1 )
	self.init = true
	self.energy = 0
	self.forces = {}
	self.damagelevel = 0
end

function ENT:ActivateShield()
	self.shieldeffect = ents.Create( "info_particle_system" )
	self.shieldeffect:SetKeyValue( "effect_name", "Advisor_Psychic_Shield_Idle" )
	self.shieldeffect:SetKeyValue( "start_active", "1" )
	self.shieldeffect:SetPos(self:GetPos() +Vector(0,0,40))
	self.shieldeffect:SetParent(self)
	self.shieldeffect:Spawn()
	self.shieldeffect:Activate() 
	self.shieldactive = true
end

function ENT:DeactivateShield()
	if ValidEntity(self.shieldeffect) then self.shieldeffect:Remove() end
	self.shieldactive = false
end

function ENT:CanRecharge()
	local Ents = ents.FindByClass("nihilanth_crystal")
	if #self.forces < 2 and #Ents > 0 then
		local visible
		
		for k, v in pairs(Ents) do
			local tracedata = {}
			tracedata.start = self:GetPos()
			tracedata.endpos = v:GetPos() +Vector(0,0,20)
			tracedata.filter = {self}
			local trace = util.TraceLine(tracedata)
			if ValidEntity(trace.Entity) and trace.Entity == v then visible = true end
		//	if self:Visible( v ) /*and v:GetPos():Distance(self) <= 5000*/ then visible = true end
		end
		if visible then return true else return false end
	else return false end
end

function ENT:Recharge()
	self.idledelay = CurTime() +3.401
	self:PlayRandomSound("Attack")
	
	self:StartSchedule(schdRecharge)
	self.attacking = true
	
	if !self.shieldactive then self:ActivateShield() end
	
	local crystals = {}
	for k, v in pairs(ents.FindByClass("nihilanth_crystal")) do
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = v:GetPos() +Vector(0,0,20)
		tracedata.filter = {self}
		local trace = util.TraceLine(tracedata)
		if ValidEntity(trace.Entity) and trace.Entity == v then table.insert(crystals,v) end
		//if self:Visible(v) then
		//	table.insert(crystals,v)
		//end
	end
	if #crystals == 0 then self.attacking = false; return end
	
	local frcpercrystal = math.ceil((2 -#self.forces) /#crystals)
	for k, v in pairs(crystals) do
		if #self.forces < 2 then
			local delay = 0
			for i = 1, frcpercrystal do
				timer.Simple(delay, function() if ValidEntity(self) and ValidEntity(v) and #self.forces < 2 then
				local e_ball = ents.Create("nihilanth_force")
				e_ball:SetPos( v:GetPos() +Vector(0,0,60) )
				e_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
				e_ball.owner = self
				e_ball:SetOwner(self)
				e_ball.radius = math.random(40,60)
				e_ball.height = math.random(40,60)
				e_ball.speed = math.random(100,200)
				e_ball.delay = math.Rand(0,6)
				e_ball.scale = 0.4
				
				local rand = math.random(1,2)
				if rand == 1 then
					e_ball.direction = "right"
				else
					e_ball.direction = "left"
				end
				
				e_ball:SetMoveCollide( 3 )
				e_ball:Spawn()
				local phys = e_ball:GetPhysicsObject()
					phys:SetMass( 1 )
					phys:EnableGravity( false )
					phys:EnableDrag( false )
					
				table.insert(self.forces, e_ball)
				self.damagelevel = 2 -#self.forces
				self.energy = (#self.forces /2) *150
				end end)
				delay = delay +0.15
			end
		end
	end
	timer.Simple(3.44, function() if ValidEntity(self) then self.attacking = false end end)
end

function ENT:RemoveForce(frc)
	local tbl_new = {}
	for k, v in pairs(self.forces) do
		if v != frc then
			table.insert(tbl_new,v)
		else
			//v:Absorb()
			v:Remove()
		end
	end
	self.forces = tbl_new
end

function ENT:FlyToPos( Vec, Speed, x, y, z )
	local Entity_pos = self:GetPos()
	if x == 0 then
		Entity_pos.x = 0
	end
	if y == 0 then
		Entity_pos.y = 0
	end
	if z == 0 then
		Entity_pos.z = 0
	end
	local normal = (Vec - Entity_pos):GetNormalized() *Speed
	self:SetLocalVelocity( normal )
end

/*function ENT:FlySchedule( schedule )
	if !self.started_flyschedule then
		self.started_flyschedule = true
		self:StartSchedule( schedule )
		timer.Create( "self.started_flyschedule_reset_timer" .. self:EntIndex(), 3, 1, function() self.started_flyschedule = false end )
	end
end*/

function ENT:Think()
	if GetConVarNumber("ai_disabled") == 1 then return end

	if self.idledelay and CurTime() >= self.idledelay then
		self.idledelay = CurTime() +2.067
		self:StartSchedule(schdIdle)
	end
	
	if self.flytarget then
		if self.h_flytarget and ValidEntity( self.h_flytarget ) then
			if self:GetPos():Distance( self.h_flytarget:GetPos() ) <= 5 then
				local path_keyvalues = self.h_flytarget:GetKeyValues()
				for k, v in pairs( path_keyvalues ) do
					if k == "target" then
						if v then
							self.h_flytarget_n = v
							self.h_flytarget = ents.FindByName( self.h_flytarget_n )[1]
						else
							self.flytarget = false
						end
					end
				end
			end
			if self.flytarget and self.h_flytarget then
				self:FlyToPos( self.h_flytarget:GetPos(), self.h_flyspeed, 1, 1, 1 )
			end
		else
			self.flytarget = false
		end
	end
	
	if self.following or self.flytarget then return end
	self.flyveloc = Vector( 0, 0, 0 )
	if ValidEntity( self.enemy ) and self.FoundEnemy then
		self.enemy_dist = Vector( 0, 0, 0 )

		local self_enemy_pos = self.enemy:GetPos()
		local self_pos = self:GetPos()
		if self_enemy_pos.z < 0 and self_pos.z < 0 then
			self_enemy_pos.z = self_enemy_pos.z /-1
			self_pos.z = self_pos.z /-1
		end
		if( ( self_pos.z - self_enemy_pos.z ) < 150 ) then
			self.enemy_dist.z = 125
			self_enemy_pos.z = 0
		elseif( ( self_pos.z - self_enemy_pos.z ) > 200 ) then
			self.enemy_dist.z = -125
			self_enemy_pos.z = 0
			local c_veloc = self:GetVelocity()
			if c_veloc.z > 0 then
				c_veloc.z = 0				// temporary fix for the fly-to-the-sky bug
			end
			self:SetLocalVelocity( c_veloc )
		elseif( ( self_pos.z - self_enemy_pos.z ) >= 150 and ( self_enemy_pos.z - self_pos.z ) <= 200 ) then
			self.enemy_dist.z = 0
			self_enemy_pos.z = 0
		end
		local self_pos_xy = self:GetPos()
		self_pos_xy.z = 0
		local self_enemy_pos_xy = self.enemy:GetPos()
		self_enemy_pos_xy.z = 0
		local dist = self_pos_xy:Distance( self_enemy_pos_xy )
		if dist < 300 then
			self_enemy_pos.x = 0
			self_enemy_pos.y = 0
			self.enemy_dist.x = 0
			self.enemy_dist.y = 0
		elseif dist < 200 and ( self_pos.z - self_enemy_pos.z ) < 200 then
			self.test = true
			self:SetLocalVelocity( (self:GetPos() - self_enemy_pos):GetNormalized() *160  )
		end
		if dist > 380 and !self.test then
			self:FlyToPos( ( self_enemy_pos + self.enemy_dist ), self.h_flyspeed, 1, 1, 0 )
		end
		self.test = nil
	else
		// UP trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, 0, 380 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, 0, -50 )
		end
		
		// DOWN trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, 0, -380 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, 0, 50 )
			//self:FlySchedule( schdFlyUp )
		end

		// FORWARD trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 380, 0, 0 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( -50, 0, 0 )
		end
		
		// BACKWARD trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( -380, 0, 0 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 50, 0, 0 )
		end
		
		// LEFT trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, 380, 0 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, -50, 0 )
		end
		
		// RIGHT trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, -380, 0 )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, 50, 0 )
		end
		self:SetLocalVelocity( self.flyveloc )
	end
	
	if self.efficient then return end
	self:ValidateRelationships()
end

function ENT:Attack_Range_a()
	self.idledelay = CurTime() +3.401
	self:PlayRandomSound("Attack")
	
	local function lAttak( tar )
		if !tar:IsValid() then 
			self.attacking = false
			for k, v in pairs( self.sprite_table ) do
				v:Remove()
			end
		return end
		
		local FireTrace = ((self.enemy:GetPos() + Vector(0,0,10)) - self:GetPos())
		local Firevector = FireTrace:GetNormalized()
		local FireLength = FireTrace:Length()
		local ArriveTime = FireLength / 2000
		local BaseShootVector = Firevector * 2000 + Vector(0,0,300 * ArriveTime)
		controller_disposition = self:Disposition( self.enemy )
		
		self.c_ball_count = 0
		local function c_ball_spawn( Vec )
			if self.enemy and ValidEntity( self.enemy ) then
				local c_ball = ents.Create("controller_ball_fire")
				c_ball:SetPos( Vec )
				c_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
				c_ball.owner = self
				c_ball.Speed = 115
				c_ball:SetMoveCollide( 3 )
				c_ball.enemy = self.enemy
				c_ball:SetOwner( self )
				c_ball:Spawn()
				local phys = c_ball:GetPhysicsObject()
					phys:SetMass( 1 )
					phys:EnableGravity( false )
					phys:EnableDrag( false )
					phys:ApplyForceCenter( ( self.enemy:GetPos() - self:GetPos() ):GetNormal() * 1000 )
			end
		end
		local rand = math.random(4,8)
		c_ball_spawn( self:LocalToWorld( Vector( 30, 0, 30 ) ) )
		timer.Create("C_Ball1_timer" .. self.Entity:EntIndex( ), 0.1, 1, c_ball_spawn, self:LocalToWorld( Vector( 25, 0, 27 ) ) )
		timer.Create("C_Ball2_timer" .. self.Entity:EntIndex( ), 0.2, 1, c_ball_spawn, self:LocalToWorld( Vector( 28, 0, 33 ) ) )
		if rand >= 4 then
			timer.Create("C_Ball3_timer" .. self.Entity:EntIndex( ), 0.3, 1, c_ball_spawn, self:LocalToWorld( Vector( 27, 0, 30 ) ) )
		end
		if rand >= 5 then
			timer.Create("C_Ball4_timer" .. self.Entity:EntIndex( ), 0.4, 1, c_ball_spawn, self:LocalToWorld( Vector( 31, 0, 32 ) ) )
		end
		if rand >= 6 then
			timer.Create("C_Ball5_timer" .. self.Entity:EntIndex( ), 0.5, 1, c_ball_spawn, self:LocalToWorld( Vector( 25, 0, 26 ) ) )
		end
		if rand >= 7 then
			timer.Create("C_Ball6_timer" .. self.Entity:EntIndex( ), 0.6, 1, c_ball_spawn, self:LocalToWorld( Vector( 29, 0, 32 ) ) )
		end
		if rand == 8 then
			timer.Create("C_Ball7_timer" .. self.Entity:EntIndex( ), 0.7, 1, c_ball_spawn, self:LocalToWorld( Vector( 30, 0, 30 ) ) )
		end
		
		local function attack_end()
			self.attacking = false
			for k, v in pairs( self.sprite_table ) do
				v:Remove()
			end
		end
		timer.Create("attack_end_timer" .. self.Entity:EntIndex( ), 0.7, 1, attack_end )
	end
	timer.Create( "range_attack_end_timer" .. self.Entity:EntIndex( ), 2.3, 1, lAttak, self.enemy )
	self.sprite_count = 0
	self.sprite_table = {}
	local function c_ball_sprites()
		self.sprite_count = self.sprite_count +1
		local sprite = ents.Create( "env_sprite" )
		sprite:SetKeyValue( "rendermode", "9" )
		sprite:SetKeyValue( "rendercolor", "255 141 15" )
		sprite:SetKeyValue( "model", "sprites/orangecore2.spr" )
		sprite:SetKeyValue( "scale", "0.4" )
		sprite:SetKeyValue( "spawnflags", "1" )
		sprite:SetPos( self:GetPos() )
		sprite:Spawn()
		sprite:Activate()
		sprite:SetParent( self )
		if self.sprite_count == 1 then
			sprite:Fire( "SetParentAttachment", "2", 0 )
			c_ball_sprites()
		else
			sprite:Fire( "SetParentAttachment", "3", 0 )
		end
		table.insert( self.sprite_table, sprite )
	end
	timer.Create( "range_attack_sprite_timer" .. self.Entity:EntIndex( ), 0.8, 1, c_ball_sprites )
end

function ENT:Attack_Range_b()
	self.idledelay = CurTime() +2.3
	self:PlayRandomSound("Attack")
	
	local function lAttak( tar )
		if !tar:IsValid() then self.attacking = false; return end
		local FireTrace = ((self.enemy:GetPos() + Vector(0,0,10)) - self:GetPos())
		local Firevector = FireTrace:GetNormalized()
		local FireLength = FireTrace:Length()
		local ArriveTime = FireLength / 2000
		local BaseShootVector = Firevector * 2000 + Vector(0,0,300 * ArriveTime)
		controller_disposition = self:Disposition( self.enemy )
	
		local c_ball = ents.Create("controller_ball_dark")
		local bone_pos, bone_ang = self:GetBonePosition( self:LookupBone("Bip01 L Hand") )
		c_ball:SetPos( bone_pos + Vector( 15, 0, 30 ) )
		c_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
		c_ball.owner = self
		c_ball.Speed = 100
		c_ball:SetMoveCollide( 3 )
		c_ball.enemy = self.enemy
		c_ball:SetOwner( self )
		c_ball:Spawn()
		local function c_ball_pos()
			if self and ValidEntity( self ) and ValidEntity( c_ball ) then
				local bone_pos, bone_ang = self:GetBonePosition( self:LookupBone("Bip01 L Hand") )
				c_ball:SetPos( bone_pos + Vector( 15, 0, 30 ) )
			end
		end
		timer.Create( "c_ball_pos_timer" .. self.Entity:EntIndex( ), 0.05, 0, c_ball_pos )
		
		
		local function throw_c_ball()
			timer.Destroy( "c_ball_pos_timer" .. self.Entity:EntIndex( ) )
			if ValidEntity( c_ball ) then
				local phys = c_ball:GetPhysicsObject()
					phys:SetMass( 1 )
					phys:EnableGravity( false )
					phys:EnableDrag( false )

					phys:ApplyForceCenter( ( self.enemy:GetPos() - self:GetPos() ):GetNormal() * 1000 )
			end
			self.attacking = false
		end
		timer.Create( "throw_c_ball_timer" .. self.Entity:EntIndex( ), 1.05, 1, throw_c_ball )
	end
	timer.Create( "range_attack_end_timer" .. self.Entity:EntIndex( ), 0.64, 1, lAttak, self.enemy )
end



/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
	if !self.attacking and self:CanRecharge() then self:Recharge(); return end
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.attacking and convar_ai == 0 ) then
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
		if( self.enemy and ValidEntity( self.enemy ) and self.enemy:GetPos():Distance( self:GetPos() ) <= self.closest_range ) then
			if( self.enemy:GetPos():Distance( Pos ) < self.RangeDistance and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self.attacking = true
				self.idle = 0
				if !self.range_sec_charged then
					self:StartSchedule( schdRangeAttack_a )
					self:Attack_Range_a()
				else
					local rand = math.random( 1, 3 )
					if rand == 3 then
						self:StartSchedule( schdRangeAttack_b )
						self:Attack_Range_b()
					else
						self.attacking = false
					end
					self.range_sec_charged = false
					timer.Destroy( "sec_attack_recharge_timer" .. self:EntIndex() )
				end
				if !self.range_sec_charged and !timer.IsTimer( "sec_attack_recharge_timer" .. self:EntIndex() ) then
					timer.Create( "sec_attack_recharge_timer" .. self:EntIndex(), math.Rand( 8, 20 ), 1, function() self.range_sec_charged = true end )
				end
			elseif( self:HasCondition( 42 ) ) then
				self:UpdateEnemyMemory( self.enemy, self.enemy:GetPos() )
				self:StartSchedule( schdDodge )
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 900 ) or !self.following ) then
				timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
				self:SetEnemy( self.enemy, true )
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:StartSchedule( schdChase )
			end
		/*elseif( ( !self.enemy or !ValidEntity(self.enemy) ) and self.enemy_fear and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) */
		else
			self.closest_range = 9999
		end
		
	self:SetEnemy( NULL )	
	elseif( self.idle == 0 and convar_ai == 0 ) then
		self.idle = 1
		self:SetSchedule( SCHED_IDLE_STAND )
		self:SelectSchedule()
	/*elseif( !self.FoundEnemy and !self.FoundEnemy_fear and table.Count( self.table_fear ) > 0 ) then
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
		end*/
	end
	
	if( self.following ) then
		if ValidEntity( self.follow_target ) then
			if( self:Disposition( self.follow_target ) != 3 ) then
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end

			if( self:GetPos():Distance( self.follow_target:GetPos() ) > 120 and ( ( ValidEntity( self.enemy ) and self.enemy != self.follow_target and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) > 800 ) or !ValidEntity( self.enemy ) ) and !self.attacking and convar_ai == 0 ) then
				self:SetEnemy( self.follow_target, true )
				self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
				self:FlyToPos( self.follow_target:GetPos(), self.h_flyspeed, 1, 1, 1 )
				timer.Create( "self_select_schedule_timer" .. self:EntIndex(), 1, 1, function() self:StartSchedule( schdReset ) end )
			elseif( self.enemy == self.follow_target ) then
				self.enemy = NULL
			end
		else
			self.following = false
			self.follow_target = NULL
		end
	end
	
	
	/*local function wandering_schd()
		local convar_ai = GetConVarNumber("ai_disabled")
		if( convar_ai == 0 ) then
			self:StartSchedule( schdWandering )
		end
		timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
	end*/
	
	
	if( self.wander == 1 and !self.following and !self.FoundEnemy and convar_ai == 0 and !self.attacking ) then
		if( !self.timer_created ) then
			self.timer_created = true
			self:PlayRandomSound("Idle")
			timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
			//timer.Create( "wandering_timer" .. self.Entity:EntIndex( ), math.random(10,14), 1, wandering_schd )
		end
	else
		timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	end
end 

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmg)
	self:SpawnBloodEffect( self.BloodType, dmg:GetDamagePosition() )
	if self.dead then return end
	if self.ScaleDmg then dmg:ScaleDamage(self.ScaleDmg); gamemode.Call( "ScaleNPCDamage", self, 1, dmg ) end
	if !self.shieldactive then self:SetHealth(self:Health() - dmg:GetDamage()) end
	if self.triggertarget and self.triggercondition == "2" then
		self:GotTriggerCondition()
	elseif self.starthealth and self:Health() <= (self.starthealth /2) then
		self:GotTriggerCondition()
	end

	local damage = dmg:GetDamage()
	if !self.inflictor then
		self.inflictor = dmg:GetInflictor()
	end
	if !self.attacker then
		self.attacker = dmg:GetAttacker()
	end
	
	if self.shieldactive then
		self.energy = self.energy -dmg:GetDamage()
		local energy = self.energy
		local energy_max = 150
		local damage_level = math.floor((energy_max -energy) /energy_max *2)
		if energy <= 0 then
			damage_level = 2
			self:DeactivateShield()
		end
		if damage_level > self.damagelevel then
			for i = 1, damage_level -self.damagelevel do
				local frc = self.forces[1]
				if ValidEntity(frc) then self:RemoveForce(frc) end
			end
			self.damagelevel = damage_level
		end
	end
	
	//if self.RunMeleeDistance and self:CheckEnemy( 1 ) and self.enemy:GetPos():Distance( self:GetPos() ) < self.RunMeleeDistance and self.enemy:GetPos():Distance( self:GetPos() ) > self.MeleeDistance then
	//	self.hidecur = CurTime() +4
	//	self.hiding = true
	//end
	
	if( self:Health() > 0 ) then
		if( damage <= 25 ) then
			self:SetCondition( 17 )
		else
			self:SetCondition( 18 )
		end
		
		if( ValidEntity( self.inflictor ) and self.inflictor:GetClass() == "prop_physics" ) then
			self:SetCondition( 19 )
		end
	
		self.damage_count = self.damage_count +1
		if( self.damage_count == 6 ) then
			self:SetCondition( 20 )
		end
		timer.Create( "damage_count_reset_timer" .. self.Entity:EntIndex( ), 1.5, 1, function() self.damage_count = 0 end )
	end
	
	if( ( self.damage_count == 6 or self:HasCondition( 18 ) ) and !self.attacking and self.pain and self.Sounds["Pain"] and #self.Sounds["Pain"] > 0 ) then
		self:StartSchedule( schdHurt )
		//self:EmitSound( self.PainSound ..math.random(1,self.PainSoundCount) .. ".wav", 500, 100)
		
		self:PlayRandomSound("Pain")
	end
	
	if !self.enemy and self.enemy_memory and ( !self.WaterMonster or ( self.WaterMonster and self.attacker:WaterLevel() > 0 ) ) then
		local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
		if !table.HasValue( self.enemy_memory, self.attacker ) and ValidEntity( self.attacker ) and ( !self.attacker:IsPlayer() or ( self.attacker:IsPlayer() and convar_ignoreply != 1 and !self.ignoreplys ) ) and self:Disposition( self.attacker ) == 1 then table.insert( self.enemy_memory, self.attacker ) end
	end
	
	if ValidEntity(self.attacker) then
		self:UpdateEnemyMemory( self.attacker, self.attacker:GetPos() )
	end
	self.idle = 0

	if ( self:Health() <= 0 and !self.dead ) then //run on death
		self.dead = true
		self:EndPossession()
		if self.triggertarget and self.triggercondition == "4" then self:GotTriggerCondition() end
		if self.DeathSkin then self:SetSkin( self.DeathSkin ) end
		if self.DeathSequence then self:StopMoving();self:StartSchedule(self.DeathSequence) end
		gamemode.Call( "OnNPCKilled", self, self.attacker, self.inflictor )
		if self.Sounds["Death"] and #self.Sounds["Death"] > 0 then
			self:PlayRandomSound("Death")
		end

		if self.attacker:IsPlayer() then
			self.attacker:AddFrags( 1 )
		end
		
		if( self.attacker:GetClass() != "npc_barnacle" and !dmg:IsDamageType( DMG_DISSOLVE ) ) then
			if self.SpawnRagdollOnDeath then self:SpawnRagdoll( dmg:GetDamageForce() ) end
			if self.WaterMonster and !self.SpawnRagdollOnDeath then self:DeathFloat() end
			if self.drophealthkit then self:DropHealthkit() end
			if self.PrintDeathDecal then self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self:GetPos().z +4 ) ); self:SpawnBloodDecal( "YellowBlood", self ) end
			self:SetNPCState( NPC_STATE_DEAD )
			if self.SpawnRagdollOnDeath or self.RemoveOnDeath then self:Remove() end
		elseif( dmg:IsDamageType( DMG_DISSOLVE ) ) then
			self:SetNPCState( NPC_STATE_DEAD )
			self:SetSchedule( SCHED_DIE_RAGDOLL )
		end
	elseif( self:Health() > 0 ) then
		self.inflictor = nil
		self.attacker = nil
	end
end

function ENT:KeyValue( key, value )
	if( key == "squadname" or key == "netname" ) then
		self.squad = value
		self:SetupSquad()
	end
	if( key == "wander" and value == "1" ) then
		self.wander = 1
	elseif( key == "wander" ) then
		self.wander = 0
	end
	
	if( key == "health" ) then
		self.health = value
	end
	
	if( key == "target" ) then
		self.h_flytarget_n = value
	end
	
	if( key == "flyspeed" ) then
		self.h_flyspeed = value
	end
	//self[key] = value
end


function ENT:AcceptInput( cvar_name, activator, caller )
	if cvar_name == "setsquad" then
		timer.Simple( 0.01, function() self.squad = self:GetKeyValue( self, "squadname" ); self:SetupSquad() end )
	end
	
	if( string.find( cvar_name,"startflyingpath" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) and !self.flytarget and self.h_flytarget_n ) then
		self.h_flytarget = ents.FindByName( self.h_flytarget_n )[1]
		if self.h_flytarget then
			self:FlyToPos( self.h_flytarget:GetPos(), self.h_flyspeed, 1, 1, 1 )
			self.flytarget = true
		end
	end
	
	if( string.find( cvar_name,"stopflyingpath" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) and self.flytarget ) then
		self.flytarget = false
		self.h_flytarget = nil
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
Name: OnRemove
Desc: Called just before entity is deleted
//-------------------------------------------------------*/
function ENT:OnRemove()
	self:DeactivateShield()
	for k, v in pairs(self.forces) do
		v:Remove()
	end
	self:StopSounds()
	
	if self.sprite_table then
		for k, v in pairs( self.sprite_table ) do
			if ValidEntity( v ) then
				v:Remove()
			end
		end
	end
	
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy("C_Ball1_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball2_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball3_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball4_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball5_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball6_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("C_Ball7_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "range_attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "range_attack_sprite_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "c_ball_pos_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "throw_c_ball_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "sec_attack_recharge_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
end