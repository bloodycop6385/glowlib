GlowLib:DevLog( GlowLib.LogTypes.SUCCESS, "Defining Half-Life 2 model definitions" )

GlowLib:Define("models/combine_soldier.mdl", {
    Position = function(definition, entity)
        local attachment = entity:LookupAttachment("eyes")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            return attachmentData.Pos
        end

        return entity:LocalToWorld(Vector(0, 0, 65))
    end,
    Size = 42,
    Color = {
        [0] = Color(0, 64, 124, 30),
        [1] = Color(102, 59, 10, 30)
    }
})

GlowLib:Define("models/combine_soldier_prisonguard.mdl", {
    Position = function(definition, entity)
        local attachment = entity:LookupAttachment("eyes")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            return attachmentData.Pos
        end

        return entity:LocalToWorld(Vector(0, 0, 65))
    end,
    Size = 42,
    Color = {
        [0] = Color(109, 80, 0, 30),
        [1] = Color(104, 0, 0, 30)
    }
})

GlowLib:Define("models/combine_super_soldier.mdl", {
    Position = function(definition, entity)
        local attachment = entity:LookupAttachment("eyes")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            return attachmentData.Pos
        end

        return entity:LocalToWorld(Vector(0, 0, 65))
    end,
    Size = 42,
    Color = {
        [0] = Color(158, 51, 51, 30),
    }
})

GlowLib:Define("models/hunter.mdl", {
    Position = function(definition, entity)
        local attachment = entity:LookupAttachment("top_eye")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            return attachmentData.Pos - attachmentData.Ang:Forward() * 5.5
        end

        return entity:LocalToWorld(Vector(0, 0, 65))
    end,
    OnDraw = function(definition, entity, origin, xSize, ySize, colour)
        local attachment = entity:LookupAttachment("bottom_eye")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            origin = attachmentData.Pos - attachmentData.Ang:Forward() * 5.5
        end

        GlowLib:RenderSprite(origin, xSize, ySize, colour)
    end,
    Size = 40,
    Color = {
        [0] = Color(0, 255, 255, 119),
    }
})

GlowLib:Define("models/combine_scanner.mdl", {
    Position = function(definition, entity)
        local attachment = entity:LookupAttachment("eyes")
        if ( attachment > 0 ) then
            local attachmentData = entity:GetAttachment(attachment)
            return attachmentData.Pos
        end

        return entity:LocalToWorld(Vector(0, 0, 65))
    end,
    Size = 40,
    Color = {
        [0] = Color(131, 52, 0, 30),
    }
})