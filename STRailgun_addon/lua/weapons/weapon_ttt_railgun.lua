AddCSLuaFile()
SWEP.CSMuzzleX = true
SWEP.Tracer = "ToolTracer"
SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Railgun"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = true
   SWEP.ViewModelFOV       = 70

   SWEP.Icon               = "vgui/ttt/icon_scout"
   SWEP.IconLetter         = "n"
   
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "Charge-up sniper rifle with explosive rounds.\n\nExplosions are small, and you only get three!"
   }
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_EQUIP1
SWEP.WeaponID              = nil

SWEP.Primary.Delay         = 1.5
SWEP.Primary.Recoil        = 7
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = nil
SWEP.Primary.Damage        = 25
SWEP.Primary.Cone          = 0.005
SWEP.Primary.ClipSize      = 3
SWEP.Primary.ClipMax       = 20 -- keep mirrored to ammo
SWEP.Primary.DefaultClip   = 3
sound.Add( {
	name = "Weapon_Railgun.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "weapons/railgun/railgun-fire.wav"
} )
sound.Add( {
	name = "Weapon_Railgun.ChargeStart",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = 100,
	sound = "weapons/railgun/railgun-chargestart.wav"
} )
sound.Add( {
	name = "Weapon_Railgun.ChargeCancel",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = 100,
	sound = "weapons/railgun/railgun-chargecancel.wav"
} )
SWEP.Primary.Sound         = Sound( "Weapon_Railgun.Single" )

SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = { nil }
SWEP.LimitedStock = true

SWEP.Secondary.Sound       = Sound("Default.Zoom")

SWEP.HeadshotMultiplier    = 1

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = true
SWEP.AmmoEnt               = nil

SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/v_snip_scout.mdl")
SWEP.WorldModel            = Model("models/weapons/w_snip_scout.mdl")

SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )

function SWEP:SetZoom(state)
   if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
      if state then
         self:GetOwner():SetFOV(20, 0.3)
      else
         self:GetOwner():SetFOV(0, 0.2)
      end
   end
end

function SWEP:PrimaryAttack()

   if !self:GetCharging() then
      self:SetCharging( true )
      self:EmitSound( "Weapon_Railgun.ChargeStart" )
      self:SetChargeEnd( CurTime() + 1.793 )
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim(self.PrimaryAnim)

   self:GetOwner():MuzzleFlash()
   self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

   local sights = self:GetIronsights()

   numbul = numbul or 1
   cone   = cone   or 0.01

   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self:GetOwner():GetShootPos()
   bullet.Dir    = self:GetOwner():GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 1
   bullet.TracerName = self.Tracer or "Tracer"
   bullet.Force  = 10
   bullet.Damage = dmg
   bullet.Callback = function()
        if SERVER then
            local explode = ents.Create( "env_explosion" ) //creates the explosion
            explode:SetPos( self.Owner:GetEyeTrace().HitPos )
            explode:Spawn()
            explode:EmitSound( "weapons/railgun/railgun-expl.wav", SNDLVL_GUNFIRE )
            explode:SetKeyValue( "spawnflags", bit.bor( 16, 64, 2048, 128, 256, 512 ) )
            explode:SetKeyValue( "iMagnitude", 75 )
            explode:Fire( "Explode", 0, 0 )
        end
   end

   self:GetOwner():FireBullets( bullet )

   -- Owner can die after firebullets
   if (not IsValid(self:GetOwner())) or (not self:GetOwner():Alive()) or self:GetOwner():IsNPC() then return end

   if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then

      -- reduce recoil if ironsighting
      recoil = sights and (recoil * 0.6) or recoil

      local eyeang = self:GetOwner():EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self:GetOwner():SetEyeAngles( eyeang )
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   self:SetZoom(bIronsights)
   if (CLIENT) then
      self:EmitSound(self.Secondary.Sound)
   end

   self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   self:SetCharging( false )
   self:SetChargeEnd( 0 )
   self.LoopSound:Stop()
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload( ACT_VM_RELOAD )
   self:SetIronsights( false )
   self:SetZoom( false )
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   self:SetCharging( false )
   self:SetChargeEnd( 0 )
   self.LoopSound:Stop()
   return true
end

function SWEP:OnRemove()
   self:SetCharging( false )
   self:SetChargeEnd( 0 )
   self.LoopSound:Stop()
end

DEFINE_BASECLASS( SWEP.Base )

function SWEP:Initialize()
   BaseClass.Initialize( self )
   
   self.LoopSound = CreateSound( self, "weapons/railgun/railgun-chargeloop.wav" )
   self.LoopSoundLastPlay = 0
end

function SWEP:Think()
   BaseClass.Think( self )
   if self:GetCharging() and CurTime() >= self:GetChargeEnd() and !self.LoopSound:IsPlaying() then
      if IsFirstTimePredicted() then
         local readySpark = EffectData()
         readySpark:SetOrigin( self:GetPos() )
         util.Effect( "CrossbowLoad", readySpark )
         self.LoopSound:Play()
      end
   end
   if !self:GetOwner():KeyDown( IN_ATTACK ) and self:GetCharging() then
      if CurTime() < self:GetChargeEnd() then
         self:EmitSound( "weapons/railgun/railgun-chargecancel.wav" )
      else
         BaseClass.PrimaryAttack( self )
      end
      self:SetCharging( false )
      self:SetChargeEnd( 0 )
      self.LoopSound:Stop()
   end
   if !IsValid( self:GetOwner() ) or !self:GetOwner():Alive() then
      self.LoopSound:Stop()
   end
end

function SWEP:SetupDataTables()
   BaseClass.SetupDataTables( self )
   self:NetworkVar("Bool", 4, "Charging")
   self:NetworkVar("Float", 4, "ChargeEnd" )

   if SERVER then
      self:SetCharging( false )
      self:SetChargeEnd( 0 )
   end
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end

function SWEP:PreDrawViewModel( vm ) -- Paint the deagle before drawing it
   Material("models/weapons/v_models/snip_scout/snip_scout"):SetVector("$color2", Vector(0.5, 1, 1) )
   if self:GetCharging() then
      vm:SetPos( vm:GetPos() - ( vm:GetForward() * math.Clamp( CurTime() + 1.8 - self:GetChargeEnd(), 0, 1.8 ) * 2 ) + 
         ( vm:GetRight() * math.Clamp( CurTime() + 1.8 - self:GetChargeEnd(), 0, 1.8 ) * math.Rand( 0, 0.1 ) ) +
         ( vm:GetUp() * math.Clamp( CurTime() + 1.8 - self:GetChargeEnd(), 0, 1.8 ) * math.Rand( 0, 0.1 ) ) )
   end
end


function SWEP:PostDrawViewModel( vm ) -- Paint it back
   Material("models/weapons/v_models/snip_scout/snip_scout"):SetVector("$color2", Vector(1, 1, 1) )
end

function SWEP:DrawWorldModel()
	self:SetColor( Color( 128, 255, 255 ) )
	self:DrawModel()
end