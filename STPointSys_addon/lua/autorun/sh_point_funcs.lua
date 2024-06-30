--[[
	Shared file for the PAS (Point Accumulation System)
	by SweptThrone
	Website: sweptthr.one
	Handle: @sweptthrone on everything

	This file provides helper functions for the PAS.

	The Point Accumulation System takes the points you've earned at the end of each TTT round
	and stores them.
	These points are based on how cleanly you played the round and are calculated entirely by TTT.
]]--

local plyMeta = FindMetaTable( "Player" )

function plyMeta:SetSPoints( pts )

	if SERVER then
		sql.Query( "UPDATE swept_points SET SteamID = '" .. self:SteamID64() .. "', Points = " .. pts .. " WHERE SteamID = '" .. self:SteamID64() .. "'" )
		self:SetNWInt( "SPoints", pts )
	else
		ErrorNoHalt( "[SweptTTT] Attempt to use SetSPoints on client!" )
	end

end

function plyMeta:GetSPoints()

	if SERVER then
		return sql.Query( "SELECT SteamID, Points FROM swept_points WHERE SteamID = '" .. self:SteamID64() .. "'" )[1][ "Points" ]
	elseif CLIENT then
		return self:GetNWInt( "SPoints", 0 )
	else
		ErrorNoHalt( "somethin fucked up bad" )
	end

end

function plyMeta:AddSPoints( pts )

	if SERVER then
		local currPts = sql.Query( "SELECT SteamID, Points FROM swept_points WHERE SteamID = '" .. self:SteamID64() .. "'" )[1][ "Points" ]
		currPts = currPts + pts
		sql.Query( "UPDATE swept_points SET SteamID = '" .. self:SteamID64() .. "', Points = " .. currPts .. " WHERE SteamID = '" .. self:SteamID64() .. "'" )
		self:SetNWInt( "SPoints", currPts )
	else
		ErrorNoHalt( "AddPoints on client is bad" )
	end
		
end