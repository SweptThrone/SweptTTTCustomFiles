--[[
	Server file for the FLS (Fair Loadout System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file stores and gives the player's weapons for next round.
    It only stores and gives weapons that spawn naturally, no T or D weapons and no ammo.

    The Fair Loadout System allows players to bring their weapons into the next round.
    On my server, I enabled the post-round deathmatch, so this was like a fun minigame at the end of rounds.
    Free-for-all and whoever survives keeps their weapons.
]]--

util.AddNetworkString( "loadoutmsg" )

local plyMeta = FindMetaTable( "Player" )
function plyMeta:GetWeaponInSlot( slot )
    for k,v in pairs( self:GetWeapons() ) do
        if v.Kind == slot then
            return v
        end
    end
end

hook.Add( "TTTEndRound", "SaveLoadout", function()
    for k,v in pairs( player.GetAll() ) do
        if IsValid( v ) and v:Alive() then
            v.STLoadout = {}
            -- 1 -> pistol, 2 -> primary, 3 -> grenade
            for i = 2, 4 do
                if v:GetWeaponInSlot( i ) and v:GetWeaponInSlot( i ).AutoSpawnable then
                    v.STLoadout[ v:GetWeaponInSlot( i ):GetClass() ] = true
                end
            end
            net.Start( "loadoutmsg" )
            net.Send( v )
        end
    end
end )

hook.Add( "PlayerDroppedWeapon", "LoadoutDropWeapon", function( ply, wep )
    if GAMEMODE.round_state == ROUND_POST and IsValid( ply ) and IsValid( wep ) and ply.STLoadout then
        ply.STLoadout[ wep:GetClass() ] = false
    end
end )

hook.Add( "WeaponEquip", "LoadoutEquipWeapon", function( wep, ply )
    if GAMEMODE.round_state == ROUND_POST and IsValid( ply ) and IsValid( wep ) and ply.STLoadout and wep.AutoSpawnable then
        ply.STLoadout[ wep:GetClass() ] = true
    end
end )

hook.Add( "TTTPrepareRound", "LoadoutGiveLoadout", function()
    timer.Simple( 1, function()
        for k,v in pairs( player.GetAll() ) do
            if v.STLoadout then
                for a,b in pairs( v.STLoadout ) do
                    if b then
                        if !v:CanCarryWeapon( weapons.Get( a ) ) then
                            v:DropWeapon( v:GetWeaponInSlot( weapons.Get( a ).Kind ) )
                        end
                        v:Give( a )
                    end
                end
                v.STLoadout = {}
            end
        end
    end )
end )

hook.Add( "PlayerDeath", "LoadoutDeleteLoadout", function( ply )
    ply.STLoadout = {}
end )