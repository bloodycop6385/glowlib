GlowLib:DevLog( GlowLib.LogTypes.SUCCESS, "Initialising", GlowLib.Colours.CLIENT, " clientside", color_white, " hooks..." )
GlowLib.SpriteMaterial = Material("glowlib/glowlib_light_glow02")

hook.Add("OnEntityCreated", "GlowLib::OnEntityCreated", function(entity)
    if !IsValid(entity) || entity:IsWorld() then return end

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

hook.Add("PostDrawTranslucentRenderables", "GlowLib::PostDrawTranslucentRenderables", function()
    if !GlowLib:IsActivated() then return end

    local client = LocalPlayer()

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

        local angInner = 45
        local angOuter = angInner + 35

        local eyePos = client:EyePos()
        local toSprite = (origin - eyePos):GetNormalized()

        local eyeAttachmentIndex = v:LookupAttachment("eyes")
        if ( eyeAttachmentIndex <= 0 ) then continue end

        local dot = toSprite:Dot(v:GetAttachment(eyeAttachmentIndex).Ang:Forward())
        local angle = math.deg(math.acos(math.Clamp(dot, -1, 1)))

        if angle > angOuter then return end

        -- Fade out alpha as angle approaches outerAngle, fully faded in at innerAngle
        local fadeFrac
        if angle <= angInner then
            fadeFrac = 1
        else
            fadeFrac = 1 - ((angle - angInner) / (angOuter - angInner))
            fadeFrac = math.Clamp(fadeFrac, 0, 1)
        end

        local fadedCol = Color(colour.r, colour.g, colour.b, math.floor(colour.a * fadeFrac))

        cam.Start3D()
            GlowLib:RenderSprite(origin, xSize || 16, ySize || 16, fadedCol)
        cam.End3D()

        if isfunction(definition.OnDraw) then
            definition:OnDraw(v, origin, xSize, ySize, colour)
        end
    end
end)