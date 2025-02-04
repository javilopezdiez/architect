function debug()
    debug_print( "get_window_name:                      " .. get_window_name())
    debug_print( "get_application_name:                 " .. get_application_name())
    debug_print( "get_window_geometry:                  " .. get_window_geometry())
    debug_print( "get_window_client_geometry:           " .. get_window_client_geometry())
    debug_print( "get_window_type:                      " .. get_window_type())
    debug_print( "get_class_instance_name:              " .. get_class_instance_name())
    debug_print( "get_window_role:                      " .. get_window_role())
    debug_print( "get_window_xid:                       " .. get_window_xid())
    debug_print( "get_window_class:                     " .. get_window_class())
    debug_print( "get_workspace_count:                  " .. get_workspace_count())
end

function contains(list, search_element)
    for _, i in ipairs(list) do
        if search_element:find(i) then
            return true
        end
    end
    return false
end

local avoid_roles = {
    "dropdown"
}
function avoidRoles()
    return contains(avoid_roles, get_window_role())
end
local avoid_names = {
}
function avoidName()
    return contains(avoid_names, get_window_name())
end

local accepted_types = {
    "WINDOW_TYPE_NORMAL",
    "WINDOW_TYPE_DIALOG"
}
function avoidType()
    return not contains(accepted_types, get_window_type())
end

function is_main_display_active()
    local handle = io.popen("xrandr --listmonitors | grep '*'")
    local primary_display_info = handle:read("*all")
    handle:close()
    return primary_display_info ~= nil and primary_display_info:find("%*")
end

function get_screen_dimensions()
    local handle = io.popen("xrandr | grep '*' | awk '{print $1}' | head -n 1")
    local resolution = handle:read("*line")
    handle:close()

    if resolution then
        local width, height = resolution:match("(%d+)x(%d+)")
        return tonumber(width), tonumber(height)
    else
        return 1920, 1080
    end
end

function center_and_resize_window(window_id)
    local screen_width, screen_height = get_screen_dimensions()
    local new_width = math.floor(screen_width * 10/11)
    local new_height = math.floor(screen_height * 5/6)
    local x_pos = math.floor((screen_width - new_width) / 2)
    local y_pos = math.floor((screen_height - new_height) / 2)

    if window_id then 
        set_window_geometry_by_id(window_id, x_pos, y_pos, new_width, new_height)
    else 
        set_window_geometry(x_pos, y_pos, new_width, new_height)
    end
end

function set_window_geometry_by_id(window_id, x_pos, y_pos, width, height)
    os.execute(string.format(
        "xdotool windowmove %s %d %d windowsize %s %d %d",
        window_id, x_pos, y_pos, window_id, width, height
    ))
end

-- Function to check if a command is available
function is_command_available(command)
    local handle = io.popen("command -v " .. command .. " &> /dev/null && echo 'true' || echo 'false'")
    local result = handle:read("*a")
    handle:close()
    return result:match("true") ~= nil
end

-- INPUT
if not get_window_type and arg[1] then
    local window_id = arg[1]
    os.execute("echo 'Focused Window ID: " .. window_id .. "'")
    center_and_resize_window(window_id)
-- DEVILSPIE
else
    if (not avoidType() and 
        not avoidRoles() and 
        not avoidName()) then
        debug()
        if is_main_display_active() then
            maximize()
        else
            center_and_resize_window()
        end
    end
end