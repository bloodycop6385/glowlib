local GlowLib = GlowLib

if ( SERVER ) then
    local function updateGlow(ent)
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
        if ( glowEyes[1] == nil ) then
            GlowLib:Initialize(ent)

            return
        end

        GlowLib:Update(ent)
    end

    local nextThinkSV = 0
    hook.Add("Think", "GlowLib:Think_SV", function()
        if ( nextThinkSV > CurTime() ) then return end

        local sv_enabled = GetConVar("sv_glowlib_enabled"):GetBool()
        if ( !sv_enabled ) then return end

        for i = 1, #GlowLib.Glow_Data_Keys do
            local model = GlowLib.Glow_Data_Keys[i]
            model = string.lower(model)

            local entities = ents.FindByModel(model)
            if ( !entities or entities[1] == nil ) then continue end

            for j = 1, #entities do
                local ent = entities[j]
                if ( !IsValid(ent) ) then continue end

                if ( !GlowLib:ShouldDraw(ent) ) then
                    GlowLib:Hide(ent)
                    continue
                end

                updateGlow(ent)
                GlowLib:Show(ent)
            end
        end

        nextThinkSV = CurTime() + GlowLib.Config.DELAY_THINK_SERVER
    end)

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

    local function handleViewEntityChange()
        local cl_glowlib_enabled = GlowLib.CVARS.CL_ENABLED:GetBool()
        if ( !cl_glowlib_enabled ) then return end

        for i = 1, #GlowLib.Glow_Data_Keys do
            local model = GlowLib.Glow_Data_Keys[i]
            model = string.lower(model)

            local entities = ents.FindByModel(model)
            if ( !entities or entities[1] == nil ) then continue end

            for j = 1, #entities do
                local ent = entities[j]
                if ( !IsValid(ent) ) then continue end
                if ( ent:IsDormant() ) then continue end

                ent:SetNW2Bool("GlowLib:ShouldDraw", cl_glowlib_enabled)
                if ( !GlowLib:ShouldDraw(ent) ) then
                    GlowLib:Hide(ent)
                    continue
                end

                GlowLib:Show(ent)
            end
        end
    end

    local nextThinkCL, nextViewEntityThinkCL = 0, 0
    hook.Add("Think", "GlowLib:Think_CL", function()
        local client = LocalPlayer()
        if ( !client or !client:IsValid() ) then return end

        if ( nextViewEntityThinkCL < CurTime() ) then
            local clientTable = client:GetTable()
            local viewEntity = GetViewEntity()

            if ( clientTable.GlowLib_LastViewEntity != viewEntity ) then
                clientTable.GlowLib_LastViewEntity = viewEntity
                handleViewEntityChange()
            end

            nextViewEntityThinkCL = CurTime() + 0.1
        end

        if ( nextThinkCL > CurTime() ) then return end

        local cl_glowlib_enabled = GlowLib.CVARS.CL_ENABLED:GetBool()
        if ( !cl_glowlib_enabled ) then return end

        for i = 1, #GlowLib.Glow_Data_Keys do
            local model = GlowLib.Glow_Data_Keys[i]
            model = string.lower(model)

            local entities = ents.FindByModel(model)
            if ( !entities or entities[1] == nil ) then continue end

            for j = 1, #entities do
                local ent = entities[j]
                if ( !IsValid(ent) ) then continue end
                if ( ent:IsDormant() ) then continue end

                ent:SetNW2Bool("GlowLib:ShouldDraw", cl_glowlib_enabled)
                if ( !GlowLib:ShouldDraw(ent) ) then
                    GlowLib:Hide(ent)
                    continue
                end

                GlowLib:Show(ent)
            end
        end

        nextThinkCL = CurTime() + GlowLib.Config.DELAY_THINK_CLIENT
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
