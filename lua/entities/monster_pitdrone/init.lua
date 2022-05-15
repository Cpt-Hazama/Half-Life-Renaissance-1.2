AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/pit_drone.mdl"
ENT.MeleeDistance	= 65
ENT.RangeDistance	= 1000

// OnDeath
ENT.SpawnRagdollOnDeath = false
ENT.FadeOnDeath = false
ENT.BloodType = "yellow"
ENT.Pain = true
ENT.DeathSkin = false
ENT.DeathSequence = true

ENT.possess_viewdistance = 110
ENT.possess_viewheight = 76

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"pitdrone/pit_drone_melee_attack1.wav", "pitdrone/pit_drone_melee_attack2.wav"}
ENT.DSounds["Spike"] = {"pitdrone/pit_drone_attack_spike1.wav", "pitdrone/pit_drone_attack_spike2.wav"}
ENT.DSounds["Reload"] = {"weapons/crossbow/reload1.wav"}
ENT.DSounds["Alert"] = {"pitdrone/pit_drone_alert1.wav", "pitdrone/pit_drone_alert2.wav", "pitdrone/pit_drone_alert3.wav"}
ENT.DSounds["Death"] = {"pitdrone/pit_drone_die1.wav", "pitdrone/pit_drone_die2.wav", "pitdrone/pit_drone_die3.wav"}
ENT.DSounds["Pain"] = {"pitdrone/pit_drone_pain1.wav", "pitdrone/pit_drone_pain2.wav", "pitdrone/pit_drone_pain3.wav", "pitdrone/pit_drone_pain4.wav"}
ENT.DSounds["Idle"] = {"pitdrone/pit_drone_idle1.wav", "pitdrone/pit_drone_idle2.wav", "pitdrone/pit_drone_idle3.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH", 0 )//_TIMED", 0.2 )
//schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdWait = ai_schedule.New( "Wait" )
schdWait:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )

local schdMeleeAttack_a = ai_schedule.New( "Attack Enemy a" ) 
schdMeleeAttack_a:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_a:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_a:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK2 )

local schdMeleeAttack_b = ai_schedule.New( "Attack Enemy a" ) 
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1 )

local schdRangeAttack = ai_schedule.New( "Range Attack" ) 
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdReload = ai_schedule.New( "Attack Enemy a" ) 
schdReload:EngTask( "TASK_STOP_MOVING", 0 )
schdReload:EngTask( "TASK_STOP_MOVING", 0 )
schdReload:EngTask( "TASK_PLAY_SEQUENCE", ACT_RELOAD )

local schdWandering = ai_schedule.New( "Wander" ) 
schdWandering:AddTask( "wandering" )
schdWandering:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 384 )
schdWandering:EngTask( "TASK_WALK_PATH", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_SMALL_FLINCH", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

local schdResetSchedule = ai_schedule.New( "ResetSchedule" ) 
schdResetSchedule:EngTask( "TASK_SET_SCHEDULE", "SCHED_SCRIPTED_WAIT" ) 

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_JUMP | CAP_MOVE_GROUND | CAP_OPEN_DOORS | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD )
	self:SetMaxYawSpeed( 5000 )


	if !self.health then
		self:SetHealth(sk_pitdrone_health_value)
	end
	
	local rand = math.random(2,4)
	self:SetBodygroup(2,rand)
	self.spikes = 7 -rand
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end

	self:SetUpEnemies({"monster_alien_voltigore", "monster_shocktrooper", "monster_shockroach", "monster_geneworm", "monster_alien_babyvoltigore", "monster_pitworm"})
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self.allow_range_attack = true
	
	self:InitSounds()
	
	self:SetSchedule( 1 )
	self.init = true
	self.possess_viewpos = Vector( -95, 0, 88 )
	self.possess_addang = Vector(0,0,55)
end

function ENT:Think()
	if GetConVarNumber("ai_disabled") == 1 or self.efficient then return end
	self:ValidateRelationships()
	
	if self.possessed then
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.attacking and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			self:PossessMovement( 80 )
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				if self.spikes > 0 then
					self:StartSchedule( schdRangeAttack )
					self:Attack_Range(true)
				else
					self:Reload()
				end
			elseif self.master:KeyDown( 2048 ) then
				self:PlayRandomSound("Attack")
				if math.random(1,2) == 1 then
					self:AttackMelee(schdMeleeAttack_a, self.MeleeDistance, sk_pitdrone_claws_value, "pitdrone", Angle( 7, -10, 0 ), 0.5, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav", {1, "zombie/claw_strike" ..math.random(1,3).. ".wav", Angle( 7, 10, 0 )} )
				else
					self:AttackMelee(schdMeleeAttack_b, self.MeleeDistance, sk_pitdrone_claws_value, "pitdrone", Angle( 10, 0, 0 ), 0.55, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
				end
			end
		end
	end
	
	if self.possessed then return end
	local grenades = ents.FindByClass( "npc_grenade_frag" )
	for k,v in pairs(grenades) do
		local grenade_dist = v:GetPos():Distance( self:GetPos() )
		if( !self.ghide and grenade_dist < 256 and !self.FoundEnemy ) then
			self:SetEnemy( v, true )
			self:UpdateEnemyMemory( v, v:GetPos() )
			self:StartSchedule( schdHide )
			self.ghide = true
			self:SetEnemy( NULL )
			timer.Create( "self.ghide_reset_timer" .. self.Entity:EntIndex( ), 1, 1, function() self.ghide = false end )
		end
	end
end

function ENT:Reload()
	self:StartSchedule( schdReload )
	self.attacking = true
	self:PlayRandomSound("Reload")
	timer.Simple(0.8, function()
		if !ValidEntity(self) or self.dead then return end
		self.spikes = 6
		self:SetBodygroup(2,1)
		self.attacking = false
	end)
end

function ENT:Attack_Range( poss )
	self.attacking = true
	self.idle = 0

	self:PlayRandomSound("Spike")
	timer.Simple(0.4, function()
		if (!ValidEntity(self) or !ValidEntity(self.enemy)) and !self.possessed then self.attacking = false; return end
			local spike = ents.Create("pitdrone_spike")
			spike:SetPos(self:GetPos() +self:GetForward() *13 +self:GetUp() *36)
			spike.owner = self
			spike:SetOwner( self )
			spike:Spawn()
			
			local vec
			if !self.possessed then
				vec = (self.enemy:GetPos() -self:GetPos()):GetNormal()
			else
				vec = self:GetForward()
			end
			spike:SetAngles(vec:Angle())
			local phys = spike:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocity( vec *2400)
			end
		
		self.spikes = self.spikes -1
		if self.spikes == 0 then
			self:SetBodygroup(2,0)
		else
			self:SetBodygroup(2,7 -self.spikes)
		end
		timer.Simple(1.2,function() if ValidEntity(self) then self.attacking = false; self:SelectSchedule() end end)
	end)
end

function ENT:TaskStart_wandering()
	self:PlayRandomSound("Idle")
	self:TaskComplete()
end 

function ENT:Task_wandering()
	if( self.FoundEnemy ) then
		self:TaskComplete()
	end
end

function ENT:CanRangeAttack()
	if self.enemy:GetPos():Distance(self:GetPos()) <= self.RangeDistance and self.allow_range_attack and self.spikes > 0 and self:Visible(self.enemy) then return true else return false end
end

function ENT:CanMeleeAttack()
	if self.enemy:GetPos():Distance(self:GetPos()) <= self.MeleeDistance then return true else return false end
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.attacking and !self.possessed and convar_ai == 0 ) then
		if !self.searchdelay then
			self.searchdelay = CurTime() +0.4
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
		if( ValidEntity( self.enemy ) and self.enemy:GetPos():Distance( self:GetPos() ) <= self.closest_range ) then
			local dist = self.enemy:GetPos():Distance( Pos )
			if self:HasCondition( 10 ) and !self:HasCondition( 42 ) and (self:CanRangeAttack() or self:CanMeleeAttack()) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				if self:CanRangeAttack() and dist > self.MeleeDistance then
					self:StartSchedule( schdRangeAttack )
					self:Attack_Range()
					
					if !self.range_attack_max_count then
						self.range_attack_max_count = math.random(2,3)
					else
						self.range_attack_max_count = self.range_attack_max_count -1
					end
					
					if self.range_attack_max_count == 0 then
						self.allow_range_attack = false
						self.range_attack_max_count = nil
						timer.Create( "range_attack_reset_timer" .. self:EntIndex(), math.random(6,9), 1, function() self.allow_range_attack = true end )
					end
				elseif dist <= self.MeleeDistance then
					self:PlayRandomSound("Attack")
					if math.random(1,2) == 1 then
						self:AttackMelee(schdMeleeAttack_a, self.MeleeDistance, sk_pitdrone_claws_value, "pitdrone", Angle( 7, -10, 0 ), 0.5, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav", {1, "zombie/claw_strike" ..math.random(1,3).. ".wav", Angle( 7, 10, 0 )} )
					else
						self:AttackMelee(schdMeleeAttack_b, self.MeleeDistance, sk_pitdrone_claws_value, "pitdrone", Angle( 10, 0, 0 ), 0.55, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
					end
				end
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 800 ) or !self.following ) then
				timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
				self:SetEnemy( self.enemy, true )
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:StartSchedule( schdChase )
			end
		elseif( !ValidEntity(self.enemy) and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) 
		else
			self.closest_range = 9999
		end
		
	self:SetEnemy( NULL )
	elseif( !self.FoundEnemy and !self.FoundEnemy_fear and !self.attacking and !self.possessed and convar_ai == 0 and self.spikes <= 3 ) then
		self:Reload()
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
	
	if( self.following and !self.possessed ) then
		if ValidEntity( self.follow_target ) then
			if( self:Disposition( self.follow_target ) != 3 ) then
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
			
			if( self:GetPos():Distance( self.follow_target ) > 175 and ( ( ValidEntity( self.enemy ) and self.enemy != self.follow_target and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) > 800 ) or !ValidEntity( self.enemy ) ) and !self.attacking and convar_ai == 0 ) then
				self:SetEnemy( self.follow_target, true )
				self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
				self:StartSchedule( schdFollow )
				timer.Create( "self_select_schedule_timer" .. self:EntIndex(), 1, 1, function() self:StartSchedule( schdReset ) end )
			elseif( self.enemy == self.follow_target ) then
				self.enemy = NULL
			end
		else
			self.following = false
			self.follow_target = NULL
		end
	end
	
	local function wandering_schd()
		local convar_ai = GetConVarNumber("ai_disabled")
		if( convar_ai == 0 ) then
			self:StartSchedule( schdWandering )
		end
		timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
	end
	
	
	if( self.wander == 1 and !self.following and !self.possessed and !self.FoundEnemy and convar_ai == 0 and !self.attacking ) then
		if( !self.timer_created ) then
			self.timer_created = true
			timer.Create( "wandering_timer" .. self.Entity:EntIndex( ), math.random(10,14), 1, wandering_schd )
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
	timer.Destroy( "range_attack_reset_timer" .. self:EntIndex())
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