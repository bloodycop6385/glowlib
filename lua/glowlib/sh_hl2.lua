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
        [0] = Color(32, 147, 255, 20),
        [1] = Color(83, 38, 0, 100)
    }
})