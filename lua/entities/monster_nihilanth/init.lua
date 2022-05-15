AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/nihil.mdl"
ENT.RangeDistance		= 20000 // def: 1250

ENT.SpawnRagdollOnDeath = false
ENT.FadeOnDeath = true
ENT.BloodType = "yellow"
ENT.Pain = true
ENT.DeathSkin = false

ENT.ScaleDmg = 3

ENT.Sounds = {}
ENT.Sounds["Attack"] = {"x/x_attack1.wav", "x/x_attack2.wav", "x/x_attack3.wav"}
ENT.Sounds["Death"] = {"x/x_die1.wav"}
ENT.Sounds["Pain"] = {"x/x_pain1.wav", "x/x_pain2.wav", "x/x_pain3.wav"}
ENT.Sounds["Idle"] = {"x/x_laugh1.wav", "x/x_laugh2.wav"}
ENT.Sounds["DeathEnd"] = {"debris/beamstart6.wav"}
ENT.Sounds["DeathEnd2"] = {"debris/beamstart8.wav"}

local schdRangeAttack_a = ai_schedule.New( "Attack Enemy range a" ) 
schdRangeAttack_a:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_a:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1 )

local schdRangeAttack_a_exhausted = ai_schedule.New( "Attack Enemy range a exhausted" ) 
schdRangeAttack_a_exhausted:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_a_exhausted:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK1_LOW )

local schdRangeAttack_b = ai_schedule.New( "Attack Enemy range b" ) 
schdRangeAttack_b:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_b:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK2 )

local schdRangeAttack_b_exhausted = ai_schedule.New( "Attack Enemy range a exhausted" ) 
schdRangeAttack_b_exhausted:EngTask( "TASK_STOP_MOVING", 0 )
schdRangeAttack_b_exhausted:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RANGE_ATTACK2_LOW )

local schdRecharge = ai_schedule.New( "Recharge" )
schdRecharge:EngTask( "TASK_STOP_MOVING", 0 )
schdRecharge:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_RELOAD )

local schdSpawnAllies = ai_schedule.New( "Spawn Allies" )
schdSpawnAllies:EngTask( "TASK_STOP_MOVING", 0 )
schdSpawnAllies:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1 )

//local schdFlyUp = ai_schedule.New( "Fly up" ) 
//schdFlyUp:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_CONTROLLER_UP )

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_SMALL_FLINCH", 0 ) 

local schdDeath = ai_schedule.New( "Hurt" ) 
schdDeath:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_DIESIMPLE )

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

local schdIdle = ai_schedule.New( "Idle" ) 
schdIdle:EngTask( "TASK_STOP_MOVING", 0 )
schdIdle:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_IDLE )

local schdIdleExhausted = ai_schedule.New( "Idle Exhausted" ) 
schdIdleExhausted:EngTask( "TASK_STOP_MOVING", 0 )
schdIdleExhausted:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_FLY )

function ENT:Initialize()
	self.forces = {}
	self.beams = {}
	if !self.mapentity and #ents.FindByClass("monster_nihilanth") >= 2 then self:Remove(); return end

	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_LARGE )
	self:SetHullSizeNormal();
	self:SetSolid( SOLID_BBOX )

	self:SetMoveType( MOVETYPE_FLY )

	self:CapabilitiesAdd( CAP_MOVE_FLY | CAP_INNATE_RANGE_ATTACK1 | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD | CAP_SKIP_NAV_GROUND_CHECK )

	self:SetMaxYawSpeed( 2 )

	if !self.health then
		self:SetHealth(sk_nihilanth_health_value)
	end
	self.energy = 1500
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	if !self.h_flyspeed then
		self.h_flyspeed = 200
	end
	
	self:SetUpEnemies( {"monster_alien_grunt", "monster_alien_slave", "monster_alien_controller"} )
	//self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }

	self.enemyTable_enemies_e = {}
	
	//self:InitSounds()
	self.damagelevel = 0
	
	self:SetSchedule( 1 )
	self.init = true
	
	for k, v in pairs(player:GetAll()) do
		v:ConCommand("playgamesound music/HL1_song24.mp3")
	end
	
	timer.Simple(4,function() if ValidEntity(self) then
		for k, v in pairs(player:GetAll()) do
			v:ConCommand("playgamesound nihilanth/nil_freeman.wav")
		end
	end end)
	
	self.hull = ents.Create("monster_hull")
	self.hull.owner = self
	self.hull:SetPos(self:GetPos())
	self.hull:SetParent(self)
	self.hull:Spawn()
	self.hull:Activate()
	self.hull:SetOwner(self)
	
	for i = 1,20 do
		local e_ball = ents.Create("nihilanth_force")
		e_ball:SetPos( self:GetPos() )
		e_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
		e_ball.owner = self
		e_ball.radius = math.random(300,400) //420
		e_ball.height = math.random(200,400) //320
		e_ball.speed = math.random(500,600) //500
		e_ball.delay = math.Rand(0,6)
		
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
	end
	
	self.crystals = {}
	
	local hitpos = self:GetPos() +Vector(0,0,1000)
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos() +Vector(0,0,1000)
	tracedata.filter = {self, self.hull}
	local trace = util.TraceLine(tracedata)
	if trace.HitWorld then
		hitpos = trace.HitPos
	end 
	for i = 1,3 do
		local tracedata = {}
		tracedata.start = hitpos
		tracedata.endpos = tracedata.start +Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-0.25,-1)) *5000
		tracedata.filter = {self, self.hull}
		local trace = util.TraceLine(tracedata)
		if trace.HitWorld then
			local SpawnAngles = trace.HitNormal:Angle()
			SpawnAngles.pitch = SpawnAngles.pitch +90
			local crystal = ents.Create("nihilanth_crystal")
			crystal:SetPos(trace.HitPos -trace.HitNormal * 14)
			crystal:SetAngles(SpawnAngles)
			crystal:Spawn()
			
			table.insert(self.crystals, crystal)
		end 
	end
	
	self.applygravitydelay = CurTime()
end

function ENT:Absorb(count)
	local tbl_old = self.forces
	for i = 1,count do
		local target = self.forces[i]
		target.speed = 5000
		target.radius = 0
		target:Absorb()
		local tbl_new = {}
		for k, v in pairs(tbl_old) do
			if v != target then
				table.insert(tbl_new,v)
			end
		end
		tbl_old = tbl_new
	end
	self.forces = tbl_old
end

function ENT:FlyToPos( Vec, Speed, x, y, z )
	local Entity_pos = self:GetPos()
	Entity_pos.x = 0
	Entity_pos.y = 0
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

function ENT:Exhausted()
	self.core = ents.Create("nihilanth_force_core")
	self.core:SetParent(self)
	self.core:Spawn()
	self.core:Activate()
	self.core:Fire("SetParentAttachment", "0",0)
	
	self.exhausted = true
	if !self.attacking then
		self.idledelay = CurTime()
	end
end

function ENT:SetPlayerGravity()
	for k, v in pairs(player:GetAll()) do
		if v:GetPos():Distance(self:GetPos()) <= 7000 then
			v:SetGravity((600 /GetConVarNumber("sv_gravity")) *0.04)
		else
			v:SetGravity(1)
		end
	end
end

function ENT:Think()
	local combine_balls = ents.FindByClass( "prop_combine_ball" )
	for k,v in pairs(combine_balls) do
		if( ValidEntity( v ) ) then
			constraint.NoCollide( self, v, 0, 0 );  
		end
	end

	if GetConVarNumber("ai_disabled") == 1 then return end

	if CurTime() > self.applygravitydelay then
		self:SetPlayerGravity()
		self.applygravitydelay = CurTime() + 0.4
	end
	
	if self.exhaust and !self.attacking then self.exhaust = false; self:Exhausted() end
	if self.idledelay and CurTime() >= self.idledelay and !self.dead then
		self.idledelay = CurTime() +3.875
		if !self.exhausted then
			self:StartSchedule(schdIdle)
		else
			self:StartSchedule(schdIdleExhausted)
		end
	elseif self.dead then
		if CurTime() >= self.deadanimdelay then
			self.deadanimdelay = CurTime() +4
			self:StartSchedule(schdDeath)
		end
		for k, v in pairs(self.beams) do
			v[1]:SetPos(self:GetRandomWorldPos(v[2]:GetPos()))
			v[2]:SetPos(self:GetPos())
			//v[2]:SetPos(self:GetAttachment(self:LookupAttachment(tostring(k)))["Pos"])
		end
		return
	end
	
	self.flyveloc = Vector( 0, 0, 0 )
	if ValidEntity( self.enemy ) and self.FoundEnemy then
		local speed = self.h_flyspeed
		local targeth
		local dist = self.enemy:GetPos().z -self:GetPos().z
		//if self:WorldToLocal(self.enemy:GetPos()).z < 0 then dist = dist *-1 end
		local ply = player:GetAll()[1]
		if dist >= -1100 then
			targeth = dist +1200
			
			self:FlyToPos( ( self.flyveloc +Vector(0,0,targeth) ), speed, 1, 1, 0 )
			self.test = nil
		elseif dist <= -1300 then
			targeth = dist -1200
			
			self:FlyToPos( ( self.flyveloc +Vector(0,0,targeth) ), speed, 1, 1, 0 )
			self.test = nil
		else
			self:SetLocalVelocity(self:GetVelocity() *0.85)
		end
	else
		// UP trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, 0, 600 )
		trace.filter = {self, self.hull}

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, 0, -50 )
		end
		
		// DOWN trace
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + Vector( 0, 0, -600 )
		trace.filter = {self, self.hull}

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then 
			self.flyveloc = self.flyveloc + Vector( 0, 0, 50 )
			//self:FlySchedule( schdFlyUp )
		end
		self:SetLocalVelocity( self.flyveloc )
	end
	
	if self.efficient then return end
	self:ValidateRelationships()
end


function ENT:PlayRandomSound(sound)
	local rand = math.random(1,#self.Sounds[sound])
	
	for k, v in pairs(player:GetAll()) do
		v:ConCommand("playgamesound " .. self.Sounds[sound][rand])
	end
end

function ENT:StopSounds()
end

function ENT:Attack_Range_a()
	//self:PlayRandomSound("Attack")
	/*local AttackSounds = {"x/x_attack1.wav", "x/x_attack2.wav", "x/x_attack3.wav"}
	
	local rand = math.random(1,#AttackSounds)
	for k, v in pairs(player:GetAll()) do
		v:ConCommand("playgamesound " .. AttackSounds[rand])
	end*/
	
	self:PlayRandomSound("Attack")
	
	self.idledelay = CurTime() +6.4//6.375
	
	local function lAttak( tar )
		if !tar:IsValid() or self.dead then 
			self.attacking = false
		return end
		self:EmitSound("x/x_ballattack1.wav", 100, 100)
		
		local FireTrace = ((self.enemy:GetPos() + Vector(0,0,10)) - self:GetPos())
		local Firevector = FireTrace:GetNormalized()
		local FireLength = FireTrace:Length()
		local ArriveTime = FireLength / 2000
		local BaseShootVector = Firevector * 2000 + Vector(0,0,300 * ArriveTime)
		controller_disposition = self:Disposition( self.enemy )
		
		self.c_ball_count = 0
		local function c_ball_spawn()
			if self.enemy and ValidEntity( self.enemy ) then
				for i = 2,3 do
					local Vec = self:GetAttachment(self:LookupAttachment(i))["Pos"]
					local c_ball = ents.Create("nihilanth_force_energy")
					c_ball:SetPos( Vec )
					c_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
					c_ball.owner = self
					c_ball.Speed = 140
					c_ball:SetMoveCollide( 3 )
					c_ball.enemy = self.enemy
					c_ball:SetOwner( self )
					c_ball:Spawn()
					local phys = c_ball:GetPhysicsObject()
						phys:SetMass( 1 )
						phys:EnableGravity( false )
						phys:EnableDrag( false )
						phys:ApplyForceCenter( ( self.enemy:GetPos() - Vec ):GetNormal() * 1600 )
				end
				self:EmitSound("debris/zap4.wav", 100, 100)
			end
		end
		c_ball_spawn( self:LocalToWorld( Vector( 30, 0, 30 ) ) )
		if !self.energycritical then
			timer.Create("C_Ball1_timer" .. self.Entity:EntIndex( ), 0.1, 1, c_ball_spawn, self:LocalToWorld( Vector( 25, 0, 27 ) ) )
			timer.Create("C_Ball2_timer" .. self.Entity:EntIndex( ), 0.2, 1, c_ball_spawn, self:LocalToWorld( Vector( 28, 0, 33 ) ) )
			timer.Create("C_Ball3_timer" .. self.Entity:EntIndex( ), 0.3, 1, c_ball_spawn, self:LocalToWorld( Vector( 27, 0, 30 ) ) )
		end
		
		local function attack_end()
			self.attacking = false
		end
		timer.Create("attack_end_timer" .. self.Entity:EntIndex( ), 0.7, 1, attack_end )
	end
	timer.Create( "range_attack_end_timer" .. self.Entity:EntIndex( ), 4.55, 1, lAttak, self.enemy )
end

function ENT:Attack_Range_b()
	self.idledelay = CurTime() +6.4//6.375
	self:PlayRandomSound("Attack")
	
	local function lAttak( tar )
		if !tar:IsValid() or self.dead then self.attacking = false; return end
		local FireTrace = ((self.enemy:GetPos() + Vector(0,0,10)) - self:GetPos())
		local Firevector = FireTrace:GetNormalized()
		local FireLength = FireTrace:Length()
		local ArriveTime = FireLength / 2000
		local BaseShootVector = Firevector * 2000 + Vector(0,0,300 * ArriveTime)
		controller_disposition = self:Disposition( self.enemy )
	
		local c_ball = ents.Create("nihilanth_force_teleport")
		c_ball:SetPos( self:GetPos() +self:GetForward() *50 )
		c_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
		c_ball.owner = self
		c_ball.Speed = 600
		c_ball:SetMoveCollide( 3 )
		c_ball.enemy = self.enemy
		c_ball:SetOwner( self )
		c_ball:Spawn()
		
		local phys = c_ball:GetPhysicsObject()
			phys:SetMass( 1 )
			phys:EnableGravity( false )
			phys:EnableDrag( false )
			
		local function attack_end()
			self.attacking = false
		end
		timer.Create("attack_end_timer" .. self.Entity:EntIndex( ), 0.7, 1, attack_end )
	end
	timer.Create( "range_attack_end_timer" .. self.Entity:EntIndex( ), 4.6, 1, lAttak, self.enemy )
end

function ENT:CanRecharge()
	if self.exhausted then return false end
	local Ents = ents.FindByClass("nihilanth_crystal")
	if #self.forces < 14 and #Ents > 0 then
		local visible
		for k, v in pairs(Ents) do
			if self:Visible( v ) then visible = true end
		end
		if visible then return true else return false end
	else return false end
end

function ENT:Recharge()
	self.idledelay = CurTime() +6.375
	self:PlayRandomSound("Attack")
	
	self:StartSchedule(schdRecharge)
	self.attacking = true
	
	local crystals = {}
	for k, v in pairs(ents.FindByClass("nihilanth_crystal")) do
		if self:Visible(v) then
		/*local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = v:GetPos()
		tracedata.filter = {self,self.hull}
		local trace = util.TraceLine(tracedata)
		if ValidEntity(trace.Entity) and trace.Entity == v then*/
		table.insert(crystals,v)
		end
	end
	if #crystals == 0 then self.attacking = false; return end
	timer.Destroy("Exhaust_timer" .. self:EntIndex())
	timer.Destroy("Energy_crit_timer" .. self:EntIndex())
	
	local frcpercrystal = math.ceil((20 -#self.forces) /#crystals)
	for k, v in pairs(crystals) do
		if #self.forces < 20 then
			local delay = 0
			for i = 1, frcpercrystal do
				timer.Simple(delay, function() if ValidEntity(self) and ValidEntity(v) and #self.forces < 20 then
				local e_ball = ents.Create("nihilanth_force")
				e_ball:SetPos( v:GetPos() +Vector(0,0,60) )
				e_ball:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
				e_ball.owner = self
				e_ball.radius = math.random(300,400)
				e_ball.height = math.random(200,400)
				e_ball.speed = math.random(500,600)
				e_ball.delay = math.Rand(0,6)
				
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
				self.damagelevel = 20 -#self.forces
				self.energy = (#self.forces /20) *1500
				end end)
				delay = delay +0.15
			end
		end
	end
	timer.Simple(6.8, function() if ValidEntity(self) then self.attacking = false end end)
end

function ENT:OnDeath()
	local fade = ents.Create("env_fade")
	fade:SetKeyValue("duration","0.5")
	fade:SetKeyValue("holdtime","0.5")
	fade:SetKeyValue("renderamt","255")
	fade:SetKeyValue("rendercolor","0 210 0")
	fade:SetKeyValue("spawnflags","1")
	fade:Spawn()
	fade:Activate()
	fade:Fire("fade","",0)
	fade:Fire("kill","",0.5)
	
	self:PlayRandomSound("DeathEnd")
	self:Remove()
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamageHull(dmg)
	self:SpawnBloodEffect( self.BloodType, dmg:GetDamagePosition() )
	if self.dead then return end
	if self.exhausted and self.ScaleDmg then dmg:SetDamage(dmg:GetDamage() /self.ScaleDmg) end
	if self.exhausted then self:SetHealth(self:Health() - dmg:GetDamage()) end
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
	
	//if self.RunMeleeDistance and self:CheckEnemy( 1 ) and self.enemy:GetPos():Distance( self:GetPos() ) < self.RunMeleeDistance and self.enemy:GetPos():Distance( self:GetPos() ) > self.MeleeDistance then
	//	self.hidecur = CurTime() +4
	//	self.hiding = true
	//end
	
	if self.damagelevel < 20 then
		self.energy = self.energy -dmg:GetDamage()
		local energy = self.energy
		local energy_max = 1500
		local damage_level = math.floor((energy_max -energy) /energy_max *20)
		if energy <= 0 then
			timer.Simple(math.Rand(5,8), function() if !ValidEntity(self) then return end; self.gocrazy = true end)
			damage_level = 20
			local rand = math.Rand(20,30)
			timer.Create("Exhaust_timer" .. self:EntIndex(), rand, 1, function() if ValidEntity(self) then self.exhaust = true end end)
			
			timer.Create("Energy_crit_timer" .. self:EntIndex(), rand +6, 1, function() if ValidEntity(self) then self.energycritical = true end end)
		end
		if damage_level > self.damagelevel then
			for i = 1, damage_level -self.damagelevel do
				local frc = self.forces[1]
				if ValidEntity(frc) then self:RemoveForce(frc) end
			end
			self.damagelevel = damage_level
		end
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
		//self:StartSchedule( schdHurt )
		//self:EmitSound( self.PainSound ..math.random(1,self.PainSoundCount) .. ".wav", 500, 100)
		
		//self:PlayRandomSound("Pain")
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
		self.shake = ents.Create("env_shake")
		self.shake:SetKeyValue("amplitude","4")
		self.shake:SetKeyValue("radius","5000")
		self.shake:SetKeyValue("duration","30")
		self.shake:SetKeyValue("frequency","2.5")
		self.shake:Spawn()
		self.shake:Activate()
		self.shake:Fire("StartShake","",0)
		self.shake:Fire("kill","",6)
	
		self.deathsound = ents.Create("ambient_generic")
		self.deathsound:SetKeyValue("message","ambience/alien_minddrill.wav")
		self.deathsound:SetKeyValue("health","10")
		self.deathsound:SetKeyValue("spawnflags","17")
		self.deathsound:Spawn()
		self.deathsound:Activate()
		self.deathsound:Fire("PlaySound","",0)
		
		self:SetLocalVelocity(Vector(0,0,0))
		
		timer.Create("DeathGibTimer" .. self:EntIndex(), 0.4, 100, function() self:ShootDeathGib() end)

		self.dead = true
		self.deadanimdelay = CurTime()
		self:CreateBeams()
		timer.Simple(8, function() if ValidEntity(self) then self:StartDeathEnd() end end)
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

function ENT:ShootDeathGib()
	local gib = ents.Create("sent_gib")
	gib:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	gib:SetPos(self:GetPos() +Vector(0,0,375))
	gib:Spawn()
	gib:Activate()
	gib:SetOwner(self.hull)
	local phys = gib:GetPhysicsObject()
		phys:Wake()
		phys:EnableGravity(false)
		phys:SetMass( 1 )
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio( 0.1 )
		phys:ApplyForceCenter(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(0.5,1)) *150)
		
	local sprite = ents.Create("env_sprite")
	sprite:SetKeyValue("rendermode", "5")
	sprite:SetKeyValue("model", "sprites/exit1.vmt")
	sprite:SetKeyValue("scale", "1")
	sprite:SetKeyValue("spawnflags", "1")
	sprite:SetPos(gib:GetPos())
	sprite:SetParent(gib)
	sprite:Spawn()
	sprite:Activate()
	
	gib:Fire("kill","",5)
	sprite:Fire("kill","",5)
end

function ENT:StartDeathEnd()
	local function CreateSprite(size, pos)
		if !ValidEntity(self) then return end
		local shake = ents.Create("env_sprite")
		shake:SetKeyValue("spawnflags","3")
		shake:SetKeyValue("GlowProxySize","2")
		shake:SetKeyValue("scale","25")
		shake:SetKeyValue("framerate","10")
		shake:SetKeyValue("model","sprites/Fexplo1.spr")
		shake:SetKeyValue("rendercolor","77 210 130")
		shake:SetKeyValue("renderamt","255")
		shake:SetKeyValue("rendermode","5")
		shake:SetKeyValue("renderfx","14")
		shake:SetPos(pos)
		shake:Spawn()
		shake:Activate()
		shake:Fire("kill","",6)
	
		self:PlayRandomSound("DeathEnd2")
		//WorldSound( "debris/beamstart8.wav", Vector(0,0,0) )
	end
	local pos = self:GetPos()
	local forward = self:GetForward()
	local right = self:GetRight()
	
	CreateSprite(15,pos +forward *800)
	local delay = 1
	for i = 0, 20 do
		local spawnpos = pos +forward *math.Rand(-650,650) +right *math.Rand(-650,650)
		timer.Simple(delay, function() CreateSprite(15,spawnpos) end)
		delay = delay +math.Rand(0.18, 0.75)
	end
	
	timer.Simple(10, function() if ValidEntity(self) then self:OnDeath() end end)
end

function ENT:OnTakeDamage(dmg)
end

function ENT:GetRandomWorldPos(startpos)
	local x = 1
	local y = 1
	local z = 1
	if math.random(1,2) == 2 then x = -1 end
	if math.random(1,2) == 2 then y = -1 end
	if math.random(1,2) == 2 then z = -1 end
	local normal = Vector(math.Rand(0,x),math.Rand(0,y),math.Rand(0,z))
	local Vec = startpos +normal *99999
	
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = Vec
	tracedata.filter = {self,self.hull}
	local trace = util.TraceLine(tracedata)
	return trace.HitPos
end

function ENT:CreateBeams()
	for i = 0,3 do
		local beam_target = ents.Create("info_target")
		beam_target:SetName(tostring(self) .. "_laser" .. beam_target:EntIndex() .. "_target")
		beam_target:SetPos(self:GetPos())
		beam_target:Spawn()
		beam_target:Activate()
		
		local beam = ents.Create("env_beam")
		beam:SetName(tostring(self) .. "_laser" .. beam:EntIndex())
		beam:SetKeyValue("life","0.2")
		beam:SetKeyValue("Radius","99999")
		beam:SetKeyValue("LightningEnd",tostring(self) .. "_laser" .. beam_target:EntIndex() .. "_target")
		beam:SetKeyValue("LightningStart",tostring(self) .. "_laser" .. beam:EntIndex())
		beam:SetKeyValue("NoiseAmplitude","10")
		beam:SetKeyValue("renderamt","255")
		beam:SetKeyValue("rendercolor","0 75 255")
		beam:SetKeyValue("BoltWidth","10")
		beam:SetKeyValue("texture","sprites/laserbeam.spr")
		beam:SetKeyValue("spawnflags","5")
		beam:SetKeyValue("StrikeTime","0")
		beam:SetKeyValue("TextureScroll","35")
		beam:Spawn()
		beam:Activate()
		beam:SetPos(self:GetRandomWorldPos(beam_target:GetPos()))
		
		self.beams[i] = {beam,beam_target}
	end
end

function ENT:SpawnAlly(pos, class)
	local ally = ents.Create(class)
	ally:SetPos(pos)
	ally:SetAngles(self:GetAngles())
	ally.enemy_memory = self.enemy_memory
	ally.enemy = self.enemy
	ally.squadtable = {}
	ally.squad = tostring(self) .. "_squad"
	ally:Spawn()
	ally:Activate()
	ally:SetupSquad()
	
	ally:EmitSound("debris/beamstart" .. math.random(1,2) .. ".wav",100,100)
	
	local sprite = ents.Create("env_sprite")
	sprite:SetKeyValue("rendermode", "5")
	sprite:SetKeyValue("model", "sprites/exit1.vmt")
	sprite:SetKeyValue("scale", "1")
	sprite:SetKeyValue("spawnflags", "1")
	sprite:SetPos(pos)
	sprite:Spawn()
	sprite:Activate()
	sprite:Fire("kill","",0.3)
end

function ENT:GoCrazy()
	self:PlayRandomSound("Attack")
	self:StartSchedule(schdSpawnAllies)
	
	local shake = ents.Create("env_shake")
	shake:SetKeyValue("amplitude","4")
	shake:SetKeyValue("radius","5000")
	shake:SetKeyValue("duration","30")
	shake:SetKeyValue("frequency","2.5")
	shake:Spawn()
	shake:Activate()
	shake:Fire("StartShake","",0)
	shake:Fire("StopShake","",5.9)
	shake:Fire("kill","",6)

	for k,v in pairs(player:GetAll()) do
		//v:ConCommand("pp_mat_overlay 1")
		//v:ConCommand("pp_mat_overlay_texture effects/advisoreffect/advisorblast1.vmt")
		v:ConCommand("playgamesound npc/antlion/rumble1.wav")
		v:ConCommand("playgamesound ambient/levels/intro/rhumble_1_42_07.wav")
		v:ConCommand("playgamesound ambient/levels/labs/teleport_mechanism_windup1.wav")
		v:ConCommand("playgamesound ambient/levels/citadel/portal_open1_adpcm.wav")
		v:ConCommand("playgamesound ambient/levels/citadel/portal_open1_adpcm.wav")
	end
	
	timer.Simple(2.4, function()
	for i = 1, math.random(5,7) do
		local normal = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))
		local pos = self:GetPos() +(normal *math.random(600, 800))
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = pos
		tracedata.filter = {self, self.hull}
		local trace = util.TraceLine(tracedata)
		if !trace.Hit then
			self:SpawnAlly(pos, "monster_alien_controller")
			
			WorldSound( "debris/beamstart" .. math.random(1,2) .. ".wav", pos )
		end
	end
	for i = 1, 3 do
		local rand = math.random(1,2)
		local class
		if rand == 1 then
			class = "monster_alien_grunt"
		else
			class = "monster_alien_slave"
		end
		local normal = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))
		local pos = self:GetPos() +(normal *math.random(600, 800))
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = tracedata.start +Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-0.25,-1)) *5000
		tracedata.filter = {self, self.hull}
		local trace = util.TraceLine(tracedata)
		if trace.HitWorld then
			pos = trace.HitPos +trace.HitNormal *20
			self:SpawnAlly(pos, class)
			WorldSound( "debris/beamstart" .. math.random(1,2) .. ".wav", pos )
		end
	end
	end)
end


function ENT:RemoveForce(frc)
	local tbl_new = {}
	for k, v in pairs(self.forces) do
		if v != frc then
			table.insert(tbl_new,v)
		else
			v:Absorb()
		end
	end
	self.forces = tbl_new
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient or self.dead then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	
	if !self.attacking and self:CanRecharge() then self:Recharge(); return end
	if( /*( self.FoundEnemy or self.FoundEnemy_fear ) and*/ !self.attacking and convar_ai == 0 ) then
		if self.gocrazy then self.gocrazy = false; self:GoCrazy(); return end
		if !self.searchdelay then
			self.searchdelay = CurTime() +0.15
		end
		local enemy_tbl
		if self.searchdelay < CurTime() then
			enemy_tbl = self:FindInCone( 20000 )
			self.searchdelay = nil
		end
		if enemy_tbl then self:UpdateMemory(enemy_tbl) end
		local Pos = self:GetPos()
		if self.enemy then self:CheckEnemy( 1 ) end
		if self.enemy_fear then self:CheckEnemy( 3 ) end
		if( self.enemy and ValidEntity( self.enemy ) and self.enemy:GetPos():Distance( self:GetPos() ) <= self.closest_range ) then
			if( self.enemy:GetPos():Distance( Pos ) < self.RangeDistance ) then//and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				self.attacking = true
				self.idle = 0
				//if !self.range_sec_charged then
					local rand = math.random( 1, 3 )
					if rand != 3 or self.exhausted then
						if !self.exhausted then
							self:StartSchedule( schdRangeAttack_a )
						else
							self:StartSchedule( schdRangeAttack_a_exhausted )
						end
						self:Attack_Range_a()
					else
						if !self.exhausted then
							self:StartSchedule( schdRangeAttack_b )
						else
							self:StartSchedule( schdRangeAttack_b_exhausted )
						end
						self:Attack_Range_b()
					end
				/*else
					local rand = math.random( 1, 3 )
					if rand == 3 then
						self:StartSchedule( schdRangeAttack_b )
						self:Attack_Range_b()
					else
						self.attacking = false
					end
					self.range_sec_charged = false
					timer.Destroy( "sec_attack_recharge_timer" .. self:EntIndex() )
				end*/
				if !self.range_sec_charged and !timer.IsTimer( "sec_attack_recharge_timer" .. self:EntIndex() ) then
					timer.Create( "sec_attack_recharge_timer" .. self:EntIndex(), math.Rand( 8, 20 ), 1, function() self.range_sec_charged = true end )
				end
			elseif( self:HasCondition( 42 ) ) then
				self:UpdateEnemyMemory( self.enemy, self.enemy:GetPos() )
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 900 ) or !self.following ) then
				timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
				self:SetEnemy( self.enemy, true )
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
			end
		/*elseif( ( !self.enemy or !ValidEntity(self.enemy) ) and self.enemy_fear and ValidEntity(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) */
		else
			self.closest_range = 20000
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
			//self:PlayRandomSound("Idle")
			timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
			//timer.Create( "wandering_timer" .. self.Entity:EntIndex( ), math.random(10,14), 1, wandering_schd )
		end
	else
		timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	end
end 

function ENT:KeyValue( key, value )
	if key == "hammerid" then
		self.mapentity = true
	end
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
	for k, ply in pairs(player:GetAll()) do
		ply:SetGravity(1)
	end
	if self.init then
		for k, v in pairs(self.crystals) do if ValidEntity(v) then v:Remove() end end
		if ValidEntity(self.deathsound) then self.deathsound:Fire("Volume", "0", 0); self.deathsound:Remove() end
		if ValidEntity(self.shake) then self.shake:Fire("StopShake","",0); self.shake:Remove() end
		for k, v in pairs(self.beams) do
			for l, w in pairs(v) do
				w:Remove()
			end
		end
		if ValidEntity(self.core) then self.core:Remove() end
		for k, v in pairs(self.forces) do
			v:Remove()
		end
		if ValidEntity(self.hull) then self.hull:Remove() end
		self:StopSounds()
	end
	
	timer.Destroy("DeathGibTimer" .. self:EntIndex())
	timer.Destroy("Exhaust_timer" .. self:EntIndex())
	timer.Destroy("Energy_crit_timer" .. self:EntIndex())
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
	timer.Destroy( "c_ball_pos_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "throw_c_ball_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "sec_attack_recharge_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
end