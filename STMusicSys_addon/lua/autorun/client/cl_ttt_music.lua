--[[
	Client file for the CMS (Custom Music System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file plays music the user added.

    The Custom Music System plays music the user set up at various states.
    This never really took off because it requires a lot of setup by the end user,
    but in my opinion it's better than servers forcing bad music.
]]--

local hasPlayedMusic = false

hook.Add( "TTTBeginRound", "STTTStartRoundMusic", function()
    if LocalPlayer():IsTraitor() then
        if !file.Exists( "sound/sweptttt/round_start_traitor.wav", "GAME" ) then
            print( "You can add a round_start_traitor.wav file to your own sound/sweptttt/ folder to have music play now." )
        else
            surface.PlaySound( "sweptttt/round_start_traitor.wav" )
        end
    elseif LocalPlayer():IsDetective() then
        if !file.Exists( "sound/sweptttt/round_start_detective.wav", "GAME" ) then
            print( "You can add a round_start_detective.wav file to your own sound/sweptttt/ folder to have music play now." )
        else
            surface.PlaySound( "sweptttt/round_start_detective.wav" )
        end
    else
        if !file.Exists( "sound/sweptttt/round_start_detective.wav", "GAME" ) then
            print( "You can add a round_start_innocent.wav file to your own sound/sweptttt/ folder to have music play now." )
        else
            surface.PlaySound( "sweptttt/round_start_innocent.wav" )
        end
    end
end )

hook.Add( "Tick", "STTTPreparingMusic", function()

    if math.ceil( GetGlobalFloat( "ttt_round_end", 0 ) - CurTime() ) == 30 and !hasPlayedMusic and GAMEMODE.round_state == ROUND_PREP then
        if !file.Exists( "sound/sweptttt/round_warmup.wav", "GAME" ) then
            print( "You can add a 30-second round_warmup.wav file to your own sound/sweptttt/ folder to have music play now." )
        else
            surface.PlaySound( "sweptttt/round_warmup.wav" )
		end
        hasPlayedMusic = true
    end
end )

net.Receive( "STTTSendRoundResult", function()

    local res = net.ReadInt( 32 )

    if res == WIN_TRAITOR then
        if LocalPlayer().IsTraitor and LocalPlayer():IsTraitor() then
            if !file.Exists( "sound/sweptttt/traitors_win_traitor.wav", "GAME" ) then
                print( "You can add a traitors_win_traitor.wav file to your own sound/sweptttt/ folder to have music play now." )
            else
                surface.PlaySound( "sweptttt/traitors_win_traitor.wav" )
            end
        else
            if !file.Exists( "sound/sweptttt/traitors_win_innocent.wav", "GAME" ) then
                print( "You can add a traitors_win_innocent.wav file to your own sound/sweptttt/ folder to have music play now." )
            else
                surface.PlaySound( "sweptttt/traitors_win_innocent.wav" )
            end
        end
    else
        if LocalPlayer():IsTraitor() then
            if !file.Exists( "sound/sweptttt/innocent_win_traitor.wav", "GAME" ) then
                print( "You can add a innocent_win_traitor.wav file to your own sound/sweptttt/ folder to have music play now." )
            else
                surface.PlaySound( "sweptttt/innocent_win_traitor.wav" )
            end
        else
            if !file.Exists( "sound/sweptttt/innocent_win_innocent.wav", "GAME" ) then
                print( "You can add a innocent_win_innocent.wav file to your own sound/sweptttt/ folder to have music play now." )
            else
                surface.PlaySound( "sweptttt/innocent_win_innocent.wav" )
            end
        end
    end
    hasPlayedMusic = false

end )