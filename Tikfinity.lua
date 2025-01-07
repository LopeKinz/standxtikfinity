----------------------------------
-- 1) IMPORTS & INITIAL SETTINGS
----------------------------------
local json = require("json") -- built-in Stand JSON

-- Our Node.js server endpoint for GET /events
-- Adjust the port/path if your Node script differs.
local bridge_host = "localhost:3000"
local bridge_path = "/events"

-- Are we currently polling?
local polling = false

-- Each event has its own message/command templates stored in one table:
local event_templates = {
    chat = {
        message = "Chat: {name} said: {message}",
        command = "say {name} just chatted: {message}"
    },
    gift = {
        message = "Gift: {name} sent a {gift}",
        command = "say Thank you, {name}, for the {gift}!"
    },
    like = {
        message = "Like: {name} liked the stream",
        command = "say {name} liked the stream!"
    },
    follow = {
        message = "Follow: {name} is now following!",
        command = "say Thanks for the follow, {name}!"
    },
    share = {
        message = "Share: {name} shared the stream!",
        command = "say Thank you, {name}, for sharing!"
    },
    subscribe = {
        message = "Subscribe: {name} has subscribed!",
        command = "say Thanks for subscribing, {name}!"
    },
    roomUser = {
        message = "RoomUser: {name} joined the room",
        command = "say {name} joined the room!"
    }
}

----------------------------------------
-- 2) MENU SETUP
----------------------------------------
menu.divider(menu.my_root(), "Tikfinity Bridge by legendpinkyhax")

-- Let user customize the Node.js bridge host & path
menu.text_input(
    menu.my_root(),
    "Bridge Host",
    {"tikfinity_bridge_host"},
    "Host:Port for the Node.js bridge. Default is "..bridge_host,
    function(val)
        bridge_host = val
        util.toast("Updated bridge host: "..bridge_host)
    end,
    bridge_host
)

menu.text_input(
    menu.my_root(),
    "Bridge Path",
    {"tikfinity_bridge_path"},
    "Path for the Node.js bridge. Default is "..bridge_path,
    function(val)
        bridge_path = val
        util.toast("Updated bridge path: "..bridge_path)
    end,
    bridge_path
)

-- Toggle polling on/off
menu.toggle(
    menu.my_root(),
    "Start Polling Events",
    {"tikfinity_poll"},
    "Continuously fetch new events from the Node.js bridge.",
    function(on)
        polling = on
        if on then
            util.toast("Polling started.")
            start_poll_loop()
        else
            util.toast("Polling stopped.")
        end
    end,
    false
)

-- Create sub-menus for each event (same as before)
local chat_root      = menu.list(menu.my_root(), "Chat Settings", {}, "Chat event templates")
local gift_root      = menu.list(menu.my_root(), "Gift Settings", {}, "Gift event templates")
local like_root      = menu.list(menu.my_root(), "Like Settings", {}, "Like event templates")
local follow_root    = menu.list(menu.my_root(), "Follow Settings", {}, "Follow event templates")
local share_root     = menu.list(menu.my_root(), "Share Settings", {}, "Share event templates")
local subscribe_root = menu.list(menu.my_root(), "Subscribe Settings", {}, "Subscribe event templates")
local roomuser_root  = menu.list(menu.my_root(), "RoomUser Settings", {}, "RoomUser event templates")

-- A helper to create two text inputs (message + command) for a single event
local function create_event_template_menu(root_list, event_key)
    menu.text_input(
        root_list,
        "Message Template",
        {"tikfinity_"..event_key.."_msg"},
        "Use {name}, {message}, {gift} as placeholders.",
        function(new_val)
            event_templates[event_key].message = new_val
            util.toast(event_key.." message template updated:\n" .. new_val)
        end,
        event_templates[event_key].message
    )

    menu.text_input(
        root_list,
        "Command Template",
        {"tikfinity_"..event_key.."_cmd"},
        "Use {name}, {message}, {gift} as placeholders.",
        function(new_val)
            event_templates[event_key].command = new_val
            util.toast(event_key.." command template updated:\n" .. new_val)
        end,
        event_templates[event_key].command
    )
end

-- Populate each sub-menu
create_event_template_menu(chat_root, "chat")
create_event_template_menu(gift_root, "gift")
create_event_template_menu(like_root, "like")
create_event_template_menu(follow_root, "follow")
create_event_template_menu(share_root, "share")
create_event_template_menu(subscribe_root, "subscribe")
create_event_template_menu(roomuser_root, "roomUser")


----------------------------------------
-- 3) HELPER FUNCTIONS
----------------------------------------
local function replace_placeholders(template, name, message, gift)
    local out = template
    out = string.gsub(out, "%%", "%%%%")
    out = string.gsub(out, "{name}", name or "Unknown")
    out = string.gsub(out, "{message}", message or "")
    out = string.gsub(out, "{gift}", gift or "")
    return out
end

local function display_message(txt)
    util.toast(txt, TOAST_DEFAULT)
    util.log("[Tikfinity Bridge] " .. txt)
end

local function execute_stand_command(cmd)
    util.log("[Tikfinity Bridge] Attempting to run command: " .. cmd)
    menu.trigger_commands(cmd)
end

local function handle_event(event_key, name, msg, gift)
    local templates = event_templates[event_key]
    if not templates then
        util.log("[Tikfinity Bridge] Unknown event key: " .. tostring(event_key))
        return
    end
    local display_txt = replace_placeholders(templates.message, name, msg, gift)
    local cmd_txt     = replace_placeholders(templates.command, name, msg, gift)

    display_message(display_txt)
    execute_stand_command(cmd_txt)
end

-- parse_tiktok_event is same as your original
function parse_tiktok_event(event_json)
    local ok, event_obj = pcall(json.decode, event_json)
    if not ok or type(event_obj) ~= "table" then
        util.log("[Tikfinity Bridge] Invalid JSON: " .. tostring(event_json))
        return
    end

    local event_type = event_obj.event or ""
    local data = event_obj.data or {}

    local name = data.nickname or data.uniqueId or "Unknown"
    local message = ""
    local gift = ""

    if event_type == "chat" then
        message = data.comment or ""
    elseif event_type == "gift" then
        gift = data.giftName or "Gift"
    elseif event_type == "like" then
        message = "Sent Likes"
    elseif event_type == "follow" then
        message = "Followed!"
    elseif event_type == "share" then
        message = "Shared the stream!"
    elseif event_type == "subscribe" then
        message = "Subscribed!"
    elseif event_type == "roomUser" then
        message = "Joined the room!"
    else
        util.log("[Tikfinity Bridge] Unrecognized event: " .. event_type)
    end

    handle_event(event_type, name, message, gift)
end

----------------------------------------
-- 4) POLLING LOOP
----------------------------------------
function start_poll_loop()
    util.create_thread(function()
        while polling do
            util.yield(2000)  -- poll every 2 seconds, adjust as needed

            async_http.init(bridge_host, bridge_path, function(body, header_fields, status_code)
                -- Expecting JSON like:
                -- {"events":["{ \"event\": \"chat\", \"data\":{...}}", ...]}
                if status_code == 200 and #body > 0 then
                    local ok, parsed = pcall(json.decode, body)
                    if ok and type(parsed) == "table" and type(parsed.events) == "table" then
                        for _, raw_json in ipairs(parsed.events) do
                            parse_tiktok_event(raw_json)
                        end
                    end
                else
                    -- Could log or handle if needed
                    util.log("[Tikfinity Bridge] HTTP GET /events status="..tostring(status_code))
                end
            end)
            -- optional, if needed: async_http.set_default_headers(...)
            async_http.dispatch()
        end
    end)
end

----------------------------------------
-- 5) TEST ACTIONS (Simulate Events)
----------------------------------------
menu.action(
    menu.my_root(),
    "Simulate Chat Event",
    {"tikfinity_testchat"},
    "",
    function()
        local fake_json = [[
        {
            "event": "chat",
            "data": {
                "nickname": "TestUser",
                "comment": "Hello from a test!"
            }
        }
        ]]
        parse_tiktok_event(fake_json)
    end
)

menu.action(
    menu.my_root(),
    "Simulate Gift Event",
    {"tikfinity_testgift"},
    "",
    function()
        local fake_json = [[
        {
            "event": "gift",
            "data": {
                "nickname": "SomeDonor",
                "giftName": "Ice Cream"
            }
        }
        ]]
        parse_tiktok_event(fake_json)
    end
)
