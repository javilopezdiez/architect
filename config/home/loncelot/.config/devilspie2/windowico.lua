-- List of windows and icons
local windows = {
    {name = "Picture in picture", icon = "/home/loncelot/Pictures/ico/pip.png"},
    {name = "spotify_player", icon = "/home/loncelot/Pictures/ico/spotify.png"},
    -- Add more here
}

-- Function to run shell commands and get output
local function exec(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

for _, win in ipairs(windows) do
    -- Get the first window ID matching the name
    local win_id = exec('xdotool search --name "' .. win.name .. '" | head -n 1'):gsub("%s+", "")
    
    if win_id ~= "" then
        print("Setting icon for window:", win.name)
        -- Apply icon
        os.execute('xseticon -id ' .. win_id .. ' "' .. win.icon .. '"')
    end
end
