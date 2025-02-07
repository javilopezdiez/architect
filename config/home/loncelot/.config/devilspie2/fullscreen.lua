-- VARIABLES
local WIDTH = 10/11
local HEIGHT = 5/6

local default_external_devil_size = "s"
local WIDTH_S = 2/5
local HEIGHT_S = 2/3

local avoid_roles = {
	"dropdown"
}
local avoid_names = {
	'notify',
	'Authenticate',
	'xfce4-screenshooter'
}
local accepted_types = {
	"WINDOW_TYPE_NORMAL",
	"WINDOW_TYPE_DIALOG"
}

-- MAIN
function main()
	if isScript() then
		setSize(true, arg)
		debug(true, arg)
		if is_main_display_active() then
			-- os.execute("mywin.sh --max")
			-- center_and_resize(WIDTH, HEIGHT, arg[1]) -- equivalent
			center_and_resize_window(arg[1])
		else
			-- center_and_resize(1/3, 2/3, arg[1]) -- could do
			center_and_resize_window(arg[1])
		end
	else
		if (not avoidType() and 
			not avoidRoles() and 
			not avoidName()) then
			debug(false, null)
			if is_main_display_active() then
				-- os.execute("mywin.sh --max")
				-- center_and_resize(WIDTH, HEIGHT) -- equivalent
				center_and_resize_window()
			else
				-- when big display set default size
				setSize(false, null)
				-- center_and_resize(1/3, 2/3) -- could do
				center_and_resize_window()
			end
		end
	end
end

-- METHODS
function debug(isScript, arg)
	if isScript then
		os.execute("echo 'script_window_xid                             '" .. arg[1])
		if arg[2] then os.execute("echo 'size                                          '" .. arg[2]) end
	else
		debug_print("devil_get_window_name                         " .. get_window_name())
		debug_print("devil_get_application_name:                   " .. get_application_name())
		debug_print("devil_get_window_geometry:                    " .. get_window_geometry())
		debug_print("devil_get_window_client_geometry:             " .. get_window_client_geometry())
		debug_print("devil_get_window_type:                        " .. get_window_type())
		debug_print("devil_get_class_instance_name:                " .. get_class_instance_name())
		debug_print("devil_get_window_role:                        " .. get_window_role())
		debug_print("devil_get_window_xid:                         " .. get_window_xid())
		debug_print("devil_get_window_class:                       " .. get_window_class())
		debug_print("devil_get_workspace_count:                    " .. get_workspace_count())
	end
end

function isScript()
	local isScript = not get_window_type and arg[1] ~= nil
	os.execute("echo 'shared_isScript------------------------------>'" .. tostring(isScript))
	return isScript
end
function setSize(isScript, arg)
	if arg ~= nill then
		size = arg[2]
	end
	if (not isScript and default_external_devil_size == "s") or size == "s" then
		WIDTH = WIDTH_S
		HEIGHT = HEIGHT_S
	end
end

function contains(list, search_element)
	for _, i in ipairs(list) do
		if search_element:find(i) then
			return i
		end
	end
	return null
end
function avoidRoles()
	local contains = contains(avoid_roles, get_window_role())
	if contains ~= nil then
		debug_print("devil_avoided_window_role:                    " .. contains)
	end
	return contains ~= nil;
end
function avoidName()
	local contains = contains(avoid_names, get_window_name())
	if contains ~= nil then
		debug_print("devil_avoided_window_name:                    " .. contains)
	end
	return contains ~= nil;
end
function avoidType()
	local contains = contains(accepted_types, get_window_type())
	if contains == nil then
		debug_print("devil_avoided_window_type:                    " .. get_window_type())
	end
	return contains == nil;
end

function is_main_display_active()
	local main_handle = io.popen("xrandr --listmonitors | grep 'LVDS-1'")
	local main_display_info = main_handle:read("*all")
	main_handle:close()
	local isMainDisplayActive = main_display_info ~= ""
	os.execute("echo 'shared_isMainDisplayActive                    '" .. tostring(isMainDisplayActive))
	return isMainDisplayActive
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
	center_and_resize(WIDTH, HEIGHT, window_id)
end
function center_and_resize(w, h, window_id)
	os.execute("echo 'script_local                                  resize'")
	local screen_width, screen_height = get_screen_dimensions()
	local new_width = math.floor(screen_width * w)
	local new_height = math.floor(screen_height * h)
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

-- MAIN AT THE END TO COUNT WITH OTHER METHODS
main()