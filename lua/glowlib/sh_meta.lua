local ENTITY = FindMetaTable("Entity")
local GlowLib = GlowLib
function ENTITY:GetGlowingEyes()
    local eyes = {}

    local children = self:GetChildren()
    for i = 1, #children do
        local v = children[i]
        if ( !IsValid(v) ) then continue end

        if ( v:GetNW2String("GlowEyeName", "") == "GlowLib_Eye_" .. self:EntIndex() ) then
            eyes[#eyes + 1] = v
        end
    end

    return eyes
end
