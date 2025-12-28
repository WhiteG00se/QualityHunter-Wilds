local settings  = require("AutoItemPouchRestock.settings")
local locale    = require("AutoItemPouchRestock.locale")

local WINDOW_FLAGS = 0x120

local this = {}

this.isOpened = false

this.draw = function()
    this.isOpened = imgui.begin_window("Auto Item Pouch Restock Settings", this.isOpened, WINDOW_FLAGS);

    if not this.isOpened then
        return
    end

    local changedLocale = false
    local changedPreference = false

    if not locale.isInitialized then
        locale.init()
    end

    -- Languages
    imgui.push_item_width(200.0)
    changedLocale, settings.config.locale = imgui.combo('Languages', locale.currentLocale, locale.LOCALE_OPTIONS)
    if changedLocale then
        locale.loadTranslation()
    end

    imgui.new_line()

    -- Preference
    imgui.push_item_width(320.0)
    changedPreference, settings.config.notification      = imgui.checkbox(locale.LOCALE.notification, settings.config.notification)
    changedPreference, settings.config.campRestock       = imgui.combo(locale.LOCALE.enter_tent, settings.config.campRestock, locale.RESTOCK_OPTIONS)
    changedPreference, settings.config.missionRestock    = imgui.combo(locale.LOCALE.mission_start, settings.config.missionRestock, locale.RESTOCK_OPTIONS)
    changedPreference, settings.config.seikretRestock    = imgui.combo(locale.LOCALE.check_seikret_pouch, settings.config.seikretRestock, locale.RESTOCK_OPTIONS)

    if changedLocale or changedPreference then
        settings.save()
    end

    imgui.end_window()
end

return this