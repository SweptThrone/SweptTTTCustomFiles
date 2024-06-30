--[[
	Client file for the PAS (Point Accumulation System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file simply shows the player's total points on the scoreboard.
    I tried adding a rank title for specific points amounts, but it never looked good enough.
    It's commented out, the only thing this file does out-of-the-box is show players' total points.
    Feel free to fux with it if you want to try to add additional functionality.

	The Point Accumulation System takes the points you've earned at the end of each TTT round
	and stores them.
	These points are based on how cleanly you played the round and are calculated entirely by TTT.
]]--

--[[
local rankStuff = {
    { pts = 50, col = Color( 184, 114, 199 ), name = "Player" },
    { pts = 100, col = Color( 199, 155, 92 ), name = "Regular" },
    { pts = 250, col = Color( 192, 192, 192 ), name = "Member" },
    { pts = 500, col = Color( 219, 170, 16 ), name = "Gold Member" },
    { pts = 1000, col = Color( 177, 1, 215 ), name = "VIP" },
    { pts = 2000, col = Color( 0, 128, 255 ), name = "Super VIP" },
    { pts = 5000, col = Color( 0, 255, 0 ), name = "Addict" }
}
]]--

hook.Add( "TTTScoreboardColumns", "AddPointsColumn", function( pnl )
    pnl:AddColumn( "Points", function( ply ) return ply:GetSPoints() end )

    --[[ doesn't fit larger names
    pnl:AddColumn( "Rank", function( ply, label )
        for k,v in pairs( rankStuff ) do
            if tonumber( ply:GetSPoints() ) < rankStuff[ k + 1 ].pts then
                label:SetTextColor( v.col )
                return v.name
            end
        end
        return "Guest"
    end )
    ]]
end )