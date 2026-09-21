local windows = {
    {name = "Picture in picture", icon = "/home/loncelot/Pictures/ico/pip.png"},
    {name = "spotify_player", icon = "/home/loncelot/Pictures/ico/spotify.png"},
    {name = "yt-x", icon = "/home/loncelot/Pictures/ico/yt.png"},
}

local function exec(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

for _, win in ipairs(windows) do
    local win_id = exec('xdotool search --onlyvisible --name "' .. win.name .. '" | head -n 1'):gsub("%s+", "")
    
    if win_id ~= "" then
        print("windowico.lua - Setting icon for window:", win.name)
        print("windowico.lua - Setting icon for window:", win_id)
        print("windowico.lua - Setting icon for window:", win.icon)
        -- Apply icon
        os.execute('xseticon -id ' .. win_id .. ' "' .. win.icon .. '"')
    end
end
