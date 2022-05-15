
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
	 
		dmginfo:ScaleDamage( 3 )
	 
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
