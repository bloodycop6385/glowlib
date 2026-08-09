local GlowLib = GlowLib

if ( SERVER ) then
    hook.Add("DoPlayerDeath", "GlowLib:DoPlayerDeath", function(ply)
        if ( !IsValid(ply) ) then return end

        local model = ply:GetModel()
        if ( !model ) then return end
        model = string.lower(model)

        local glowData = GlowLib.Glow_Data[model]
        if ( !glowData ) then return end

        GlowLib:Remove(ply)
    end)

    hook.Add("CreateEntityRagdoll", "GlowLib:EntityRagdollCreated", function(ent, ragdoll)
        if ( !IsValid(ent) or !IsValid(ragdoll) ) then return end

        timer.Simple(0, function()
            if ( !IsValid(ragdoll) ) then return end

            ragdoll:SetNW2Bool("GlowLib:IsNPCRagdoll", true)

            local sv_ragdoll = GlowLib.CVARS.SV_REMOVE_ON_DEATH:GetBool()
            if ( sv_ragdoll ) then
                ragdoll:SetNW2Bool("GlowLib:ShouldDraw", false)
                GlowLib:Hide(ragdoll)

                return
            end
        end)
    end)

    hook.Add("OnNPCKilled", "GlowLib:OnNPCKilled", function(npc, attacker, inflictor)
        if ( !IsValid(npc) ) then return end

        local model = npc:GetModel()
        if ( !model ) then return end
        model = string.lower(model)

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
        if ( glowingEyes[1] == nil ) then return false end

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
    hook.Add("CreateClientsideRagdoll", "GlowLib:CreateClientsideRagdoll", function(ragdoll)
        if ( !IsValid(ragdoll) ) then return end

        timer.Simple(0, function()
            if ( !IsValid(ragdoll) ) then return end

            ragdoll:SetNW2Bool("GlowLib:IsNPCRagdoll", true)

            local cl_ragdoll = GlowLib.CVARS.CL_REMOVE_ON_DEATH:GetBool()
            if ( cl_ragdoll ) then
                ragdoll:SetNW2Bool("GlowLib:ShouldDraw", false)
                GlowLib:Hide(ragdoll)
            end
        end)
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
        if ( glowingEyes[1] == nil ) then return false end

        return true
    end)
end

hook.Add("GlowLib_ShouldDraw", "GlowLib_ShouldDraw", function(ent)
    if ( !IsValid(ent) ) then return false end

    local model = ent:GetModel()
    if ( !isstring(model) or model == "" ) then return false end
    model = string.lower(model)

    local glowData = GlowLib.Glow_Data[model]
    if ( !glowData ) then return false end

    return true
end)
