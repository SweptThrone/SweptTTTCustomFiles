--[[
	Server file for the PAS (Point Accumulation System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file actually gives people their points, stores them, and creates the database table.
    This file requires sh_point_funcs.lua, so don't separate them!

	The Point Accumulation System takes the points you've earned at the end of each TTT round
	and stores them.
	These points are based on how cleanly you played the round and are calculated entirely by TTT.
]]--

util.AddNetworkString( "ST_PointDiff" )

local plyMeta = FindMetaTable( "Player" )

-- AddFrags is used to give players points at the end of rounds,
-- probably so points can be queried by services
-- such as GameTracker.  we hijack it to store those points.
plyMeta.OldAddFrags = plyMeta.AddFrags
function plyMeta:AddFrags( count )
    self:AddSPoints( count )
    self:OldAddFrags( count )
end

hook.Add( "Initialize", "SetupCleanPointTable", function()
	-- create the table in which our points are stored
    if !sql.TableExists( "swept_points" ) then
        sql.Query( "CREATE TABLE swept_points( SteamID TEXT, Points INT )" )
        MsgC( Color( 0, 255, 0 ), "Initialized empty Swept Points table\n" )
    end

end )

hook.Add( "PlayerInitialSpawn", "AssignPointsValue", function( ply )
    -- create a field for a player when they join or load their points if found
    ply.retTable = sql.Query( "SELECT SteamID, Points FROM swept_points WHERE SteamID = '" .. ply:SteamID64() .. "'" )
    if ply.retTable == nil then
        sql.Query( "INSERT INTO swept_points( SteamID, Points ) VALUES( '" .. ply:SteamID64() .. "', 0 )" )
        MsgC( Color( 0, 255, 0 ), "Set up " .. ply:Name() .. "'s 0 points.\n" )
    end
    ply.currPoints = sql.Query( "SELECT SteamID, Points FROM swept_points WHERE SteamID = '" .. ply:SteamID64() .. "'" )[1][ "Points" ]
    ply:SetNWInt( "SPoints", ply.currPoints )
    MsgC( Color( 0, 255, 0 ), "Gave " .. ply:Name() .. "'s " .. ply.currPoints .. " points.\n" )
end )