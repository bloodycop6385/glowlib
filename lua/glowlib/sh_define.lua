local GlowLib = GlowLib

GlowLib:Define("models/police.mdl", {
    Position = function(self, ent)
        if ( !IsValid(ent) ) then return end

        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos + attachmentData.Ang:Forward() * 1.55
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(0, 0, 0, 0),
    },
    ShouldDraw = function(self, ent)
        return false
    end
})

GlowLib:Define("models/combine_soldier.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(0, 100, 210, 170),
        [1] = Color(140, 25, 0, 170)
    },
})

GlowLib:Define("models/combine_soldier_prisonguard.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(190, 145, 0, 170),
        [1] = Color(155, 40, 0, 170)
    },
})

GlowLib:Define("models/combine_super_soldier.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos + attachmentData.Ang:Forward() * -1
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(200, 0, 0, 170),
    },
})

GlowLib:Define("models/combine_scanner.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        if ( !attachmentData ) then
            return ent:GetPos() + ent:GetAngles():Forward() * 15 + ent:GetAngles():Up() * 1.1
        end

        return attachmentData.Pos + attachmentData.Ang:Forward() * -1
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(215, 105, 0, 170),
    },
})

GlowLib:Define("models/hunter.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("top_eye"))
        return attachmentData.Pos + attachmentData.Ang:Forward() * -4.5
    end,
    Attachment = "top_eye",
    Color = {
        [0] = Color(0, 255, 255, 150),
    },
    Size = 0.25,
    OnInitialize = function(self, ent, sprite)
        local glow_color = self.Color[ent:GetSkin()] or self.Color[0] or color_white

        local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            glow_color = self:CustomColor(ent, glowCol)
        end

        local attach = ent:LookupAttachment("bottom_eye")
        local attachmentData = ent:GetAttachment(attach)
        if ( !attachmentData ) then return end

        local attach_head = ent:LookupAttachment("head_center")
        local attachmentData_head = ent:GetAttachment(attach_head)
        if ( !attachmentData_head ) then return end

        if ( SERVER ) then
            local sprite = GlowLib:CreateSprite(ent, {
                Color = glow_color,
                Attachment = "bottom_eye",
                Position = attachmentData.Pos + attachmentData.Ang:Forward() * -4.5,
                Size = 0.25,
            })

            local sprite2 = GlowLib:CreateSprite(ent, {
                Color = Color(0, 60, 255, 160),
                Attachment = "head_center",
                Position = attachmentData_head.Pos + attachmentData_head.Ang:Up() * 20 + attachmentData_head.Ang:Right() * 2,
                Size = 0.8,
                NoUpdate = true,
            })
        end
    end,
})

GlowLib:Define("models/shield_scanner.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eye"))
        return attachmentData.Pos
    end,
    Attachment = "eye",
    Size = 0.35,
    Color = {
        [0] = Color(215, 105, 0, 170),
    },
})

GlowLib:Define("models/vortigaunt.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos + attachmentData.Ang:Forward() * 3
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(205, 0, 0, 170),
    },
    Size = 0.25,
    CustomColor = function(self, ent, sprite)
        if ( ent:GetInternalVariable("m_bIsBlue") ) then
            return Color(65, 0, 255, 170)
        end
    end,
})

GlowLib:CopyDefinition("models/vortigaunt_slave.mdl", "models/vortigaunt.mdl")
GlowLib:CopyDefinition("models/vortigaunt_blue.mdl", "models/vortigaunt.mdl")
GlowLib:CopyDefinition("models/vortigaunt_doctor.mdl", "models/vortigaunt.mdl")

GlowLib:Define("models/dog.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))

        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(220, 5, 0, 170),
    },
})

GlowLib:Define("models/props_combine/health_charger001.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Forward() * 7 + ent:GetAngles():Up() * -1 + ent:GetAngles():Right() * 2.5
    end,
    Color = {
        [0] = Color(0, 255, 255),
    },
    Size = 0.15,
    GlowTexture = "sprites/light_glow02.vmt",
    OnInitialize = function(self, ent, sprite)
        local glow_eyes = ent:GetGlowingEyes()
        local glowCol = self.Color[ent:GetSkin()] or self.Color[0] or color_white

        local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            glowCol = self:CustomColor(ent, glowCol)
        end

        if ( SERVER ) then
            local sprite = GlowLib:CreateSprite(ent, {
                Color = Color(0, 195, 255, 170),
                Position = ent:GetPos() + ent:GetAngles():Forward() * 9 + ent:GetAngles():Up() * 5,
                Size = 0.5,
            })

            local spriteTable = sprite:GetTable()
            spriteTable.GlowLib_bNoUpdate = true

            ent:DeleteOnRemove(sprite)

            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetAngles():Forward() * 12 + ent:GetAngles():Up() * 3 + ent:GetAngles():Right() * -5)
            light:SetParent(ent)
            light:SetKeyValue("_light", "0 255 255 255")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "15")
            light:SetKeyValue("brightness", "1")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/props_combine/suit_charger001.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Forward() * 7 + ent:GetAngles():Up() * 11 + ent:GetAngles():Right() * 1.5
    end,
    Color = {
        [0] = Color(255, 100, 0),
    },
    Size = 0.15,
    GlowTexture = "sprites/light_glow02.vmt",
    OnInitialize = function(self, ent, sprite)
        local glow_eyes = ent:GetGlowingEyes()

        local glowCol = self.Color[ent:GetSkin()] or self.Color[0] or color_white

        local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
        if ( glowColCustom != nil ) then
            glowCol = self:CustomColor(ent, glowCol)
        end

        if ( SERVER ) then
            local sprite = GlowLib:CreateSprite(ent, {
                Color = Color(255, 115, 0, 170),
                Position = ent:GetPos() + ent:GetAngles():Forward() * 9 + ent:GetAngles():Up() * 5,
                Size = 0.5,
            })

            local spriteTable = sprite:GetTable()
            spriteTable.GlowLib_bNoUpdate = true

            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetAngles():Forward() * 10 + ent:GetAngles():Up() * 4 + ent:GetAngles():Right() * -1)
            light:SetParent(ent)
            light:SetKeyValue("_light", "255 135 0")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "5")
            light:SetKeyValue("brightness", "6")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/player/combine_soldier.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(0, 100, 210, 170),
        [1] = Color(140, 25, 0, 170)
    },
    CustomColor = function(self, ent, sprie)
        if ( ent:IsPlayer() ) then
            return ent:GetPlayerColor():ToColor()
        end
    end,
})

GlowLib:Define("models/player/combine_super_soldier.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("eyes"))
        return attachmentData.Pos
    end,
    Attachment = "eyes",
    Color = {
        [0] = Color(200, 0, 0, 170),
    },
    CustomColor = function(self, ent, sprie)
        if ( ent:IsPlayer() ) then
            return ent:GetPlayerColor():ToColor()
        end
    end,
})

GlowLib.Glow_Data["models/player/combine_soldier_prisonguard.mdl"] = table.Copy(GlowLib.Glow_Data["models/combine_soldier_prisonguard.mdl"])

GlowLib:Define("models/antlion_guard.mdl", {
    Position = function(self, ent)
        local attachmentData = ent:GetAttachment(ent:LookupAttachment("attach_glow1"))
        return attachmentData.Pos
    end,
    Attachment = "attach_glow1",
    Color = {
        [0] = Color(255, 100, 0),
        [1] = Color(0, 255, 0),
    },
    Size = 0.5,
    GlowTexture = "sprites/grubflare1.vmt",
    OnInitialize = function(self, ent, sprite)
        local entTable = ent:GetTable()
        entTable.GlowLib_bDontUpdate = true
        entTable.GlowLib_bDisabled = true

        if ( SERVER ) then
            if ( IsValid(ent) and IsValid(sprite) ) then
                sprite:SetParent(nil)
                SafeRemoveEntity(sprite)
            end

            for k, v in ipairs(ent:GetChildren()) do
                if ( !IsValid(v) or v:GetClass() != "env_sprite" ) then continue end

                local glowCol = self.Color[ent:GetSkin()] or self.Color[0] or color_white

                local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
                if ( glowColCustom != nil ) then
                    glowCol = self:CustomColor(ent, glowCol)
                end

                v:SetColor(glowCol)
            end
        end
    end,
    CustomColor = function(self, ent, sprite)
        if ( ent:GetInternalVariable("cavernbreed") ) then
            return Color(0, 255, 0)
        end
    end,
    ShouldDraw = function(self, ent)
        if ( !ent:GetInternalVariable("cavernbreed") and ent:GetSkin() == 0 ) then
            return false
        end

        return true
    end,
})

GlowLib:Define("models/antlion_grub.mdl", {
    Position = function(self, ent)
        return ent:GetAttachment(1).Pos
    end,
    Attachment = "glow",
    Color = {
        [0] = Color(0, 255, 0),
    },
    GlowTexture = "sprites/grubflare1.vmt",
    OnInitialize = function(self, ent, sprite)
        if ( SERVER ) then
            local entTable = ent:GetTable()
            entTable.GlowLib_bDontUpdate = true
            entTable.GlowLib_bDisabled = true

            if ( IsValid(ent) and IsValid(sprite) ) then
                sprite:SetParent(nil)
                SafeRemoveEntity(sprite)
            end

            for k, v in ipairs(ent:GetChildren()) do
                if ( !IsValid(v) or v:GetClass() != "env_sprite" ) then continue end

                local glowCol = self.Color[ent:GetSkin()] or self.Color[0] or color_white

                local glowColCustom = self.CustomColor and isfunction(self.CustomColor) and self:CustomColor(ent, glowCol)
                if ( glowColCustom != nil ) then
                    glowCol = self:CustomColor(ent, glowCol)
                end

                v:SetColor(glowCol)
            end
        end
    end,
})

GlowLib:Define("models/healthvial.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetUp() * 5
    end,
    Color = {
        [0] = Color(0, 255, 0, 200),
    },
    Size = 0.15,
    OnInitialize = function(self, ent, sprite)
        if ( SERVER ) then
            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetUp() * 5)
            light:SetParent(ent)
            light:SetKeyValue("_light", "0 255 0")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "13")
            light:SetKeyValue("brightness", "2")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/items/healthkit.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetUp() * 6 + ent:GetForward() * 5 + ent:GetRight() * -3.5
    end,
    Color = {
        [0] = Color(0, 255, 0, 150),
    },
    Size = 0.25,
    OnInitialize = function(self, ent, sprite)
        if ( SERVER ) then
            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetUp() * 6 + ent:GetForward() * 5 + ent:GetRight() * -3.5)
            light:SetParent(ent)
            light:SetKeyValue("_light", "0 255 0")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "18")
            light:SetKeyValue("brightness", "2")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/items/battery.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetUp() * 6 + ent:GetForward() * 2
    end,
    Color = {
        [0] = Color(0, 255, 255, 150),
    },
    Size = 0.2,
    OnInitialize = function(self, ent, sprite)
        if ( SERVER ) then
            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetUp() * 5)
            light:SetParent(ent)
            light:SetKeyValue("_light", "0 255 255")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "13")
            light:SetKeyValue("brightness", "2")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/items/combine_rifle_ammo01.mdl", {
    Position = function(self, ent)
        return ent:WorldSpaceCenter()
    end,
    Color = {
        [0] = Color(255, 220, 0, 220),
    },
    Size = 0.3,
    OnInitialize = function(self, ent, sprite)
        if ( SERVER ) then
            local light = ents.Create("light_dynamic")
            light:SetNW2String("GlowEyeName", "GlowLib_Eye_" .. ent:EntIndex())
            light:SetPos(ent:GetPos() + ent:GetUp() * 5)
            light:SetParent(ent)
            light:SetKeyValue("_light", "255 220 0")
            light:SetKeyValue("style", "1")
            light:SetKeyValue("distance", "13")
            light:SetKeyValue("brightness", "2")
            light:Spawn()
            light:Activate()

            ent:DeleteOnRemove(light)
        end
    end,
})

GlowLib:Define("models/props_combine/combine_intmonitor001.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 29 + ent:GetAngles():Forward() * 10
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
        [1] = Color(0, 0, 0, 0),
        [2] = Color(200, 0, 0, 200)
    },
    Size = 1.7,
})

GlowLib:Define("models/props_combine/combine_intmonitor003.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 29 + ent:GetAngles():Forward() * 35
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
        [1] = Color(0, 0, 0, 0),
        [2] = Color(200, 0, 0, 200)
    },
    Size = 1.7,
})

GlowLib:Define("models/props_combine/combine_monitorbay.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 10 + ent:GetAngles():Forward() * 10
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
    },
    Size = 4,
})

GlowLib:Define("models/props_combine/weaponstripper.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 60 + ent:GetAngles():Forward() * 15
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
    },
    Size = 3,
})

GlowLib:Define("models/props_combine/combine_interface001.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 48 + ent:GetAngles():Forward() * 2 + ent:GetAngles():Right() * 2
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
        [1] = Color(0, 0, 0, 0),
    },
    Size = 1,
})

GlowLib:Define("models/props_combine/combine_interface002.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 48 + ent:GetAngles():Forward() * 2 + ent:GetAngles():Right() * 2
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
        [1] = Color(0, 0, 0, 0),
    },
    Size = 1.2,
})

GlowLib:Define("models/props_combine/combine_interface003.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 48 + ent:GetAngles():Forward() * 2 + ent:GetAngles():Right() * -5
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
        [1] = Color(0, 0, 0, 0),
    },
    Size = 1.2,
})

GlowLib:Define("models/props_combine/masterinterface.mdl", {
    Position = function(self, ent)
        return ent:GetPos() + ent:GetAngles():Up() * 70 + ent:GetAngles():Forward() * -30 + ent:GetAngles():Right() * 1
    end,
    Color = {
        [0] = Color(0, 255, 255, 200),
    },
    Size = 3,
})
