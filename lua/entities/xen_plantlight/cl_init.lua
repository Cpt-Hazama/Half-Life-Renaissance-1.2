include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
	//Msg( "Drawing!!! \n" )
	self.Entity:DrawModel()
	
	//local attachmentpos = self:GetAttachment( self:LookupAttachment("0") ) 
	//render.DrawSprite( attachmentpos, 32, 32, Color( 255, 141, 15, 255 ) )
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()
end

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()
	self:Draw()
end
