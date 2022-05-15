AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.m_iClass					= CLASS_MILITARY
ENT.Model = "models/hwgrunt.mdl"
ENT.MinDistance = 600

ENT.BloodType = "red"

ENT.defammo = 120

ENT.EffectMuzzle = "muzzle_scattergun"
ENT.EffectMuzzleForward = 38
ENT.EffectMuzzleRight = 8
ENT.EffectMuzzleUp = 40
ENT.EffectTracerCount = 1

ENT.DSounds = {}
ENT.DSounds["Shoot"] = {"npc/hassault/hw_shoot2.wav", "npc/hassault/hw_shoot3.wav"}
ENT.DSounds["SpinUp"] = {"npc/hassault/hw_spinup.wav"}
ENT.DSounds["Spin"] = {"npc/hassault/hw_spin.wav"}
ENT.DSounds["SpinDown"] = {"npc/hassault/hw_spindown.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 600 ) 

//schdChase:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )

local schdReload = ai_schedule.New( "Reloading" ) 
schdReload:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RELOAD ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdFollowply = ai_schedule.New( "Follow player" )
schdFollowply:EngTask( "TASK_TARGET_PLAYER", 0 )
schdFollowply:EngTask( "TASK_GET_PATH_TO_TARGET", 0 )
schdFollowply:EngTask( "TASK_MOVE_TO_TARGET_RANGE", 125 ) 

local schdSpinUp = ai_schedule.New( "Spinup" ) 
schdSpinUp:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_ARM )

local schdSpinDown = ai_schedule.New( "Spindown" ) 
schdSpinDown:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_DISARM )

local schdAttack = ai_schedule.New( "Attack Enemy" ) 
schdAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdStop = ai_schedule.New( "Stop" )
schdStop:EngTask( "TASK_STOP_MOVING", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_SMALL_FLINCH", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

local schdBackaway = ai_schedule.New( "Back away" ) 
schdBackaway:EngTask( "TASK_FIND_BACKAWAY_FROM_SAVEPOSITION", 0 ) 

function ENT:Initialize()
	self.table_fear = {}
	self.f_headcrab_table = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_ANIMATEDFACE | CAP_AIM_GUN | CAP_USE | CAP_OPEN_DOORS | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD )
	self:SetMaxYawSpeed( 5000 )

	if !self.health then
		self:SetHealth(sk_hgrunt_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	self:SetBodygroup(2,0)

	self:SetUpEnemies( {"monster_human_grunt", "monster_human_assassin", "monster_sentry"} )
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self:InitSounds()
	
	self:SetSchedule( 1 )
	self.init = true
end

function ENT:OnCondition( iCondition )
	if self.efficient then return end
	//Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )
	if !self.val_cur then self.val_cur = CurTime() +0.2 end
	if self.val_cur < CurTime() then
		self:ValidateMemory()
		self.val_cur = nil
	end
	if( ( ( !self:HasCondition( 8 ) and self:HasCondition( 7 ) ) or ( self:HasCondition( 8 ) and self:HasCondition( 7 ) ) ) or ( self.enemy_memory and table.Count( self.enemy_memory ) > 0 ) ) then
		if !self.FoundEnemy then
			self.FoundEnemy_w_t = false
		else
			self.FoundEnemy_w_t = true
		end
		self.FoundEnemy = true
		self.FoundEnemy_fear = false
		self.timer_created = false
		if( self.alert_allow == 1 and self:HasCondition( 7 ) and !self:HasCondition( 8 ) and !self.FoundEnemy_w_t and !self.following ) then
			//self:FindInCone( 1, 9999 )
			if self.enemy and ValidEntity( self.enemy ) then
				local monster_table = { "npc_antlion", "npc_antlion_worker", "npc_hunter", "npc_rollermine", "npc_vortigaunt", "npc_antlionguard", "npc_fastzombie_torso", "npc_fastzombie", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "npc_stalker", "monster_generic", "monster_alien_controller", "monster_alien_grunt", "monster_babycrab", "monster_bigmomma", "monster_bullchicken", "monster_gargantua", "monster_headcrab", "monster_houndeye", "monster_panthereye", "monster_snark", "monster_tentacle", "monster_zombie" }
				if self.enemy:IsPlayer() then
					self:SpeakSentence( "!HG_ALERT" .. math.random(0,6), self, self, 10, 10, 1, true, true, false, false )
				elseif table.HasValue( monster_table, self.enemy:GetClass() ) then
					self:SpeakSentence( "!HG_MONST" .. math.random(0,3), self, self, 10, 10, 1, true, true, false, false )
				else
					local rand = math.random(1,4)
					if rand == 1 then
						self.alertspk = "!HG_ALERT1"
					elseif rand == 2 then
						self.alertspk = "!HG_ALERT2"
					elseif rand == 3 then
						self.alertspk = "!HG_ALERT3"
					else
						self.alertspk = "!HG_ALERT6"
					end
					self:SpeakSentence( self.alertspk, self, self, 10, 10, 1, true, true, false, false )
					self.alertspk = nil
				end
			end
			self.alert_allow = 0
		end
	elseif( self:HasCondition( 8 ) and !self:HasCondition( 13 ) ) then
		self.FoundEnemy_fear = true
		self.timer_created = false
	elseif( self.FoundEnemy_fear and self:HasCondition( 13 ) ) then
		self.FoundEnemy_fear = false
	elseif( ( !self.enemy_memory or table.Count( self.enemy_memory ) == 0 ) and ( self:HasCondition( 13 ) and self:HasCondition( 31 ) ) or ( !self:HasCondition( 8 ) and !self:HasCondition( 7 ) and !self.enemy_occluded ) ) then
		self.FoundEnemy = false
	end
	
	if( self.alert_allow == 0 and !self.FoundEnemy and !timer.IsTimer( "self.alert_allow_timer" .. self:EntIndex() ) ) then
		timer.Create( "self.alert_allow_timer" .. self:EntIndex(), 3, 1, function() self.alert_allow = 1 end )
	elseif( self.FoundEnemy ) then
		timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
	end
	
	if( self:HasCondition( 13 ) ) then
		self.enemy_occluded = true
		timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	elseif( !timer.IsTimer( "self.enemy_occluded_timer" .. self:EntIndex() ) ) then
		timer.Create( "self.enemy_occluded_timer" .. self:EntIndex(), 1.5, 1, function() self.enemy_occluded = false end )
	end
end

function ENT:Think()
	if GetConVarNumber("ai_disabled") == 1 or self.efficient then return end
	self:TurnToEnemyXR(-45,45)
	
	self:ValidateRelationships()
	
	if self.possessed then
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.attacking and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			self:PossessMovement( 100 )
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				self:StopMoving()
				//self:StartSchedule(schdStop)
				if !self.allow_attack then
					if !self.spinup then
						self.spinup = true
						self.Sounds["SpinUp"][1]:Stop()
						self.Sounds["SpinUp"][1]:Play()
						self:StartSchedule(schdSpinUp)
						timer.Simple( 1.2, function() if !ValidEntity(self) then return end; self.allow_attack = true; self.spinup = false end )
					end
				else
					self:Attack_mg()
				end
			end
		end
	end
	
	if self.possessed then return end
	local grenades = ents.FindByClass( "npc_grenade_frag" )
	for k,v in pairs(grenades) do
		local grenade_dist = v:GetPos():Distance( self:GetPos() )
		if( !self.ghide and grenade_dist < 256 ) then
			self:SetEnemy( v, true )
			self:UpdateEnemyMemory( v, v:GetPos() )
			self:StartSchedule( schdBackaway )
			if !self.spkgr then
				self:SpeakSentence( "!HG_GREN" .. math.random(0,6), self, self, 10, 10, 1, true, true, false, false )
			end
			self.spkgr = true
			self.ghide = true
			self:SetEnemy( NULL )
			timer.Create( "self.ghide_reset_timer" .. self.Entity:EntIndex( ), 1, 1, function() self.ghide = false end )
			if !timer.IsTimer( "self.spkgr_reset_timer" .. self.Entity:EntIndex( ) ) then
				timer.Create( "self.spkgr_reset_timer" .. self.Entity:EntIndex( ), 6, 1, function() self.spkgr = false end )
			end
		end
	end
end

function ENT:OnTakeDamage(dmg)
	self:SpawnBloodEffect( self.BloodType, dmg:GetDamagePosition() )
	if dmg:GetInflictor():GetClass() == self:GetClass() then dmg:ScaleDamage( 0.04 ) end
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
	
	self:SpawnBloodEffect( "red", dmg:GetDamagePosition() )
	
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
	
	if( self.damage_count == 3 or self:HasCondition( 18 ) and self.pain == 1 ) then
		self:StartSchedule( schdHurt )
		self:EmitSound( "hgrunt/gr_pain" .. math.random(1,5), 100, 100 )
	end
	
	if !self.enemy and self.enemy_memory and ( !self.WaterMonster or ( self.WaterMonster and self.attacker:WaterLevel() > 0 ) ) then
		local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
		if !table.HasValue( self.enemy_memory, self.attacker ) and ( !self.attacker:IsPlayer() or ( self.attacker:IsPlayer() and convar_ignoreply != 1 and !self.ignoreplys ) ) and self:Disposition( self.attacker ) == 1 then table.insert( self.enemy_memory, self.attacker ) end
	end
	
	if ValidEntity(self.attacker) then
		self:UpdateEnemyMemory( self.attacker, self.attacker:GetPos() )
	end
	self.idle = 0

	if ( self:Health() <= 0 and !self.dead ) then //run on death
		self.dead = true
		if self.triggertarget and self.triggercondition == "4" then self:GotTriggerCondition() end
		gamemode.Call( "OnNPCKilled", self, self.attacker, self.inflictor )
		self:EmitSound( "hgrunt/gr_die" ..math.random(1,3).. ".wav", 500, 100)
		
		local cvar_keepragdolls = GetConVarNumber("ai_keepragdolls")
		
		if self.attacker:IsPlayer() then
			self.attacker:AddFrags( 1 )
		end
		
		if( self.attacker:GetClass() != "npc_barnacle" and !dmg:IsDamageType( DMG_DISSOLVE ) ) then
			self:SpawnRagdoll( dmg:GetDamageForce() )
			self:SetNPCState( NPC_STATE_DEAD )
			self:Remove()
		elseif( dmg:IsDamageType( DMG_DISSOLVE ) ) then
			self:SetNPCState( NPC_STATE_DEAD )
			self:SetSchedule( SCHED_DIE_RAGDOLL )
		end
	elseif( self:Health() > 0 ) then
		self.inflictor = nil
		self.attacker = nil
	end
end

function ENT:StopAttack()
	self.attacking = false
	self.Sounds["SpinDown"][1]:Stop()
	self.Sounds["SpinDown"][1]:Play()
	self:StartSchedule(schdSpinDown)
	self.allow_attack = false
end

function ENT:Attack_mg()
	if !ValidEntity( self.enemy ) and !self.possessed then self:StopAttack(); return end
	local i = 0
	local function fire()
		if !self.allow_attack then return end
		i = i +1
		if ( !ValidEntity( self.enemy ) and !self.possessed) or (self.possessed and !self.master:KeyDown( 1 )) then self:StopAttack(); return end
		self:PlayRandomSound("Shoot")
		self:StartSchedule( schdAttack )

		self.killicon_ent = ents.Create( "sent_killicon" )
		self.killicon_ent:SetKeyValue( "classname", "sent_killicon_hwgrunt" )
		self.killicon_ent:Spawn()
		self.killicon_ent:Activate()
		self.killicon_ent:Fire( "kill", "", 0.1 )
		self.attack_inflictor = self.killicon_ent

		self:ShootBullet( math.random(3,8), 1, 0.03 )
		if i == 50 then self:FindInCone( 9999 );if (!ValidEntity(self.enemy) or self.enemy:Health() <= 0 or !self:CanRangeAttack()) then self:StopAttack() end end
	end
	fire()
	timer.Create( "Ar_Shoot_timer" .. self:EntIndex(), 0.05, 50, fire )
	
	self.attacking = false
end

function ENT:ShootBullet( damage, num_bullets, aimcone )
	local posang = self:GetAttachment(1)
	local ang = self:GetAngles()
	ang.p = ang.p -self:GetPoseParameter("XR")
	
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = posang.Pos
	bullet.Dir = ang:Forward()
	bullet.Spread = Vector( aimcone, aimcone, aimcone ) 
	bullet.Tracer = self.EffectTracerCount
	bullet.TracerPos = posang.Pos
	bullet.Force = 1
	bullet.Damage = damage /num_bullets
	self:FireBulletsCustom( bullet )
	
	/*local muzzle = ents.Create( "info_particle_system" )
	muzzle:SetKeyValue( "effect_name", self.EffectMuzzle )
	muzzle:SetKeyValue( "start_active", "1" )
	muzzle:SetPos( posang.Pos )
	muzzle:SetAngles( posang.Ang )
	//muzzle:SetParent( self )
	muzzle:Spawn()
	muzzle:Activate()
	//muzzle:Fire( "SetParentAttachment", "muzzle", 0 )
	muzzle:Fire( "Kill", "", 0.3 )*/
	local effectdata = EffectData()
	effectdata:SetOrigin( posang.Pos )
	effectdata:SetAngle(posang.Ang)
	effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )
end 

function ENT:FireBulletsCustom(b)
    for i = 1, b.Num do
        local rand = Vector( math.Rand( -b.Spread.x, b.Spread.x ), math.Rand( -b.Spread.y, b.Spread.y ), math.Rand( -b.Spread.z, b.Spread.z ) )
        local newdir = b.Dir + rand

		local tracedata = {} 
		tracedata.start = b.Src
		tracedata.endpos = b.Src +(b.Dir +rand) *9000 +self:GetRight() *-12
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)  
		
		util.BlastDamage( self.attack_inflictor, self, trace.HitPos, 12, b.Damage )
		local tracer = math.random(1,b.Tracer)
		//self:GetTextureDecal(trace)
		tracedata.mask = 16432
		local trace_wt = util.TraceLine(tracedata)
		if trace_wt.Hit then
			local particle = ents.Create("info_particle_system")
			particle:SetKeyValue("effect_name", "water_bulletsplash01_minigun")
			particle:SetKeyValue( "start_active", "1" )
			particle:SetPos(trace_wt.HitPos)
			particle:Spawn()
			particle:Activate()
			particle:Fire("kill","",0.3)
			WorldSound( "ambient/water/water_splash" .. math.random(1,3) .. ".wav", trace_wt.HitPos )
		end
		
		if tracer != 1 then return end
		local effectdata = EffectData()
		effectdata:SetStart( b.TracerPos )
		effectdata:SetOrigin( trace.HitPos )
		effectdata:SetNormal(trace.HitNormal)
		effectdata:SetScale( 6000 )
		util.Effect( "Tracer", effectdata, true, true )
    end
end

function ENT:CanRangeAttack()
	if self.enemy:GetPos():Distance(self:GetPos()) <= self.MinDistance and self:Visible(self.enemy) then return true else return false end
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
	if( ( self.FoundEnemy or self.FoundEnemy_fear ) and !self.attacking and convar_ai == 0 ) then
		if !self.searchdelay then
			self.searchdelay = CurTime() +0.25
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
			if( self:HasCondition( 10 ) and !self:HasCondition( 42 ) and self:CanRangeAttack() ) then
				self:StopMoving()
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				if self.allow_attack then
					self.attacking = true
					self.idle = 0
					self:Attack_mg()
				elseif !self.spinup then
					self.spinup = true
					self.Sounds["SpinUp"][1]:Stop()
					self.Sounds["SpinUp"][1]:Play()
					self:StartSchedule(schdSpinUp)
					timer.Simple( 1.2, function() if !ValidEntity(self) then return end; self.allow_attack = true; self.spinup = false; self:SelectSchedule() end )
				end
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 800 ) or !self.following ) then
				timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
				self:SetEnemy( self.enemy, true )
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self:StartSchedule( schdChase )
			end
		elseif( ( !self.enemy or !ValidEntity(self.enemy) ) and self.enemy_fear and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) 
		end
		
		self:SetEnemy( NULL )	
	elseif( self.idle == 0 and convar_ai == 0 ) then
		self.idle = 1
		self:SetSchedule( SCHED_IDLE_STAND )
		self:SelectSchedule()
	elseif( !self.FoundEnemy_fear and table.Count( self.table_fear ) > 0 ) then
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
	
	if( self.following and !self:EnemyIsInWeaponRange() ) then
		if ValidEntity( self.follow_target ) and self.follow_target:Health() > 0 then
			if( self:Disposition( self.follow_target ) != 3 ) then
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
			
			if( self:GetPos():Distance( self.follow_target:GetPos() ) > 225 and convar_ai == 0 ) then
				self:SetEnemy( self.follow_target, true )
				self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
				if self.follow_target:IsPlayer() then
					self:StartSchedule( schdFollowply )
				else
					self:StartSchedule( schdFollow )
				end
				timer.Create( "self_select_schedule_timer" .. self:EntIndex(), 1, 1, function() self:StartSchedule( schdReset ) end )
			elseif( self:GetPos():Distance( self.follow_target ) <= 225 ) then
				self:StartSchedule( schdStop )
			end
			
			if( self:GetPos():Distance( self.follow_target:GetPos() ) < 30 and convar_ai == 0 ) then
				self:SetEnemy( self.follow_target, true )
				self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
				self:StartSchedule( schdBackaway )
			end
		else
			self.following = false
			self.follow_target = NULL
			self.pressed = false
		end
	end
end 

function ENT:GetSpawnflag( value )
	local spawnflags = { 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
	if !table.HasValue( spawnflags, value ) then return false end
	if value == 32768 then
		self.predisaster = true
	end
	return true
end

function ENT:GetKeyValue( target, key )
	for k, v in pairs( target:GetKeyValues() ) do
		if k == key then
			self.keyvalue = v
		end
	end
	
	return self.keyvalue
end


/*---------------------------------------------------------
Name: OnRemove
Desc: Called just before entity is deleted
//-------------------------------------------------------*/
function ENT:OnRemove()
	self:EndPossession()
	self:StopSounds()
	if sc_atkbyply and sc_atkbyply.owner and ValidEntity( sc_atkbyply.owner ) and sc_atkbyply.owner == self.owner then
		sc_atkbyply.owner = NULL
		sc_atkbyply = NULL
	end
	timer.Destroy( "allow_attack_timer" .. self:EntIndex() )
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self.ghide_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "draw_wep_timer" .. self:EntIndex() )
	timer.Destroy( "reload_timer" .. self:EntIndex() )
	timer.Destroy( "self.spkkill_reset_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "self_pressed_timer" .. self:EntIndex() )
	timer.Destroy( "self_pressed_reset_timer" .. self:EntIndex() )
	timer.Destroy( "self.plyused_reset_timer" .. self:EntIndex() )
	timer.Destroy( "in_use_reset_timer" .. self:EntIndex() )
	timer.Destroy( "Ar_Shoot_timer" .. self:EntIndex() )
end