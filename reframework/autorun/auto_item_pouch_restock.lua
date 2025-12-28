-- auto_item_pouch_restock.lua : written by archwizard1204                                                                                                                                                                                                                                                                                                                                                                                      8964
-- Only on NexusMods, my profile page : https://next.nexusmods.com/profile/archwizard1204?8964
-- version : 1.6

local settings      = require("AutoItemPouchRestock.settings")
local settingsMenu  = require("AutoItemPouchRestock.settings_menu")
local locale        = require("AutoItemPouchRestock.locale")

local ItemUtil      = sdk.find_type_definition("app.ItemUtil")
local ItemMySetUtil = sdk.find_type_definition("app.ItemMySetUtil")
local ChatManager   = sdk.get_managed_singleton("app.ChatManager")

settings.init()

local function loadLocale()
    if not locale.isInitialized then
        locale.init()
    end
end

local function sendNotification(msg)
    if not ChatManager or settings.config.notification == false then return end

    ChatManager:call("addSystemLog(System.String)", msg)
end

local function restockCurrentPouchItems()
    loadLocale()
    local fillPouchItems = ItemUtil:get_method("fillPouchItems()")

    if not fillPouchItems then return end

    fillPouchItems(nil)
    sendNotification(locale.LOCALE.item_pouch_restocked)
end

local function restockShellPouchItems()
    local fillShellPouchItems = ItemUtil:get_method("fillShellPouchItems()")

    if not fillShellPouchItems then return end

    fillShellPouchItems(nil)
end

local function restockItems()
    loadLocale()
    if settings.config.mySet ~= nil then
        local applyMySetToPouch = ItemMySetUtil:get_method("applyMySetToPouch(System.Int32)")
        local isValidData = ItemMySetUtil:get_method("isValidData(System.Int32)")

        if not applyMySetToPouch or not isValidData then return end

        local mySetInt32 = sdk.to_ptr(settings.config.mySet)

        if isValidData(nil, mySetInt32) then
            applyMySetToPouch(nil, mySetInt32)
            sendNotification(locale.LOCALE.item_loadout_applied)
        else
            restockCurrentPouchItems()
        end
    else
        sendNotification('Please use one of your loadout first.')
        restockCurrentPouchItems()
    end
end

local function restockCamp(retval)      -- テントに入る
    if settings.config.campRestock == 1 then
        restockItems()
        restockShellPouchItems()
    elseif settings.config.campRestock == 2 then
        restockCurrentPouchItems()
        restockShellPouchItems()
    end
    return retval
end

local function restockMission(args)   -- クエスト受注
    local ActiveQuest = sdk.to_managed_object(args[3])
    if not ActiveQuest:call("isArenaQuest") then
        if settings.config.missionRestock == 1 then
            restockItems()
            restockShellPouchItems()
        elseif settings.config.missionRestock == 2 then
            restockCurrentPouchItems()
            restockShellPouchItems()
        end
    end
    return sdk.PreHookResult.CALL_ORIGINAL
end

local function restockSeikret(retval)   -- セクレト支給品メニュー
    if settings.config.seikretRestock == 1 then
        restockItems()
        restockShellPouchItems()
    elseif settings.config.seikretRestock == 2 then
        restockCurrentPouchItems()
        restockShellPouchItems()
    end
    return retval
end

local function mySetTracker(args)
    local mySet = (sdk.to_int64(args[2]) & 0xFFFFFFFF)

    if settings.config.mySet ~= mySet then
        settings.config.mySet = mySet
        settings.save()
    end
end

re.on_frame(function()
    if settingsMenu.isOpened then
        settingsMenu.draw()
    end
end)

re.on_draw_ui(function()
    if imgui.tree_node("Auto Item Pouch Restock") then
        if imgui.button("Open Settings") then
            settingsMenu.isOpened = not settingsMenu.isOpened;
        end
        imgui.tree_pop()
    end
end)

re.on_config_save(function()
	settings.save()
end)

sdk.hook(sdk.find_type_definition("app.Gm170_002"):get_method("buttonPushEvent"), nil, restockCamp)
sdk.hook(sdk.find_type_definition("app.mcHunterTentAction"):get_method("updateBegin"), nil, restockCamp)
sdk.hook(sdk.find_type_definition("app.cQuestDirector"):get_method("acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)"), restockMission, nil)
sdk.hook(sdk.find_type_definition("app.FacilitySupplyItems"):get_method("openGUI"), nil, restockSeikret)
sdk.hook(sdk.find_type_definition("app.ItemMySetUtil"):get_method("applyMySetToPouch"), mySetTracker, nil)
sdk.hook(sdk.find_type_definition("app.GUI030203"):get_method("applyMySet"), mySetTracker, nil)