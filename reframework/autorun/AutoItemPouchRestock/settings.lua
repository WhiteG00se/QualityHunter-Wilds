local CONFIG_PATH   =   "auto_item_pouch_restock/config/config.json"
local DEFAULT_PATH  =   "auto_item_pouch_restock/config/default.json"

local this = {}

this.config = {}

this.save = function()
	json.dump_file(CONFIG_PATH, this.config)
end

this.load = function()
    local loadedConfig = json.load_file(CONFIG_PATH);
	if loadedConfig then
		this.config = loadedConfig;
        if this.config.notification == nil then
            this.config.notification = true
        end
    else
        this.config = json.load_file(DEFAULT_PATH);
    end
end

this.init = function()
    this.load()
end

return this