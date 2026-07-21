local GlowLib = GlowLib

function GlowLib:GetAllEntities()
    local returned = {}

    for i = 1, #self.Glow_Data_Keys do
        local model = self.Glow_Data_Keys[i]
        local entities = ents.FindByModel(model)
        if ( entities[1] == nil ) then continue end

        for i = 1, #entities do
            local v = entities[i]
            if ( !v:GetNW2Bool("bHasGlowLibEffect", false) ) then continue end

            returned[#returned + 1] = v
        end
    end

    return returned
end

function GlowLib:GetAllSprites()
    local returned = {}

    local sprites = ents.FindByClass("env_sprite")
    if ( sprites[1] == nil ) then return returned end

    for i = 1, #sprites do
        local v = sprites[i]
        if ( !v:GetNW2Bool("bIsGlowLib", false) ) then continue end

        returned[#returned + 1] = v
    end

    return returned
end

if ( SERVER ) then
    function GlowLib:CreateSprite(ent, spriteData)
        if ( !IsValid(ent) or !spriteData ) then return end

        local ent_model = ent:GetModel()
        if ( !ent_model ) then return end
        ent_model = ent_model:lower()

        local glowData = self.Glow_Data[ent_model]
        if ( !glowData ) then return end

        local glow_color = spriteData.Color or glowData.Color[ent:GetSkin()] or glowData.Color[0] or color_white
        local attach = spriteData.Attachment and ent:LookupAttachment(spriteData.Attachment) or 0
        local glow_mat = spriteData.GlowTexture or glowData.GlowTexture or "sprites/light_glow02.vmt"
        local glow_size = spriteData.Size or glowData.Size or 0.3
        local glow_renderMode = spriteData.RenderMode or glowData.RenderMode or 9

        local glowColCustom = glowData.CustomColor and isfunction(glowData.CustomColor) and glowData:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            glow_color = glowData:CustomColor(ent, glowCol)
        end

        local customSize = glowData.CustomSize and isfunction(glowData.CustomSize) and glowData:CustomSize(ent, glow_size)
        if ( customSize != nil ) then
            glow_size = glowData:CustomSize(ent, glow_size)
        end

        local vec_sprite = spriteData.Position or isfunction(glowData.Position) and glowData:Position(ent, spriteData)
        if ( !vec_sprite ) then
            vec_sprite = ent:EyePos() + ent:GetAngles():Forward() * 7
        end

        local sprite = ents.Create("env_sprite")
        if ( IsValid(sprite) ) then
            sprite:SetPos(vec_sprite)
            sprite:SetParent(ent, attach or 0)

            sprite:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            sprite:SetNW2String("GlowLib_Eye_Count", #ent:GetGlowingEyes() + 1)

            sprite:SetKeyValue("model", tostring(glow_mat))
            sprite:SetColor(glow_color)

            sprite:SetKeyValue("rendermode", tostring(glow_renderMode))
            sprite:SetKeyValue("scale", tostring(glow_size))

            sprite:SetNW2Bool("bIsGlowLib", true)
            sprite:Spawn()

            ent:SetNW2Bool("bHasGlowLibEffect", true)
            ent:DeleteOnRemove(sprite)
            ent:CallOnRemove("GlowLib:Remove", function(ent)
                GlowLib:Remove(ent)
            end)

            local sprite_table = sprite:GetTable()
            sprite_table.GlowLib_bNoUpdate = spriteData.NoUpdate or false

            return sprite
        end
        
        return
    end

    function GlowLib:Remove(ent)
        if ( !IsValid(ent) ) then return end
        
        local model = ent:GetModel()
        if ( !model ) then return end

        local glow_eyes = ent:GetGlowingEyes()
        for k, v in ipairs(glow_eyes) do
            if ( IsValid(v) ) then
                v:Remove()
            end
        end

        hook.Run("GlowLib_Remove", ent)
    end

    function GlowLib:RemoveAll()
        for model, _ in pairs(self.Glow_Data) do
            local entities = ents.FindByModel(model)
            if ( entities[1] == nil ) then continue end

            for i = 1, #entities do
                self:Remove(entities[i])
            end
        end

        hook.Run("GlowLib_RemoveAll")
    end

    local color_fallback = Color(255, 255, 255, 170)
    function GlowLib:Initialize(ent)
        local sv_glowlib_enabled = GetConVar("sv_glowlib_enabled"):GetBool()
        if ( !sv_glowlib_enabled ) then return end

        if ( !IsValid(ent) ) then return end

        if ( ent:GetClass() == "prop_effect" ) then
            local child = ent:GetInternalVariable("m_hMoveChild")
            if ( IsValid(child) ) then
                ent = child
            end
        end

        local glow_eyes = ent:GetGlowingEyes()
        for k, v in ipairs(glow_eyes) do
            if ( IsValid(v) ) then
                v:Remove()
            end
        end

        local model = ent:GetModel()
        if ( !model ) then return end
        model = model:lower()

        if ( !util.IsValidModel(model) ) then return end

        local glowData = self.Glow_Data[model]
        if ( glowData ) then
            local entTable = ent:GetTable()

            if ( entTable.GlowLib_bDisabled ) then return end
            local glow_color = glowData.Color[ent:GetSkin()] or glowData.Color[0] or color_fallback

            local glow_mat = glowData.GlowTexture
            if ( !glow_mat ) then
                glowData.GlowTexture = "sprites/light_glow02.vmt"
                glow_mat = glowData.GlowTexture
            end

            local glow_size = glowData.Size
            if ( !glow_size ) then
                glowData.Size = 0.3
                glow_size = glowData.Size
            end

            local vec_sprite = glowData["Position"] and glowData:Position(ent, glowData)
            if ( !vec_sprite ) then
                vec_sprite = ent:EyePos() + ent:GetAngles():Forward() * 7
            end

            local glowColCustom = glowData.CustomColor and isfunction(glowData.CustomColor) and glowData:CustomColor(ent, glowCol)
            if ( glowColCustom != nil ) then
                glowCol = glowData:CustomColor(ent, glowCol)
            end

            local customSize = glowData.CustomSize and isfunction(glowData.CustomSize) and glowData:CustomSize(ent, glow_size)
            if ( customSize != nil ) then
                glow_size = glowData:CustomSize(ent, glow_size)
            end

            local bShouldDraw = glowData.ShouldDraw and isfunction(glowData.ShouldDraw) and glowData:ShouldDraw(ent)
            if ( bShouldDraw != nil and bShouldDraw == false ) then
                return
            end

            local attach = glowData.Attachment or "eyes"

            local sprite = self:CreateSprite(ent, {
                Color = glow_color,
                Attachment = attach,
                Position = vec_sprite,
                GlowTexture = glow_mat,
                Size = glow_size,
                RenderMode = glowData.RenderMode or 9
            })

            entTable.GlowLib_bDontUpdate = false

            if ( glowData["OnInitialize"] and isfunction(glowData["OnInitialize"]) ) then
                glowData:OnInitialize(ent, sprite)
            end

            hook.Run("GlowLib_Initalize", ent)
            net.Start("GlowLib:ClientsideInitalize")
                net.WriteEntity(ent)
                net.WriteEntity(sprite)
            net.Broadcast()
        end
    end

    function GlowLib:Update(ent)
        if ( !IsValid(ent) ) then return end

        local model = ent:GetModel()
        if ( !model ) then return end
        model = model:lower()

        local glowEyes = ent:GetGlowingEyes()
        if ( !glowEyes or #glowEyes == 0 ) then return end

        local glowData = GlowLib.Glow_Data[model]
        if ( !glowData ) then return end

        local entTable = ent:GetTable()
        if ( entTable.GlowLib_bDontUpdate ) then return end

        local col = glowData.Color[ent:GetSkin()] or glowData.Color[0] or color_fallback
        local glowColCustom = glowData.CustomColor and isfunction(glowData.CustomColor) and glowData:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            col = glowData:CustomColor(ent, glowCol)
        end

        local size = glowData.Size or 0.3

        for k, v in ipairs(glowEyes) do
            if ( !IsValid(v) ) then continue end

            local vTable = v:GetTable()
            if ( vTable.GlowLib_bNoUpdate ) then continue end

            v:SetKeyValue("model", glowData.GlowTexture or "sprites/light_glow02.vmt")
            v:SetKeyValue("scale", tostring(size))
            v:SetColor(col)
        end

        local postUpdate = glowData.PostUpdate and isfunction(glowData.PostUpdate) and glowData:PostUpdate(ent, glowEyes)
        if ( postUpdate != nil ) then
            glowData:PostUpdate(ent, glowEyes)
        end

        hook.Run("GlowLib_Update", ent)
    end
end

function GlowLib:Hide(ent)
    if ( !IsValid(ent) ) then return end

    local model = ent:GetModel()
    if ( !model ) then return end
    model = model:lower()

    local glowData = self.Glow_Data[model]
    if ( !glowData ) then return end

    hook.Run("GlowLib_PreHide", ent)

    local glow_eyes = ent:GetGlowingEyes()
    for k, v in ipairs(glow_eyes) do
        if ( IsValid(v) ) then
            v:SetNoDraw(true)

            if ( SERVER and v:GetClass() == "light_dynamic" ) then
                v:Fire("TurnOff")
            end
        end
    end

    if ( SERVER and ent:IsPlayer() ) then
        net.Start("GlowLib:HideServerside")
        net.Send(ent)
    end

    hook.Run("GlowLib_Hide", ent)
end

function GlowLib:HideAll()
    for k, v in ents.Iterator() do
        if not ( IsValid(v) ) then
            continue
        end

        local model = v:GetModel()
        if ( !model ) then continue end
        model = model:lower()

        local glowData = self.Glow_Data[model]
        if ( !glowData ) then continue end

        self:Hide(v)
    end
end

function GlowLib:Show(ent)
    if ( !IsValid(ent) ) then return end

    local model = ent:GetModel()
    if ( !model ) then return end
    model = model:lower()

    local glowData = self.Glow_Data[model]
    if ( !glowData ) then return end

    hook.Run("GlowLib_PreShow", ent)

    if ( !GlowLib:ShouldDraw(ent) ) then
        GlowLib:Hide(ent)

        return
    end

    local glow_eyes = ent:GetGlowingEyes()
    for k, v in ipairs(glow_eyes) do
        if ( IsValid(v) ) then
            v:SetNoDraw(false)

            if ( SERVER and v:GetClass() == "light_dynamic" ) then
                v:Fire("TurnOn")
            end
        end
    end

    if ( SERVER and ent:IsPlayer() ) then
        net.Start("GlowLib:HideServerside")
        net.Send(ent)
    end

    hook.Run("GlowLib_Show", ent)
end

function GlowLib:ShowAll()
    for k, v in ents.Iterator() do
        if not ( IsValid(v) ) then
            continue
        end

        local model = v:GetModel()
        if ( !model ) then continue end
        model = model:lower()

        local glowData = self.Glow_Data[model]
        if ( !glowData ) then continue end

        self:Show(v)
    end
end

function GlowLib:ShouldDraw(ent)
    if ( CLIENT ) then
        local glib_enabled = GetConVar("cl_glowlib_enabled"):GetBool()
        if ( !glib_enabled ) then return false end
    else
        local glib_enabled = GetConVar("sv_glowlib_enabled"):GetBool()
        if ( !glib_enabled ) then return false end
    end

    if ( !IsValid(ent) ) then return false end

    local model = ent:GetModel()
    if ( !model ) then return false end
    model = model:lower()

    local glowData = self.Glow_Data[model]
    if ( !glowData ) then
        if ( SERVER ) then
            GlowLib:Remove(v)
        end

        return false
    end

    local entTable = ent:GetTable()
    if ( entTable.GlowLib_bDisabled ) then return false end

    local bShouldDraw = glowData.ShouldDraw and isfunction(glowData.ShouldDraw) and glowData:ShouldDraw(ent)
    if ( bShouldDraw != nil and bShouldDraw == false ) then return false end

    local bShouldDrawHook = hook.Run("GlowLib_ShouldDraw", ent)
    if ( !bShouldDrawHook ) then return false end

    if ( ( ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() ) and ent:Health() <= 0 and !glowData.IgnoreHealth ) then return false end
    if ( ent:GetNoDraw() ) then return false end

    if ( CLIENT ) then
        local cl_ragdoll_remove = GetConVar("cl_glowlib_remove_on_death"):GetBool()
        if ( cl_ragdoll_remove and ent:IsRagdoll() and ent:GetNW2Bool("GlowLib:IsNPCRagdoll", false) ) then
            return false
        end

        if ( ent == LocalPlayer() ) then
            local shouldDrawLocalPlayer = ent:ShouldDrawLocalPlayer() or hook.Run("ShouldDrawLocalPlayer", ent) or false
            if ( !shouldDrawLocalPlayer ) then
                return false
            end
        end

        if ( ent:GetClass() == "class C_BaseFlex" ) then
            return false
        end
    else
        local sv_ragdoll_remove = GetConVar("sv_glowlib_remove_on_death"):GetBool()
        if ( sv_ragdoll_remove and ent:IsRagdoll() and ent:GetNW2Bool("GlowLib:IsNPCRagdoll", false) ) then
            return false
        end

        if ( ent:IsPlayer() ) then
            net.Start("GlowLib:HideServerside")
            net.Send(ent)

            if ( ent:GetNoDraw() ) then
                return false
            end
        end
    end

    return true
end
