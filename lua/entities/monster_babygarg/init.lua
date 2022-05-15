AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.immune = 0	// If set to 1, the gargantua will be immune to any bullet damage.

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/babygarg.mdl"
ENT.RangeDistance		= 265
ENT.MeleeDistance		= 90

ENT.possess_viewdistance = 140
ENT.possess_viewheight = 125

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"npc/babygarg/gar_attack1.wav", "npc/babygarg/gar_attack2.wav", "npc/babygarg/gar_attack3.wav"}
ENT.DSounds["FlameRun"] = {"npc/babygarg/gar_flamerun1.wav"}
ENT.DSounds["Alert"] = {"npc/babygarg/gar_alert1.wav", "npc/babygarg/gar_alert2.wav", "npc/babygarg/gar_alert3.wav"}
ENT.DSounds["Breath"] = {"npc/babygarg/gar_breathe1.wav", "npc/babygarg/gar_breathe2.wav", "npc/babygarg/gar_breathe3.wav"}
ENT.DSounds["Death"] = {"npc/babygarg/gar_die1.wav", "npc/babygarg/gar_die2.wav"}
ENT.DSounds["Pain"] = {"npc/babygarg/gar_pain1.wav", "npc/babygarg/gar_pain2.wav", "npc/babygarg/gar_pain3.wav"}
ENT.DSounds["Idle"] = {"npc/babygarg/gar_idle1.wav", "npc/babygarg/gar_idle2.wav", "npc/babygarg/gar_idle3.wav", "npc/babygarg/gar_idle4.wav", "npc/babygarg/gar_idle5.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdWait = ai_schedule.New( "Wait" )
schdWait:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )

local schdRangeAttack = ai_schedule.New( "Attack Enemy range" ) 
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack:EngTask( "TASK_STOP_MOVING", 0 )
//schdRangeAttack:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
//schdRangeAttack:AddTask( "PlaySequence", { Name = "attack", Speed = 0.8 } )
//schdRangeAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_GESTURE_RANGE_ATTACK2 )  // loop?
//schdRangeAttack:AddTask( "Attack" )

local schdMeleeAttack = ai_schedule.New( "Attack Enemy melee" ) 
schdMeleeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1 )

local schdMeleeAttack_b = ai_schedule.New( "Attack Enemy melee b" ) 
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_b:AddTask( "PlaySequence", { Name = "kickcar", Speed = 1 } )//EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1_LOW )

local schdWandering = ai_schedule.New( "Wander" ) 
schdWandering:AddTask( "wandering" )
schdWandering:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 384 )
schdWandering:EngTask( "TASK_WALK_PATH", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

local schdDodge = ai_schedule.New( "Dodge" ) 
schdDodge:EngTask( "TASK_FIND_BACKAWAY_FROM_SAVEPOSITION", 0 ) 

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_BIG_FLINCH", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

function ENT:OnTaskComplete()
	self.bTaskComplete = true
	//self:DoSchedule(self.CurrentSchedule)
end

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self.gargantua_eyesprite = ents.Create( "env_sprite" )
	self.gargantua_eyesprite:SetKeyValue( "model", "sprites/glow01.spr" )
	self.gargantua_eyesprite:SetKeyValue( "rendermode", "5" ) 
	self.gargantua_eyesprite:SetKeyValue( "rendercolor", "255 47 52" ) 
	self.gargantua_eyesprite:SetKeyValue( "scale", "0.2" ) 
	self.gargantua_eyesprite:SetKeyValue( "spawnflags", "1" ) 
	self.gargantua_eyesprite:SetParent( self )
	self.gargantua_eyesprite:Fire( "SetParentAttachment", "0", 0 )
	self.gargantua_eyesprite:Spawn()
	self.gargantua_eyesprite:Activate()

	self.flamethrower_effect_tbl = {}
	
	for i = 1,2 do
		self.flamethrower_effect = ents.Create( "info_particle_system" )
		self.flamethrower_effect:SetKeyValue( "effect_name", "flamethrower" )
			
		self.flamethrower_effect:SetParent( self )
		self.flamethrower_effect:Spawn()
		self.flamethrower_effect:Activate() 
		self.flamethrower_effect:Fire( "SetParentAttachment", tostring(i), 0 )
		table.insert( self.flamethrower_effect_tbl, self.flamethrower_effect )
	end
	

	self:SetModel( self.Model )

	self:SetHullType( HULL_LARGE );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_OPEN_DOORS | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD )

	self:SetMaxYawSpeed( 5000 )


	if !self.health then
		self:SetHealth(sk_babygarg_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	self:SetUpEnemies({"monster_gargantua"})
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self:InitSounds()
	
	self:SetSchedule( 1 )
	self.init = true
	
	self.possess_viewpos = Vector( -186, 0, 140 )
	self.possess_addang = Vector(0,0,100)
end

function ENT:Think()
	local combine_balls = ents.FindByClass( "prop_combine_ball" )
	for k,v in pairs(combine_balls) do
		if( ValidEntity( v ) ) then
			constraint.NoCollide( self, v, 0, 0 );  
		end
	end
	
	if GetConVarNumber("ai_disabled") == 1 then return end
	
	local function garg_breathe()
		self.breathdelay = nil
		self:PlayRandomSound("Breath")
	end
	if !self.breathdelay then self.breathdelay = CurTime() +4 end
	if CurTime() > self.breathdelay then
		garg_breathe()
	end
	
	
	if( self:GetActivity( ) == 10 or self:GetActivity( ) == 6 ) then
		local function playstepsound()
			self:EmitSound( "npc/garg/gar_step" .. math.random(1,2) .. ".wav" )
			util.ScreenShake( self:GetPos(), 85, 85, 0.4, 500 )  
			self.step_time = nil
		end
		if( self:GetActivity( ) == 10 ) then
			self.step_delay = 0.415
		else
			self.step_delay = 0.69
		end
		if !self.step_time then self.step_time = CurTime() +self.step_delay end
		if CurTime() > self.step_time then
			playstepsound()
		end
	end 
	
	if self.efficient then return end
	self:ValidateRelationships()

	for k, v in pairs( ents.FindByClass("npc_barnacle") ) do
		if( !table.HasValue( self.enemyTable_enemies_e, v ) ) then
			table.insert( self.enemyTable_enemies_e, v )
			v:AddEntityRelationship( self, 3, 10 )
			self:AddEntityRelationship( v, 3, 10 )
		end
	end

	if( self.range_attacking ) then
		if !self.possessed then
			if( ValidEntity(self.enemy) ) then
				if( self.enemy:GetPos():Distance( self:GetPos() ) > self.RangeDistance or self.enemy:GetPos():Distance( self:GetPos() ) < self.MeleeDistance or self.enemy:Health() <= 0 or self:Health() <= 0 ) then
					self.enemy_av = 0
				end
			else
				self.enemy_av = 0
			end
		elseif !self.master:KeyDown( 1 ) then
			self.enemy_av = 0
		end
		
		if( self.enemy_av == 0 ) then
			self.enemy_av = 1
			for k, v in pairs( self.flamethrower_effect_tbl ) do v:Fire( "Stop", "", 0 ) end
			timer.Destroy("garg_attack_schedule_timer" .. self.Entity:EntIndex( ) )
			timer.Destroy("range_attack_dmgdelay_timer" .. self.Entity:EntIndex( ))
			if !self.attack_b then
				self.Sounds["FlameRun"][1]:Stop()
				self:EmitSound( "npc/garg/gar_flameoff1.wav", 500, 100)
			end
			self.attack_b = false
			self.range_attacking = false
		end
	end
	
	if self.possessed then
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.melee_attacking and !self.range_attacking and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			self:PossessMovement( 250 )
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				if !self.master:KeyDown( 4 ) then
					self:Attack_Range( true )
				end
			elseif self.master:KeyDown( 2048 ) then
				if !self.master:KeyDown( 4 ) then
					self:AttackMelee(schdMeleeAttack, self.MeleeDistance, sk_babygarg_slash_value, "babygarg", Angle( -8, -20, 0 ), 1, 1, "npc/garg/gar_claw_strike" ..math.random(1,3).. ".wav" )
				else
					self:Attack_Melee_b(true)
				end
			end
		end
	end
end

function ENT:Attack_Range()
	self.range_attacking = true
	self.idle = 0

	self:PlayRandomSound("Attack")

	self:EmitSound( "npc/garg/gar_flameon1.wav", 500, 100)
	for k, v in pairs( self.flamethrower_effect_tbl ) do v:Fire( "Start", "", 0 ) end
	self.Sounds["FlameRun"][1]:Stop()
	self.Sounds["FlameRun"][1]:Play()
	
	self:SetSchedule( SCHED_MELEE_ATTACK2 )
	timer.Create("garg_attack_schedule_timer" .. self.Entity:EntIndex( ), 0.4, 0, function() self:SetSchedule( SCHED_MELEE_ATTACK2 ) end )
	
	
	local function burn_dmg()
		local victim = ents.FindInBox( self:LocalToWorld( Vector( 35, -70, -8.5 ) ), self:LocalToWorld( Vector( 342, 64, 95 ) ) )

		for k, v in pairs(victim) do
			if( ( ( ( v:IsPlayer() and v:Alive() ) or v:IsNPC() ) and ( self:Disposition( v ) == 1 or self:Disposition( v ) == 2 ) ) or v:GetClass() == "prop_physics" ) then
				if( v:GetClass() != "prop_physics" ) then
				end
				if v:IsPlayer() then
					v:TakeDamage(sk_babygarg_burn_pl_value,self.Entity)  
					v:EmitSound( "player/pl_burnpain" ..math.random(1,3).. ".wav", 500, 100)
				else
					v:Ignite( 6, 0 )
					if v:IsNPC() and v:Health() - sk_babygarg_burn_npc_value <= 0 then
						self.killicon_ent = ents.Create( "sent_killicon" )
						self.killicon_ent:SetKeyValue( "classname", "sent_killicon_babygarg" )
						self.killicon_ent:Spawn()
						self.killicon_ent:Activate()
						self.killicon_ent:Fire( "kill", "", 0.1 )
						self.attack_inflictor = self.killicon_ent
					else
						self.attack_inflictor = self
					end
					v:TakeDamage( sk_babygarg_burn_npc_value, self, self.attack_inflictor )  
				end
				
				if( v:GetClass() == "npc_turret_floor" and !table.HasValue( turret_index_table, v:EntIndex() ) ) then
					table.insert( turret_index_table, v:EntIndex() )
					v:Fire( "selfdestruct", "", 0 )
					local function entity_index_remove()
						table.remove( turret_index_table )
					end
					timer.Create( "entity_index_remove_timer" .. self.Entity:EntIndex( ), 4.4, 1, entity_index_remove )
				end
			end
		end
	end
	burn_dmg()
	timer.Create( "range_attack_dmgdelay_timer" .. self.Entity:EntIndex( ), 0.8, 0, burn_dmg )
end


function ENT:Attack_Melee_b( poss )
	self.attacking = true
	self.idle = 0
	self:StartSchedule( schdMeleeAttack_b )
	
	local function attack_kick_dmg()
		if !ValidEntity(self) then return end
		local hit
		local pos = self:GetPos()
		local dist = self.MeleeDistance
		local dmg = sk_babygarg_kick_value
		local viewpunch_a = Angle( 0, 0, 15 )
		for k, v in pairs(ents.FindInSphere(pos, dist)) do
			if ValidEntity(v) and ((v:IsPlayer() and v:Alive()) or !v:IsPlayer()) and v != self and (v:GetClass() == "prop_*" or self:Disposition( v ) == 1 or self:Disposition( v ) == 2) then
				local ang = self:GetAngles().y -(v:GetPos() -self:GetPos()):Angle().y
				if ang < 0 then ang = ang +360 end
				if dontcheckang or ((ang <= 90 and ang >= 0) or (ang <= 360 and ang >= 270)) then
					hit = true
					if v:IsNPC() and v:Health() -dmg <= 0 then
						local killicon_ent = ents.Create( "sent_killicon" )
						killicon_ent:SetKeyValue( "classname", "sent_killicon_babygarg" )
						killicon_ent:Spawn()
						killicon_ent:Activate()
						killicon_ent:Fire( "kill", "", 0.1 )
						self.attack_inflictor = self.killicon_ent
					else
						self.attack_inflictor = self
					end
					v:SetVelocity( (self:GetForward() *400) +Vector( 0, 0, 260 ) )
					v:TakeDamage( dmg, self, self.attack_inflictor )  
					if v:IsPlayer() then
						v:ViewPunch( viewpunch_a )
					end
					
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
		if hit then self:EmitSound( "zombie/claw_strike" ..math.random(1,3).. ".wav", 100, 100) end
		timer.Destroy( "range_attack_reset_timer" .. self:EntIndex() )
		self.allow_range_attack = true
		self.attacking = false
		if poss then self.possession_allowdelay = CurTime() +0.4 end
	end
	timer.Simple( 0.7, attack_kick_dmg )
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


function ENT:OnTakeDamage(dmg)
	if dmg:GetDamage() > 100 and !dmg:IsExplosionDamage() then dmg:SetDamage(10) end
	if !self.inflictor then
		self.inflictor = dmg:GetInflictor()
	end
	if !self.attacker then
		self.attacker = dmg:GetAttacker()
	end
	if( dmg:IsDamageType( DMG_VEHICLE ) or dmg:IsDamageType( DMG_ACID ) or dmg:IsDamageType( DMG_AIRBOAT ) ) then
		dmg:ScaleDamage( 0.1 )
	elseif( dmg:IsDamageType( DMG_CLUB ) or dmg:IsDamageType( DMG_SHOCK ) or dmg:IsDamageType( DMG_SONIC ) or dmg:IsDamageType( DMG_ENERGYBEAM ) or dmg:IsDamageType( DMG_RADIATION ) or dmg:IsDamageType( DMG_GENERIC ) ) then
		dmg:ScaleDamage( 0.4 )
	elseif( dmg:IsDamageType( DMG_POISON ) or dmg:IsDamageType( DMG_NERVEGAS ) or dmg:IsDamageType( DMG_PARALYZE ) ) then
		dmg:SetDamage( 0 )
	elseif( self.attacker:IsNPC() and ValidEntity( self.attacker ) and self.attacker:GetClass() == "npc_antlionguard" ) then
		dmg:ScaleDamage( 0.2 )
	end

	if( !dmg:IsDamageType( DMG_DISSOLVE ) ) then
		if( ( dmg:IsBulletDamage() and self.immune == 0 ) or !dmg:IsBulletDamage() ) then
			self:SetHealth(self:Health() - dmg:GetDamage())
		end
	end
	if self.triggertarget and self.triggercondition == "2" then
		self:GotTriggerCondition()
	elseif self.starthealth and self:Health() <= (self.starthealth /2) then
		self:GotTriggerCondition()
	end
	local damage = dmg:GetDamage()
	local damage_force = dmg:GetDamageForce()
	
	if( self:Health() > 0 and !dmg:IsBulletDamage() ) then
		if( damage <= 90 ) then
			self:SetCondition( 17 )
		else
			self:SetCondition( 18 )
		end
		
		if( ValidEntity( self.inflictor ) and self.inflictor:GetClass() == "prop_physics" ) then
			self:SetCondition( 19 )
		end
	
		self.damage_count = self.damage_count +1
		if( self.damage_count == 3 ) then
			self:SetCondition( 20 )
		end
		timer.Create( "damage_count_reset_timer" .. self.Entity:EntIndex( ), 1.5, 1, function() self.damage_count = 0 end )
	end
	
	if( self.damage_count == 6 or self:HasCondition( 18 ) and !self.range_attacking and !self.melee_attacking and self.pain == 1 ) then
		self:StartSchedule( schdHurt )
		self:PlayRandomSound("Pain")
	end
	
	if !self.enemy and self.enemy_memory and ( !self.WaterMonster or ( self.WaterMonster and self.attacker:WaterLevel() > 0 ) ) then
		local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
		if !table.HasValue( self.enemy_memory, self.attacker ) and ( !self.attacker:IsPlayer() or ( self.attacker:IsPlayer() and convar_ignoreply != 1 and !self.ignoreplys ) ) and self:Disposition( self.attacker ) == 1 then table.insert( self.enemy_memory, self.attacker ) end
	end
	
	if ValidEntity(self.attacker) then
		self:UpdateEnemyMemory( self.attacker, self.attacker:GetPos() )
	end
	self.idle = 0
	
	if( self:Health() <= 0 and !self.dead ) then //run on death
		self.dead = true
		self:EndPossession()
		if self.triggertarget and self.triggercondition == "4" then self:GotTriggerCondition() end
		
		gamemode.Call( "OnNPCKilled", self, self.attacker, self.inflictor )
		self:PlayRandomSound("Death")
		
		local cvar_keepragdolls = GetConVarNumber("ai_keepragdolls")
		
		if self.attacker:IsPlayer() then
			self.attacker:AddFrags( 1 )
		end
		
		if( self.attacker:GetClass() != "npc_barnacle" and !dmg:IsDamageType( DMG_DISSOLVE ) ) then
			if self.drophealthkit then self:DropHealthkit() end
			self:SetNPCState( NPC_STATE_DEAD )
			self:SetSchedule( SCHED_DIE_RAGDOLL )
			if GetConVarNumber("ai_keepragdolls") == 0 then self:Fade() end
		elseif( dmg:IsDamageType( DMG_DISSOLVE ) ) then
			self:SetNPCState( NPC_STATE_DEAD )
			self:SetSchedule( SCHED_DIE_RAGDOLL )
		end
	elseif( self:Health() > 0 ) then
		self.inflictor = nil
		self.attacker = nil
	end
end


/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.range_attacking and !self.melee_attacking and !self.possessed and convar_ai == 0 ) then
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
			if( self.enemy:GetPos():Distance( Pos ) < self.RangeDistance and self.enemy:GetPos():Distance( Pos ) > self.MeleeDistance and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:Attack_Range()
			elseif( self.enemy:GetPos():Distance( Pos ) < self.MeleeDistance and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				local rand = math.random(1,2)
				if rand == 1 then
					self:AttackMelee(schdMeleeAttack, self.MeleeDistance, sk_babygarg_slash_value, "babygarg", Angle( -8, -20, 0 ), 1, 1, "npc/garg/gar_claw_strike" ..math.random(1,3).. ".wav" )
				else
					self:Attack_Melee_b()
				end
			elseif( self:HasCondition( 42 ) ) then
				self:UpdateEnemyMemory( self.enemy, self.enemy:GetPos() )
				self:StartSchedule( schdDodge )
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
			
			if( self:GetPos():Distance( self.follow_target ) > 175 and ( ( ValidEntity( self.enemy ) and self.enemy != self.follow_target and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) > 800 ) or !ValidEntity( self.enemy ) ) and !self.range_attacking and !self.melee_attacking and convar_ai == 0 ) then
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
	
	
	if( self.wander == 1 and !self.following and !self.possessed and !self.FoundEnemy and convar_ai == 0 and !self.range_attacking and !self.melee_attacking ) then
		if( !self.timer_created ) then
			self.timer_created = true
			timer.Create( "wandering_timer" .. self.Entity:EntIndex( ), math.random(10,14), 1, wandering_schd )
		end
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
	
	if( key == "immune" and value == "1" ) then
		self.immune = 1
	elseif( key == "immune" ) then
		self.immune = 0
	end
end

/*---------------------------------------------------------
Name: OnRemove
Desc: Called just before entity is deleted
//-------------------------------------------------------*/
function ENT:OnRemove()
	if self.init then
		self:StopSounds()
		self:EndPossession()
		self.gargantua_eyesprite:Remove()
		
		for k, v in pairs( self.flamethrower_effect_tbl ) do if ValidEntity( v ) then v:Remove() end end
	end
	self:EndPossession()
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("garg_attack_schedule_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy("range_attack_dmgdelay_timer" .. self.Entity:EntIndex( ))
	timer.Destroy( "entity_index_remove_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "melee_attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "range_attack_dmgdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "melee_attack_dmgdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "range_attack_b_tracerdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "Stomp_delay_reset_timer" .. self:EntIndex() )
end