local json = require("dkjson")

local function exec(cmd)
    local h = io.popen(cmd)
    if not h then return nil end
    local out = h:read("*a")
    h:close()
    return out
end

local function removeIcons()
    print("thoriumico.lua - Removing temp icons")
    os.execute("rm -f /tmp/thorium-favicon-*.png")
end

local windows = exec("xdotool search --class thorium")

if not windows or windows == "" then
    removeIcons()
    return
end

for win_id in windows:gmatch("%S+") do

    local title = exec("xdotool getwindowname " .. win_id)
    if title then
        title = title:gsub("%s%- Thorium%s*$", "")
    else
        title = ""
    end

    local tabs_json = exec("curl -s http://localhost:9222/json")

    if tabs_json and tabs_json ~= "" then

        local tabs = json.decode(tabs_json)

        if tabs then
            for _, tab in ipairs(tabs) do

                if tab.title and title:find(tab.title, 1, true) then
                    if tab.url then
                        local icon_path = "/tmp/thorium-favicon-" .. win_id .. ".png"

                        print("thoriumico.lua - Saving temp icon")

                        os.execute(string.format(
                            'curl -L -s "https://www.google.com/s2/favicons?sz=64&domain_url=%s" -o "%s"',
                            tab.url,
                            icon_path
                        ))

                        os.execute(string.format(
                            'xseticon -id %s "%s"',
                            win_id,
                            icon_path
                        ))

                        print("thoriumico.lua - Updated icon for tab:", icon_path, tab.title)
                    end
                end
            end
        end
    else
        removeIcons()
    end
end