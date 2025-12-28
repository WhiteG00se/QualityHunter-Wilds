local this = {}

local settings          = require("AutoItemPouchRestock.settings")

local DEFAULT_LOCALE    = "en-US"
local LOCALE_PATH       = "auto_item_pouch_restock/locale/"

local languageIndexToISO639 = {
    [0] = "ja-JP",
    [1] = "en-US",
    [2] = "fr-FR",
    [3] = "it-IT",
    [4] = "de-DE",
    [5] = "es-ES",
    [6] = "ru-RU",
    [7] = "pl-PL",
    [10] = "pt-BR",
    [11] = "ko-KR",
    [12] = "zh-HK",
    [13] = "zh-CN",
    [32] = "es-ES"
}

this.LOCALE_OPTIONS = {
    ["ja-JP"] = "日本語 Japanese",
    ["en-US"] = "English",
    ["fr-FR"] = "Français French",
    ["it-IT"] = "Italiano Italian",
    ["de-DE"] = "Deutsch German",
    ["nl-NL"] = "Niederländisch Dutch",
    ["es-ES"] = "Español Spanish",
    ["pl-PL"] = "Polski Polish",
    ["pt-BR"] = "Português do Brasil Brazilian Portuguese",
    ["ko-KR"] = "한국어 Korean",
    ["zh-HK"] = "正體中文 Traditional Chinese",
    ["zh-CN"] = "简体中文 Simplified Chinese",
}

this.LOCALE = {}
this.RESTOCK_OPTIONS = {}

this.isInitialized = false
this.currentLocale = nil

this.getLanguage = function()
    if settings.config.locale then
        return settings.config.locale
    else if this.currentLocale then
        return this.currentLocale
    end
        local GUISystem = sdk.get_native_singleton("via.gui.GUISystem")
        local GUISystemType = sdk.find_type_definition("via.gui.GUISystem")
        local languageIndex = sdk.call_native_func(GUISystem, GUISystemType, "get_MessageLanguage")

        local locale = languageIndexToISO639[languageIndex]

        if locale and this.LOCALE_OPTIONS[locale] then
            return locale
        else
            return DEFAULT_LOCALE
        end
    end
end

this.loadTranslation = function()
    local locale = this.getLanguage()
    this.currentLocale = locale

    local fileName = LOCALE_PATH .. locale .. ".json"
    this.LOCALE = json.load_file(fileName)

    this.RESTOCK_OPTIONS = {
        [0] = this.LOCALE.disable,
        [1] = this.LOCALE.restock_from_item_my_set,
        [2] = this.LOCALE.restock_item_pouch
    }
end

this.init = function()
    this.loadTranslation()
    this.isInitialized = true
end

return this