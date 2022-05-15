AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/baby_voltigore.mdl"
ENT.MeleeDistance	= 70
ENT.RangeDistance	= 700

// OnDeath
ENT.SpawnRagdollOnDeath = false
ENT.FadeOnDeath = false
ENT.BloodType = "green"
ENT.Pain = true
ENT.DeathSkin = false
ENT.DeathSequence = true

ENT.possess_viewdistance = 110
ENT.possess_viewheight = 40

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"voltigore/voltigore_attack_melee1.wav", "voltigore/voltigore_attack_melee2.wav"}
ENT.DSounds["Shock"] = {"voltigore/voltigore_attack_shock.wav"}
ENT.DSounds["Alert"] = {"voltigore/voltigore_alert1.wav", "voltigore/voltigore_alert2.wav", "voltigore/voltigore_alert3.wav"}
ENT.DSounds["Death"] = {"voltigore/voltigore_die1.wav", "voltigore/voltigore_die2.wav", "voltigore/voltigore_die3.wav"}
ENT.DSounds["Pain"] = {"voltigore/voltigore_pain1.wav", "voltigore/voltigore_pain2.wav", "voltigore/voltigore_pain3.wav", "voltigore/voltigore_pain4.wav"}
ENT.DSounds["Idle"] = {"voltigore/voltigore_idle1.wav", "voltigore/voltigore_idle2.wav", "voltigore/voltigore_idle3.wav"}

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
schdMeleeAttack_a:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1 )

local schdMeleeAttack_b = ai_schedule.New( "Attack Enemy a" ) 
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK2 )

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
		self:SetHealth(sk_babyvoltigore_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end

	self:SetUpEnemies({"monster_pitdrone", "monster_shocktrooper", "monster_shockroach", "monster_geneworm", "monster_alien_voltigore", "monster_pitworm"})
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self:InitSounds()
	self.sounds_pitch = 150
	
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
				self:PlayRandomSound("Attack")
				if math.random(1,2) == 1 then
					self:AttackMelee(schdMeleeAttack_a, self.MeleeDistance, sk_babyvoltigore_slash_value /1.8, "babyvoltigore", Angle( 6, -7, 0 ), 0.55, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
				else
					self:AttackMelee(schdMeleeAttack_b, self.MeleeDistance, sk_babyvoltigore_slash_value, "babyvoltigore", Angle( 6, 0, 0 ), 0.96, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
				end
			elseif self.master:KeyDown( 2048 ) then
				self:Attack_Range(true)
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

function ENT:Attack_Range( poss )
	self:StartSchedule( schdRangeAttack )
	self.attacking = true
	self.idle = 0
	
	self:EmitSound("debris/beamstart2.wav", 100, 250)
	timer.Simple(1, function()
		if !ValidEntity(self) then return end
		local pos = self:GetPos() +self:GetForward() *20 +self:GetUp() *10
		local effectdata = EffectData()
		effectdata:SetStart( pos )
		effectdata:SetOrigin( pos )
		effectdata:SetScale( 1 )
		util.Effect( "MetalSpark", effectdata )
		self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100, 100)
		timer.Simple(2,function() if ValidEntity(self) then self.attacking = false; self:SelectSchedule() end end)
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
	local rand = math.random(1,10)
	if self.enemy:GetPos():Distance(self:GetPos()) <= self.RangeDistance and self:Visible(self.enemy) and rand == 10 then return true else return false end
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
					self:Attack_Range()
				elseif dist <= self.MeleeDistance then
					self:PlayRandomSound("Attack")
					if math.random(1,2) == 1 then
						self:AttackMelee(schdMeleeAttack_a, self.MeleeDistance, sk_babyvoltigore_slash_value /1.8, "babyvoltigore", Angle( 6, -7, 0 ), 0.55, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
					else
						self:AttackMelee(schdMeleeAttack_b, self.MeleeDistance, sk_babyvoltigore_slash_value, "babyvoltigore", Angle( 6, 0, 0 ), 0.96, 0, "zombie/claw_strike" ..math.random(1,3).. ".wav" )
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