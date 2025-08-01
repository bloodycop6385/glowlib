GlowLib:DevLog( GlowLib.LogTypes.SUCCESS, "Initialising", GlowLib.Colours.CLIENT, " clientside", color_white, " hooks..." )
GlowLib.SpriteMaterial = Material("glowlib/glowlib_light_glow02")
local client = NULL
hook.Add("OnEntityCreated", "GlowLib::OnEntityCreated", function(entity)
    if !IsValid(entity) || entity:IsWorld() then return end

    if entity == LocalPlayer() && !IsValid(client) then
        client = entity
    end

    local model = isfunction(entity.GetModel) && entity:GetModel()
    if isstring(model) && util.IsValidModel(model) then
        model = string.lower(model)

        local definition = GlowLib.Definitions[model]
        if istable(definition) then
            hook.Run("GlowLib::OnEntityCreated", entity, definition)
        end
    end
end)

hook.Add("GlowLib::ShouldDraw", "GlowLib::ShouldDraw", function(entity, definition)
    if !IsValid(entity) || entity:IsWorld() then return false end

    if isfunction(definition.ShouldDraw) then
        return definition:ShouldDraw(entity)
    end

    return true
end)

local function GetSpriteColour(definition, entity)
    if isfunction(definition.GetColor) then
        return definition:GetColor(entity)
    elseif IsColor(definition.Color) then
        return definition.Color
    elseif istable(definition.Color) then
        local skin = entity:GetSkin()
        local skinColour = definition.Color[skin]

        if IsColor(skinColour) then
            return skinColour
        end
    end
end

local function GetSpriteOrigin(definition, entity)
    if isfunction(definition.Position) then
        return definition:Position(entity)
    elseif isvector(definition.Position) then
        return entity:LocalToWorld(definition.Position)
    end

    return entity:EyePos()
end

local function GetSpriteSize(definition, entity)
    if isfunction(definition.Size) then
        return definition:Size(entity)
    elseif isnumber(definition.Size) then
        return definition.Size, definition.Size
    elseif istable(definition.Size) then
        return definition.Size[1] || 16, definition.Size[2] || 16
    end

    return 16, 16
end

hook.Add("PostDrawOpaqueRenderables", "GlowLib::PostDrawOpaqueRenderables", function()
    if !GlowLib:IsActivated() then return end

    for k, v in ents.Iterator() do
        if v:IsWorld() then continue end

        local model = isfunction(v.GetModel) && v:GetModel()
        if !isstring(model) || !util.IsValidModel(model) then continue end

        model = string.lower(model)

        local definition = GlowLib.Definitions[model]
        if !istable(definition) then continue end

        if v:IsPlayer() && v == client then continue end

        local try = hook.Run("GlowLib::ShouldDraw", v, definition)
        if ( try == false ) then continue end

        local colour = GetSpriteColour(definition, v)
        if !IsColor(colour) then continue end

        local origin = GetSpriteOrigin(definition, v)
        if !isvector(origin) then continue end

        local xSize, ySize = GetSpriteSize(definition, v)
        if !isnumber(xSize) || !isnumber(ySize) then continue end

        GlowLib:RenderSprite(origin, xSize || 16, ySize || 16, colour)

        if isfunction(definition.OnDraw) then
            definition:OnDraw(v, origin, xSize, ySize, colour)
        end
    end
end)