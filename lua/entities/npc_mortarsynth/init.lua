AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.m_iClass					= CLASS_COMBINE
ENT.Model = "models/MortarSynth.mdl"
ENT.RangeDistance		= 1250

ENT.BloodType = "yellow"
ENT.Pain = true
ENT.DeathSkin = false

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"npc/mortarsynth/attack_shoot.wav"}
ENT.DSounds["Charge"] = {"npc/vort/attack_charge.wav", "npc/scanner/scanner_electric2.wav"}
ENT.DSounds["Hover"] = {"npc/mortarsynth/hover.wav", "npc/mortarsynth/hover_alarm.wav"}
ENT.DSounds["Death"] = {}
ENT.DSounds["Pain"] = {}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdRangeAttack = ai_schedule.New( "Attack Enemy range a" ) 
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

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

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_WIDE_SHORT );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_FLY )

	self:CapabilitiesAdd( CAP_MOVE_FLY | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD | CAP_SKIP_NAV_GROUND_CHECK )

	self:SetMaxYawSpeed( 500 )

	if !self.health then
		self:SetHealth(sk_msynth_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	if !self.h_flyspeed then
		self.h_flyspeed = 200//sk_controller_fly_speed_value
	end
	
	/*self.chargeparticle_r = ents.Create("info_particle_system")
	self.chargeparticle_r:SetKeyValue("effect_name", "larvae_glow")
	self.chargeparticle_r:SetParent(self)
	self.chargeparticle_r:Spawn()
	self.chargeparticle_r:Activate()
	self.chargeparticle_r:Fire("SetParentAttachment", "0",0)
	
	self.chargeparticle_l = ents.Create("info_particle_system")
	self.chargeparticle_l:SetKeyValue("effect_name", "larvae_glow")
	self.chargeparticle_l:SetParent(self)
	self.chargeparticle_l:Spawn()
	self.chargeparticle_l:Activate()
	self.chargeparticle_l:Fire("SetParentAttachment", "1",0)
	
	self.chargeparticle_m = ents.Create("info_particle_system")
	self.chargeparticle_m:SetKeyValue("effect_name", "larvae_glow_extract")
	self.chargeparticle_m:SetParent(self)
	self.chargeparticle_m:Spawn()
	self.chargeparticle_m:Activate()
	self.chargeparticle_m:Fire("SetParentAttachment", "1",0)*/
	
	/*self.chargeeffect = ents.Create("info_particle_system")
	self.chargeeffect:SetKeyValue("effect_name", "larvae_glow_extract")
	self.chargeeffect:SetKeyValue("start_active", "1")
	self.chargeeffect:SetParent(self)
	self.chargeeffect:Spawn()
	self.chargeeffect:Activate()
	self.chargeeffect:Fire("SetParentAttachment", "2")*/
	
	
	self:InitSounds()
	self.Sounds["Hover"][1]:Play()
	
	self:SetUpEnemies({ "npc_stalker", "npc_combine_s", "npc_hunter", "npc_rollermine", "npc_turret_floor", "npc_metropolice", "npc_clawscanner", "npc_cscanner", "npc_manhack" })
	//self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }

	self.enemyTable_enemies_e = {}
	
	self:SetSchedule( 1 )
	self.init = true
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
		local enemy_vec = (self.enemy:GetPos() -self:GetPos()):GetNormalized()
		self:SetAngles( enemy_vec:Angle() )
		
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
			self:SetLocalVelocity( (self:GetPos() - self_enemy_pos):GetNormalized() *160 )
		end
		if dist > 400 and !self.test then
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

function ENT:Attack()
	if !self.Sounds["Attack"] then self:InitSounds() end
	self.Sounds["Charge"][1]:Stop()
	self.Sounds["Charge"][1]:Play()
	
	self.sprites = {}
	for i = 0,2 do
		local sprite = ents.Create("env_sprite")
		sprite:SetKeyValue("rendermode", "5")
		if i != 2 then
			sprite:SetKeyValue("rendercolor", "255 0 0")
		end
		sprite:SetKeyValue("model", "sprites/glow1.vmt")
		sprite:SetKeyValue("scale", "0.3")
		sprite:SetKeyValue("spawnflags", "1")
		sprite:SetParent(self)
		sprite:Spawn()
		sprite:Activate()
		sprite:Fire("SetParentAttachment", tostring(i), 0)
		
		table.insert(self.sprites,sprite)
	end
	
	timer.Simple(0.85, function()
		if !ValidEntity(self) then return else self.attacking = false; self.Sounds["Charge"][1]:Stop(); for k, v in pairs(self.sprites) do v:Remove() end end
		if !ValidEntity(self.enemy) then return end
		self:PlayRandomSound("Attack")
		self.sprites = nil
		
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetCenter(self.enemy) -self.enemy:GetVelocity():GetNormal() *math.random(12,15)
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		if trace.Entity == self.enemy then
			if trace.Entity:IsNPC() and trace.Entity:Health() - sk_msynth_beam_value <= 0 then
				self.killicon_ent = ents.Create( "sent_killicon" )
				self.killicon_ent:SetKeyValue( "classname", "sent_killicon_mortarsynth" )
				self.killicon_ent:Spawn()
				self.killicon_ent:Activate()
				self.killicon_ent:Fire( "kill", "", 0.1 )
				self.attack_inflictor = self.killicon_ent
			else
				self.attack_inflictor = self
			end
			trace.Entity:TakeDamage( sk_msynth_beam_value, self, self.attack_inflictor )
			self.attack_inflictor = nil
				
			if( trace.Entity:GetClass() == "npc_turret_floor" and !table.HasValue( turret_index_table, trace.Entity:EntIndex() ) ) then
				table.insert( turret_index_table, trace.Entity:EntIndex() )
				trace.Entity:Fire( "selfdestruct", "", 0 )
				trace.Entity:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) ) 
				local function entity_index_remove()
					table.remove( turret_index_table )
				end
				timer.Create( "entity_index_remove_timer" .. self.Entity:EntIndex( ), 4, 1, entity_index_remove )
			end
		end
		
		for i = 1,2 do
			timer.Create("AttackBeamTimer_" .. tostring(self) .. i, 0.01, 25, function()
				if !ValidEntity(self) or !ValidEntity(self.enemy) then return end
				local effectdata = EffectData()
					
				effectdata:SetStart(self:GetAttachment(i).Pos)
				effectdata:SetOrigin(trace.HitPos)
				util.Effect( "effect_beam", effectdata ) 
			end)
		end
	end)
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
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
				self:StartSchedule( schdRangeAttack )
				self:Attack()
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
end 

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmg)
	self:SpawnBloodEffect( self.BloodType, dmg:GetDamagePosition() )
	if self.dead then return end
	if self.ScaleDmg then dmg:ScaleDamage(self.ScaleDmg); gamemode.Call( "ScaleNPCDamage", self, 1, dmg ) end
	self:SetHealth(self:Health() - dmg:GetDamage())
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
		gamemode.Call( "OnNPCKilled", self, self.attacker, self.inflictor )
		if self.Sounds["Death"] and #self.Sounds["Death"] > 0 then
			self:PlayRandomSound("Death")
		end

		if self.attacker:IsPlayer() then
			self.attacker:AddFrags( 1 )
		end
		
		self:SetNPCState( NPC_STATE_DEAD )
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata ) 
		
		util.BlastDamage( self, self, self:GetPos(), 256, 100 )
		self:Remove()
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
	self:StopSounds()
	if self.sprites then for k, v in pairs(self.sprites) do v:Remove() end end
	
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
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
end