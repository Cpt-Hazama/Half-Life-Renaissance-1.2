
/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	return false
end

/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
---------------------------------------------------------*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 2 )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.5 )
	 
	 end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function GM:PlayerDeath( Victim, Inflictor, Attacker )

	// Don't spawn for at least 2 seconds
	Victim.NextSpawnTime = CurTime() + 1.2
	
	Victim.longjump = false
	GAMEMODE:SetPlayerSpeed( Victim, 500, 500 )

	// Convert the inflictor to the weapon that they're holding if we can.
	// This can be right or wrong with NPCs since combine can be holding a 
	// pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = Attacker end
	
	end
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( Inflictor:GetClass() )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( Inflictor:GetClass() )
		umsg.String( Attacker:GetClass() )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
	
end
