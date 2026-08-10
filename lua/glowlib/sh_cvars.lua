local GlowLib = GlowLib

GlowLib.CVARS = {}

if ( CLIENT ) then
    GlowLib.CVARS.CL_ENABLED            = CreateClientConVar("cl_glowlib_enabled", "1", true, true, "Enable or disable GlowLib", 0, 1)
    GlowLib.CVARS.CL_REMOVE_ON_DEATH    = CreateClientConVar("cl_glowlib_remove_on_death", "1", true, true, "Remove glowing eyes on death (NPCs)", 0, 1)
    GlowLib.CVARS.CL_RAGDOLLS           = CreateClientConVar("cl_glowlib_ragdolls", "1", true, true, "Enable or disable ragdoll glowing", 0, 1)
else
    GlowLib.CVARS.SV_ENABLED            = CreateConVar("sv_glowlib_enabled", "1", {FCVAR_ARCHIVE, FCVAR_GAMEDLL}, "Enable or disable GlowLib", 0, 1)
    GlowLib.CVARS.SV_REMOVE_ON_DEATH    = CreateConVar("sv_glowlib_remove_on_death", "1", {FCVAR_ARCHIVE, FCVAR_GAMEDLL}, "Enable or disable removing Glowing Eyes On Death (NPCs)", 0, 1)
    GlowLib.CVARS.SV_RAGDOLLS           = CreateConVar("sv_glowlib_ragdolls", "1", {FCVAR_ARCHIVE, FCVAR_GAMEDLL}, "Enable or disable ragdoll glowing", 0, 1)
end

GlowLib.Config = {
    DELAY_THINK_SERVER = 0.3,
    DELAY_THINK_CLIENT = 0.3,
}

if ( SERVER and GlowLib.CVARS.SV_ENABLED:GetBool() ) then
    hook.Remove("Think", "GlowLib:ThinkSV")
    hook.Add("Think", "GlowLib:ThinkSV", function()
        GlowLib:Think()
    end)
end

if ( CLIENT and GlowLib.CVARS.CL_ENABLED:GetBool() ) then
    hook.Remove("Think", "GlowLib:ThinkCL")
    hook.Add("Think", "GlowLib:ThinkCL", function()
        GlowLib:Think()
    end)
end

cvars.AddChangeCallback("sv_glowlib_enabled", function(_, _, newValue)
    if ( !SERVER ) then return end

    if ( newValue == "0" ) then
        for k, v in ipairs(GlowLib:GetAllEntities()) do
            if ( !IsValid(v) ) then continue end

            v:SetNW2Bool("GlowLib:ShouldDraw", false)
        end

        hook.Remove("Think", "GlowLib:ThinkSV")

        GlowLib:HideAll()

        return
    end

    hook.Remove("Think", "GlowLib:ThinkSV")
    hook.Add("Think", "GlowLib:ThinkSV", function()
        GlowLib:Think()
    end)

    for k, v in ipairs(GlowLib:GetAllEntities()) do
        if ( !IsValid(v) ) then continue end

        v:SetNW2Bool("GlowLib:ShouldDraw", true)
    end

    GlowLib:ShowAll()
end)

cvars.AddChangeCallback("sv_glowlib_remove_on_death", function(_, _, newValue)
    if ( !SERVER ) then return end

    if ( newValue == "1" ) then
        for k, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
        if ( !IsValid(ragdoll) or GlowLib:ShouldDraw(ragdoll) ) then continue end

            ragdoll:SetNW2Bool("GlowLib:ShouldDraw", false)
            GlowLib:Remove(ragdoll)
        end

        return
    end

    for k, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
        if ( !IsValid(ragdoll) or GlowLib:ShouldDraw(ragdoll) ) then continue end

        ragdoll:SetNW2Bool("GlowLib:ShouldDraw", true)
    end
end)

cvars.AddChangeCallback("cl_glowlib_enabled", function(_, _, newValue)
    if ( newValue == "0" ) then
        for k, v in ipairs(GlowLib:GetAllEntities()) do
            if ( !IsValid(v) ) then continue end

            v:SetNW2Bool("GlowLib:ShouldDraw", false)
        end

        hook.Remove("Think", "GlowLib:ThinkCL")

        GlowLib:HideAll()

        return
    end

    hook.Remove("Think", "GlowLib:ThinkCL")
    hook.Add("Think", "GlowLib:ThinkCL", function()
        GlowLib:Think()
    end)

    for k, v in ipairs(GlowLib:GetAllEntities()) do
        if ( !IsValid(v) ) then continue end

        v:SetNW2Bool("GlowLib:ShouldDraw", true)
    end

    GlowLib:ShowAll()
end)

cvars.AddChangeCallback("cl_glowlib_remove_on_death", function(_, _, newValue)
    if ( newValue == "1" ) then
        for k, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
            if ( !IsValid(ragdoll) or GlowLib:ShouldDraw(ragdoll) ) then continue end

            ragdoll:SetNW2Bool("GlowLib:ShouldDraw", false)
            GlowLib:Hide(ragdoll)
        end

        return
    end

    for k, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
        if ( !IsValid(ragdoll) or GlowLib:ShouldDraw(ragdoll) ) then continue end

        ragdoll:SetNW2Bool("GlowLib:ShouldDraw", true)
        GlowLib:Show(ragdoll)
    end
end)
