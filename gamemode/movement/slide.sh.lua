SlideService = SlideService or {}

-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.slide_minimum = 0.71
	ply.slide_hover_height = 2
	ply.can_slide_ramp = false
	ply.old_slide_velocity = Vector( )
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)

-- # Utility

function SlideService.Clip(velocity, plane)
	return velocity - ( plane * velocity:Dot( plane ) )
end

function SlideService.GetGroundTrace(pos, endpos, ply)

	return util.TraceHull(
  {
		start = pos,
    endpos = endpos,
    mins = ply:OBBMins( ),
    maxs = ply:OBBMaxs( ),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	})
end

function SlideService.ShouldSlide(velocity, trace, surf_min, can_slide_ramp)
	local should_slide
	if trace.HitWorld and trace.HitNormal.z > surf_min and trace.HitNormal.z < 1 then // Trace hit world and is on a ramp
    should_slide = velocity.z > 130 or (can_slide_ramp and -130 > velocity.z)
	elseif trace.HitWorld and trace.HitNormal.z <= surf_min and trace.HitNormal.z > 0 then // Trace hit world and is on a surfable ramp
		should_slide = true
	else //Trace did not hit world or is on flat ground.
    should_slide = false
	end
	return should_slide
end

// Issue with sometimes hitting an exact spot between two surf ramps might cause the player to take damage
function SlideService.HandleRampDamage(ply)
  local vel = ply:GetVelocity( )
	local pred_pos = ply:GetPos( ) + ( vel * FrameTime( ) ) // Fixes an issue with not taking damage when you should at the bottom of a surf
	local trace = SlideService.GetGroundTrace( pred_pos, pred_pos - Vector( 0, 0, 10 ), ply )
  if SlideService.ShouldSlide( SlideService.Clip( vel, trace.HitNormal ), trace, ply.slide_minimum, ply.can_slide_ramp ) then
		ply:SetGroundEntity( NULL )
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleRampDamage", SlideService.HandleRampDamage)

-- # Sliding

function SlideService.SetupRamp( ply, move )
	local trace, slide_velocity, predicted_trace, predicted_slide_velocity
	local pos = move:GetOrigin( )
	local frametime = FrameTime( )
  local primal_velocity = move:GetVelocity( )
  local next_velocity = primal_velocity * frametime
	local secondPredict = false
  local endpos = pos * 1
	endpos.z = ( endpos.z - ply.slide_hover_height ) + math.min( next_velocity.z, 0 )  // Predicted the movement the next frame if going quickly downwards
  trace = SlideService.GetGroundTrace( pos, endpos, ply )
  slide_velocity = SlideService.Clip( primal_velocity, trace.HitNormal )

  endpos.x = endpos.x + next_velocity.x //Trace prediction
  endpos.y = endpos.y + next_velocity.y
  predicted_trace = SlideService.GetGroundTrace( pos, endpos, ply ) // Fixes a problem with taking fall damage when hitting the ramps at a certain angle.
  predicted_slide_velocity = SlideService.Clip( primal_velocity, predicted_trace.HitNormal )

	// Had an issue with when going from a regular surf to a surf ramp that used to be walkable you would take damage and lose your speed.
	// This fixes that issue.
	if !predicted_trace.HitWorld && ply.old_slide_velocity then
		endpos = pos * 1
		endpos.z = ( endpos.z - ply.slide_hover_height ) + math.min( ply.old_slide_velocity.z * frametime, 0 )
		endpos.x = endpos.x + ply.old_slide_velocity.x * frametime
		endpos.y = endpos.y + ply.old_slide_velocity.y * frametime

		predicted_trace = SlideService.GetGroundTrace( pos, endpos, ply )
  	predicted_slide_velocity = SlideService.Clip( ply.old_slide_velocity, predicted_trace.HitNormal )
		secondPredict = true
	end

	if SlideService.ShouldSlide( predicted_slide_velocity, predicted_trace, ply.slide_minimum, ply.can_slide_ramp ) then
		local velocity = predicted_slide_velocity
	  if trace.HitWorld then // Fixes a problem which stop you from surfing down or stucks you.
	    pos.z = trace.HitPos.z + ply.slide_hover_height
	    if predicted_trace.HitNormal == trace.HitNormal then
	      velocity = slide_velocity
	    end
	  else
	    pos.z = predicted_trace.HitPos.z + ply.slide_hover_height
	  end
		ply.old_slide_velocity = velocity
	  move:SetVelocity( velocity )
	  move:SetOrigin( pos )
		ply:SetGroundEntity( NULL )
	elseif SlideService.ShouldSlide( slide_velocity, trace, ply.slide_minimum, ply.can_slide_ramp ) then
		local velocity = slide_velocity
		pos.z = trace.HitPos.z + ply.slide_hover_height
		ply.old_slide_velocity = velocity
		move:SetVelocity( velocity )
	  move:SetOrigin( pos )
		ply:SetGroundEntity( NULL )
	else
		// Resets incase secondPredict randomly activates upon switching from one surf ramp to another and doesn't send you in some random direction.
		ply.old_slide_velocity = nil
	end

end
hook.Add("SetupMove", "SlideService.SetupRamp", SlideService.SetupRamp)
