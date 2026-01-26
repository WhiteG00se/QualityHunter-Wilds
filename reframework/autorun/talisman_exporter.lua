-- talisman_exporter.lua
-- version : 1.1.2
-- written by MHVuze, thanks to praydog for the tooling
-- Nexus Mods profile page : https://www.nexusmods.com/profile/MHVuze

function export_ws()
    local getSkillName = sdk.find_type_definition("app.MessageUtil"):get_method("getHunterSkillName(app.HunterDef.Skill)")
    local getMsgWithLang = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid, via.Language)")

    local exportString = ""

    local validAmuletTypes = {
        [189] = "Unknown Charm",
        [190] = "Historical Charm",
        [191] = "Secret Charm",
        [192] = "Golden Age Charm",
    }

    local manager = sdk.get_managed_singleton("app.SaveDataManager")
    local box = manager:getCurrentUserSaveData()._Equip._EquipBox

    local count = box:get_Count()
    log.info(string.format("[Talisman Exporter] Found %d pieces in EquipBox", count))

    for i = 0, count - 1 do
        local work = box:get_Item(i)
        if work ~= nil then
            local category = work:get_Category()
            -- Filter for talismans
            if category == 2 then
                local amuletType = work.FreeVal0
                if validAmuletTypes[amuletType] ~= nil then
                    local customValues = work.BowgunCustomizeId
                    local skills = {customValues:get_Item(0), customValues:get_Item(1), customValues:get_Item(2)}
                    local slot = customValues:get_Item(3)

                    -- Process all 3 skills
                    local skillNames = {}
                    local skillPts = {}
                    for j = 1, 3 do
                        if skills[j] == 0 then
                            skillNames[j] = ""   -- empty name
                            skillPts[j] = 0      -- zero points
                        else
                            local level = math.floor(skills[j] / 1000)
                            local enumVal = skills[j] % 1000
                            skillNames[j] = getMsgWithLang:call(nil, getSkillName:call(nil, enumVal), 1)
                            skillPts[j] = level
                        end
                    end

                    -- Use DecodeSlots to handle armor/weapon slots
                    local armorSlots, weaponSlot = decodeSlots(slot)
                    local a1 = armorSlots[1] or 0
                    local a2 = armorSlots[2] or 0
                    local a3 = armorSlots[3] or 0

                    -- format: s1_name,s1_pts,s2_name,s2_pts,s3_name,s3_pts,a_slot1,a_slot2,a_slot3,w_slot1,w_slot2,w_slot3
                    local singleString = string.format("%s,%d,%s,%d,%s,%d,%d,%d,%d,%d,0,0",
                        skillNames[1], skillPts[1],
                        skillNames[2], skillPts[2],
                        skillNames[3], skillPts[3],
                        a1, a2, a3,
                        weaponSlot
                    )

                    exportString = exportString .. singleString .. "\n"
                    --log.info("[Talisman Exporter] " .. singleString)
                end
            end
        end
    end
    fs.write("Talisman_Exporter/Exported_Talismans.txt", exportString)
end

function decodeSlots(slots)
    -- decimal-packed: AAAA (thousands=armor1, hundreds=armor2, tens=armor3 OR weapon-level, ones=flag)
    local a1   = math.floor(slots / 1000) % 10
    local a2   = math.floor(slots / 100)  % 10
    local a3   = math.floor(slots / 10)   % 10
    local flag = slots % 10

    local hasWeapon = (flag == 1 or flag == 3)

    -- If a weapon slot exists, the tens digit encodes the weapon slot level,
    -- NOT an armor slot. So don't treat it as armor.
    if hasWeapon then
        if flag == 3 then
            -- weapon slot only, no armor slots
            a1, a2, a3 = 0, 0, 0
        else
            -- weapon + armor
            a1 = a2
            a2 = a3
            a3 = 0
        end
    end

    return {a1, a2, a3}, (hasWeapon and 1 or 0)
end

-- UI rendering
re.on_draw_ui(function()
    local title = "Talisman Exporter###Talisman Exporter"
    if imgui.tree_node(title) then
        if imgui.button("Export") then
            export_ws()
        end
        imgui.tree_pop()
    end
end)

sdk.hook(sdk.find_type_definition("app.SaveDataManager"):get_method("requestSaveDataManualSave(app.SaveDataManager.SaveDataRequestAppCallback)"), export_ws, nil)

