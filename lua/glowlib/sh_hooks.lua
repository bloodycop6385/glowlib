local GlowLib = GlowLib

local function updateGlow(ent)
    if ( !SERVER ) then return end
    if ( !IsValid(ent) ) then return end

    local model = ent:GetModel()
    if ( !model ) then return end
    model = model:lower()

    local ent_table = ent:GetTable()
    if ( !ent_table ) then return end

    local lastStored = ent_table.GlowLib_LastStoredModel or model
    if ( lastStored != model ) then
        GlowLib:Remove(ent)
    end

    ent_table.GlowLib_LastStoredModel = model

    local glowEyes = ent:GetGlowingEyes()
    if ( #glowEyes == 0 ) then
        GlowLib:Initialize(ent)

        return
    end

    GlowLib:Update(ent)
end

if ( SERVER ) then
    local nextThinkSV = 0
    hook.Add("Think", "GlowLib:Think_SV", function()
        if ( nextThinkSV > CurTime() ) then return end

        local sv_enabled = GetConVar("sv_glowlib_enabled"):GetBool()
        if ( !sv_enabled ) then return end

        for k, v in ents.Iterator() do
            if ( !IsValid(v) ) then continue end

            local model = v:GetModel()
            if ( !model ) then continue end
            model = model:lower()

            local glowData = GlowLib.Glow_Data[model]
            if ( !glowData ) then
                GlowLib:Remove(v)
                continue
            end

            if ( !GlowLib:ShouldDraw(v) ) then
                GlowLib:Hide(v)

                continue
            end

            updateGlow(v)
            GlowLib:Show(v)
        end

        nextThinkSV = CurTime() + 1
    end)

    hook.Add("DoPlayerDeath", "GlowLib:DoPlayerDeath", function(ply)
        if ( !IsValid(ply) ) then return end

        local model = ply:GetModel()
        if ( !model ) then return end
        model = model:lower()

        local glowData = GlowLib.Glow_Data[model]
        if ( !glowData ) then return end

        GlowLib:Remove(ply)
    end)

    hook.Add("CreateEntityRagdoll", "GlowLib:EntityRagdollCreated", function(ent, ragdoll)
        if ( !IsValid(ent) or !IsValid(ragdoll) ) then return end

        timer.Simple(0, function()
            if ( !IsValid(ragdoll) ) then return end

            local sv_ragdoll = GetConVar("sv_glowlib_remove_on_death"):GetBool()
            if ( sv_ragdoll ) then
                ragdoll:SetNW2Bool("GlowLib:ShouldDraw", false)
                ragdoll:SetNW2Bool("GlowLib:IsNPCRagdoll", true)
                GlowLib:Hide(ragdoll)

                return
            end

            net.Start("GlowLib:HandleClientsideRagdoll")
                net.WriteEntity(ragdoll)
            net.Broadcast()
        end)
    end)

    hook.Add("OnNPCKilled", "GlowLib:OnNPCKilled", function(npc, attacker, inflictor)
        if ( !IsValid(npc) ) then return end

        local model = npc:GetModel()
        if ( !model ) then return end
        model = model:lower()

        local glowData = GlowLib.Glow_Data[model]
        if ( !glowData ) then return end

        GlowLib:Remove(npc)
    end)

    hook.Add("GlowLib_CanPerformEdit", "GlowLib:CanPerformEdit", function(ply, ent, sprite, data)
        if ( !IsValid(ply) ) then return false end
        if ( !IsValid(ent) ) then return false end
        if ( !IsValid(sprite) ) then return false end

        if ( !ply:IsAdmin() ) then return false end

        if ( !ent.GetGlowingEyes or !isfunction(ent.GetGlowingEyes) ) then return false end

        local glowingEyes = ent:GetGlowingEyes()
        if ( !glowingEyes ) then return false end
        if ( #glowingEyes == 0 ) then return false end

        return true
    end)

    hook.Add("GlowLib_CanPlayerSaveCreation", "GlowLib:CanPlayerSaveCreation", function(ply, model, data)
        if ( !IsValid(ply) ) then return false end
        if ( !ply:IsAdmin() ) then return false end

        if ( !model or model == "" ) then return false end
        if ( !data ) then return false end

        return true
    end)
else
    local nextThinkCL = 0
    hook.Add("Think", "GlowLib:Think_CL", function()
        if ( nextThinkCL > CurTime() ) then return end

        local ply = LocalPlayer()
        if ( !IsValid(ply) ) then return end

        local cl_glowlib_enabled = GetConVar("cl_glowlib_enabled"):GetBool()
        if ( !cl_glowlib_enabled ) then return end

        for k, v in ents.Iterator() do
            if ( v:IsDormant() ) then continue end

            local model = v:GetModel()
            if ( !model or model == "" ) then continue end
            model = model:lower()

            local glowData = GlowLib.Glow_Data[model]
            if ( !glowData ) then continue end

            v:SetNW2Bool("GlowLib:ShouldDraw", glib_enabled)

            if ( !GlowLib:ShouldDraw(v) ) then
                GlowLib:Hide(v)

                continue
            end

            GlowLib:Show(v)
        end

        nextThinkCL = CurTime() + 1
    end)

    hook.Add("GlowLib_CanUseCreationMenu", "GlowLib:CanUseCreationMenu", function(ply, creationMenu)
        if ( !IsValid(ply) ) then return false end
        if ( !ply:IsAdmin() ) then return false end

        return true
    end)

    hook.Add("GlowLib_CanUseEditMenu", "GlowLib:CanUseEditMenu", function(ply, ent, editMenu)
        if ( !IsValid(ply) ) then return false end
        if ( !IsValid(ent) ) then return false end
        if ( !ply:IsAdmin() ) then return false end

        if ( !ent.GetGlowingEyes or !isfunction(ent.GetGlowingEyes) ) then return false end

        local glowingEyes = ent:GetGlowingEyes()
        if ( !glowingEyes ) then return false end
        if ( #glowingEyes == 0 ) then return false end

        return true
    end)
end

hook.Add("GlowLib_ShouldDraw", "GlowLib_ShouldDraw", function(ent)
    if ( !IsValid(ent) ) then return false end

    local model = ent:GetModel()
    if ( !model or model == "" ) then return false end
    model = model:lower()

    local glowData = GlowLib.Glow_Data[model]
    if ( !glowData ) then return false end

    return true
end)