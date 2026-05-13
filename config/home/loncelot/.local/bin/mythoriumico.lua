local json = require("dkjson")

local function exec(cmd)
    local h = io.popen(cmd)
    if not h then return nil end
    local out = h:read("*a")
    h:close()
    return out
end

-- cache: win_id -> last title
local last_title = {}

-- cache: domain -> icon path
local icon_cache = {}

local function removeIcons()
    print("thoriumico.lua - Removing temp icons")
    os.execute("rm -f /tmp/thorium-favicon-*.png")
end

local function getDomain(url)
    return url:match("https?://([^/]+)")
end

local function getIcon(url, win_id)
    local domain = getDomain(url)
    if not domain then return nil end

    if icon_cache[domain] then
        return icon_cache[domain]
    end

    local icon_path = "/tmp/thorium-favicon-" .. domain .. ".png"

    os.execute(string.format(
        'curl -L -s "https://www.google.com/s2/favicons?sz=64&domain_url=%s" -o "%s"',
        url,
        icon_path
    ))

    icon_cache[domain] = icon_path
    return icon_path
end

local function processWindow(tabs, title, win_id)

    if last_title[win_id] == title then
        return -- nothing changed, skip everything
    end

    last_title[win_id] = title

    for _, tab in ipairs(tabs) do

        if tab.type == "page"
            and tab.url
            and tab.title
            and title:find(tab.title, 1, true) then

            local icon_path = getIcon(tab.url, win_id)
            if not icon_path then return end

            print("thoriumico.lua - Updating icon for", win_id, tab.title)

            os.execute(string.format(
                'xseticon -id %s "%s"',
                win_id,
                icon_path
            ))

            break -- only apply first match per window
        end
    end
end

-- MAIN
local windows = exec("xdotool search --class thorium")
if not windows or windows == "" then
    removeIcons()
    return
end

local tabs_json = exec("curl -s http://localhost:9222/json")
local tabs = tabs_json and json.decode(tabs_json)

if not tabs then
    removeIcons()
    return
end

for win_id in windows:gmatch("%S+") do

    local title = exec("xdotool getwindowname " .. win_id)

    if title then
        title = (title or ""):gsub("%s%- Thorium%s*$", "")
        processWindow(tabs, title, win_id)
    end
end