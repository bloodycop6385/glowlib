GlowLib:DevLog(GlowLib.LogTypes.SUCCESS, "Loaded core file")

function GlowLib:Define(model, data)
    if !isstring(model) || !util.IsValidModel(model) then
        self:DevLog( self.LogTypes.ERROR, "Invalid model definition: ", model )
        return
    end

    model = string.lower(model)

    if !istable(data) then
        self:DevLog( self.LogTypes.ERROR, "Invalid data for model definition: ", model )
        return
    end

    self.Definitions[model] = data
end

local CVAR_ENABLED = CreateConVar("glowlib_sv_enabled", "1", {FCVAR_ARCHIVE}, "Enable GlowLib server-side functionality", 0, 1)
local CVAR_CLIENT_ENABLED = CreateClientConVar("glowlib_cl_enabled", "1", true, true, "Enable GlowLib client-side functionality", 0, 1)

function GlowLib:IsActivated()
    if SERVER and !CVAR_ENABLED:GetBool() then
        return false
    elseif CLIENT and !CVAR_CLIENT_ENABLED:GetBool() then
        return false
    end

    local try = hook.Run("GlowLib::ShouldBeActivated")
    return try
end