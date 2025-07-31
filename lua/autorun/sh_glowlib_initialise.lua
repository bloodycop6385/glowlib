if SERVER then
    MsgC( "GlowLib :: Initialising...\n" )
end

GlowLib = GlowLib || {}
GlowLib.__index = GlowLib

GlowLib.LogTypes = {
    SUCCESS = 1,
    ERROR = 2,
    WARNING = 3,
}

GlowLib.Colours = {
    SUCCESS = Color( 80, 255, 140 ),
    ERROR = Color( 255, 120, 85 ),
    WARNING = Color( 255, 200, 0 ),
    ["SERVER"] = Color( 70, 255, 230),
    ["CLIENT"] = Color( 225, 165, 80),
}

GlowLib.Definitions = GlowLib.Definitions || {}

function GlowLib:Log( logType, ... )
    local colour_prefix =   logType == self.LogTypes.SUCCESS && self.Colours.SUCCESS
                            || logType == self.LogTypes.WARNING && self.Colours.WARNING
                            || self.Colours.ERROR

    local logPackage = {...}
    logPackage[ #logPackage + 1 ] = "\n"

    MsgC(SERVER && self.Colours.SERVER || self.Colours.CLIENT, "GlowLib :: ", colour_prefix, unpack(logPackage) )

end

local CVAR_DEV = GetConVar( "developer" )
function GlowLib:DevLog(logType, ...)
    if !CVAR_DEV:GetBool() then return end

    local colour_prefix =   logType == self.LogTypes.SUCCESS && self.Colours.SUCCESS
                            || logType == self.LogTypes.WARNING && self.Colours.WARNING
                            || self.Colours.ERROR

    local logPackage = {...}
    logPackage[ #logPackage + 1 ] = "\n"

    MsgC( SERVER && self.Colours.SERVER || self.Colours.CLIENT, "GlowLib :: ", colour_prefix, unpack(logPackage) )
end

local COLOUR_USER = Color( 255, 73, 24 )
local COLOUR_ERROR = Color( 255, 120, 85 )

local function IncFile( filePath, realm )
    local fileName = string.GetFileFromFilename( filePath )
    local prefix = string.sub( fileName, 1, 3 )

    if SERVER && prefix == "sv_" then
        include( filePath )
    elseif prefix == "sh_" then
        if SERVER then
            AddCSLuaFile( filePath )
        end

        include( filePath )
    elseif prefix == "cl_" then
        if SERVER then
            AddCSLuaFile( filePath )
        elseif CLIENT then
            include( filePath )
        end
    end
end

local function IncDirectory( directory )
    local files, directories = file.Find( directory .. "/*", "LUA" )

    if ( files[1] != nil ) then
        for i = 1, #files do
            IncFile( directory .. "/" .. files[ i ] )
        end
    end

    if ( directories[1] != nil ) then
        for i = 1, #directories do
            IncDirectory( directory .. "/" .. directories[ i ] )
        end
    end
end

local function Initialise()
    IncDirectory("glowlib")
end

xpcall( Initialise, function( catch )
    GlowLib:Log(GlowLib.LogTypes.ERROR, "Failed to initialise! Please check the console for more information and report it to the developer." )
end)

local RELOADED = false
hook.Add( "OnReloaded", "GlowLib::Reload", function()
    if RELOADED then return end
    RELOADED = true

    xpcall( Initialise, function( catch )
        GlowLib:Log(GlowLib.LogTypes.ERROR, "Failed to reload! Please check the console for more information and report it to the developer." )
        return
    end )

    GlowLib:DevLog( GlowLib.LogTypes.SUCCESS, "GlowLib reloaded successfully!" )
end )

GlowLib:Log(GlowLib.LogTypes.SUCCESS, "Initialised! Thank you for the support!", COLOUR_USER, " -bloodycop6385 :)" )