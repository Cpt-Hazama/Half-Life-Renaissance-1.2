AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.m_iClass					= CLASS_HEADCRAB
ENT.Model = "models/hl1_crab.mdl"
ENT.MinDistance		= 235

ENT.SpawnRagdollOnDeath = true
ENT.FadeOnDeath = false
ENT.BloodType = "yellow"
ENT.Pain = false
ENT.DeathSkin = false

ENT.possess_viewdistance = 70
ENT.possess_viewheight = 30

ENT.DSounds = {}
ENT.DSounds["Alert"] = {"headcrab/hc_alert"}
ENT.DSounds["Death"] = {"headcrab/hc_die1.wav", "headcrab/hc_die2.wav"}
ENT.DSounds["Idle"] = {"headcrab/hc_idle1.wav", "headcrab/hc_idle2.wav", "headcrab/hc_idle3.wav", "headcrab/hc_idle4.wav", "headcrab/hc_idle5.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdWait = ai_schedule.New( "Wait" )
schdWait:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )

local schdAttack = ai_schedule.New( "Attack Enemy" ) 
schdAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

local schdWandering = ai_schedule.New( "Wander" ) 
schdWandering:AddTask( "wandering" )
schdWandering:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 384 )
schdWandering:EngTask( "TASK_WALK_PATH", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_TINY );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_MOVE_JUMP | CAP_OPEN_DOORS | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD )

	self:SetMaxYawSpeed( 5000 )
	
	if !self.health then
		self:SetHealth(sk_headcrab_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end

	self:SetUpEnemies( {"npc_fastzombie_torso", "npc_fastzombie",  "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "monster_zombie", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "monster_babycrab", "monster_bigmomma", "monster_gonome", "monster_zombie_barney", "monster_zombie_soldier"} )
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	self.enemyTable_LI = { "monster_babycrab", "monster_zombie", "npc_fastzombie_torso", "npc_fastzombie", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "npc_headcrab", "monster_bigmomma", "monster_gonome" }
	
	self:InitSounds()
	
	self:SetSchedule( 1 )
	
	self.enemyTable_enemies_e = {}
	
	self.possess_viewpos = Vector( -75, 0, 32 )
	self.possess_addang = Vector(0,0,22)
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
				self:Attack( true )
			end
		end
	end
end

function ENT:Attack( poss )
	self.attacking = true
	self.idle = 0
	self:StartSchedule( schdAttack )
	self:EmitSound( "headcrab/hc_attack" .. math.random(1,3) .. ".wav", 100, 140)
	local enemy_pos
	if !poss then
		enemy_pos = self.enemy:GetPos()
	else
		enemy_pos = self:GetPos() +self:GetForward() *18
	end
	if( enemy_pos:Distance( self:GetPos() ) < 70 ) then
		self.attack_angle = enemy_pos + Vector( 0, 0, 8 ) - self:GetPos();
	else
		self.attack_angle = enemy_pos + Vector( 0, 0, 70 ) - self:GetPos();
	end
	
	self:SetVelocity(self.attack_angle:Normalize()*500);

	local enemy_table = {}
	local function attack_dmg()
		local self_pos = self:GetPos()
		
		local victim = ents.FindInSphere( self_pos, 35 )
		for k, v in pairs(victim) do
			if( !table.HasValue( enemy_table, v ) ) then
				if( ( ( ( v:IsPlayer() and v:Alive() ) or v:IsNPC() ) and ( self:Disposition( v ) == 1 or self:Disposition( v ) == 2 ) ) or v:GetClass() == "prop_physics" ) then
					self:EmitSound( "headcrab/hc_headbite.wav", 100, 120)
					table.insert( enemy_table, v )
					if v:IsNPC() and v:Health() - sk_headcrab_melee_value <= 0 then
						self.killicon_ent = ents.Create( "sent_killicon" )
						self.killicon_ent:SetKeyValue( "classname", "sent_killicon_headcrab" )
						self.killicon_ent:Spawn()
						self.killicon_ent:Activate()
						self.killicon_ent:Fire( "kill", "", 0.1 )
						self.attack_inflictor = self.killicon_ent
					else
						self.attack_inflictor = self
					end
					v:TakeDamage( sk_headcrab_melee_value, self, self.attack_inflictor )  
					
					if( v:GetClass() == "npc_turret_floor" and !table.HasValue( turret_index_table, v:EntIndex() ) ) then
						table.insert( turret_index_table, v:EntIndex() )
						v:Fire( "selfdestruct", "", 0 )
						v:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) ) 
						local function entity_index_remove()
							table.remove( turret_index_table )
						end
						timer.Create( "entity_index_remove_timer" .. self.Entity:EntIndex( ), 4.4, 1, entity_index_remove )
					end
				end
			end
		end
		
		local function attack_end()
			timer.Destroy( "attack_dmgdelay_timer" .. self.Entity:EntIndex( ) )
			self:StartSchedule( schdWait )
			self.timer_allow = 1
			self.attacking = false
		end
		timer.Create( "attack_end_timer" .. self.Entity:EntIndex( ), 0.6, 1, attack_end )
	end
	timer.Create( "attack_dmgdelay_timer" .. self.Entity:EntIndex( ), 0.01, 0, attack_dmg )
	timer.Create( "attack_dmgdelay_deltimer" .. self.Entity:EntIndex( ), 0.8, 1, function() timer.Destroy( "attack_dmgdelay_timer" .. self.Entity:EntIndex( ) ) end )
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

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.attacking and !self.possessed and convar_ai == 0 ) then
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
			if( self.enemy:GetPos():Distance( Pos ) < self.MinDistance and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:Attack()
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 800 ) or !self.following ) then
				self:SetEnemy( self.enemy, true )
				self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				self:StartSchedule( schdChase )
			end
		elseif( ( !self.enemy or !ValidEntity(self.enemy) ) and self.enemy_fear and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) 
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
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "entity_index_remove_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_dmgdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_dmgdelay_deltimer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
end