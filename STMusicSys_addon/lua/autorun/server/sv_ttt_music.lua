--[[
	Server file for the CMS (Custom Music System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file sends the round result when it ends to play the right music.
    There's a different song for innocents and traitors winning.

    The Custom Music System plays music the user set up at various states.
    This never really took off because it requires a lot of setup by the end user,
    but in my opinion it's better than servers forcing bad music.
]]--

util.AddNetworkString( "STTTSendRoundResult" )

hook.Add( "TTTEndRound", "STTTEndRoundMusic", function( res )
    net.Start( "STTTSendRoundResult" )
        net.WriteInt( res, 32 ) -- this could probably be less than 32 bits
    net.Broadcast()
end )