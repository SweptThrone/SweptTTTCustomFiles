--[[
	Client file for the FLS (Fair Loadout System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file notifies the player of how they can keep their weapons.

    The Fair Loadout System allows players to bring their weapons into the next round.
    On my server, I enabled the post-round deathmatch, so this was like a fun minigame at the end of rounds.
    Free-for-all and whoever survives keeps their weapons.
]]--

local BASE_TEXT_COLOR = Color( 255, 255, 128 ) --yellow
local PLAYER_TEXT_COLOR = Color( 128, 255, 128 )
local STATUS_COLOR = Color( 255, 128, 128 )

net.Receive( "loadoutmsg", function()
    chat.AddText( BASE_TEXT_COLOR, "Survive the deatchmatch to", PLAYER_TEXT_COLOR, " keep your weapons ", BASE_TEXT_COLOR, "for next round!" )
end )