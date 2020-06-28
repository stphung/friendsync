-- Todo
-- Minimap Button
-- Refactor(files/methods)

local maxFriends = 50;
local sync;

FS_Name = "FriendSync++";
FS_Version = "0.7";

--//////////////////////////////////////////////////////////////////////////////
-- event.lua
-- Dependencies: util.lua, form.lua
--------------------------------------------------------------------------------
--
-- Synchronizes or Appends to the friends list.
-- Return: void
--
function onLoad()
	print(FS_Name .. " " .. FS_Version .. " " .. LOADED .. ".  " .. TO_DISPLAY_AVAILABLE_OPTIONS_USE .. " /fs|fspp");
    addSlashCommands();
end
--------------------------------------------------------------------------------
--
-- The slash command handler for this addon.
-- Return: void
--
function slashCommandHandler(msg)
    if (msg=="") then
        print("/fs|fspp <arg>");
        print(ARGUMENTS_INCLUDE .. ": show, hide, version"); 
    elseif ( msg=="show" ) then
        showMain();
    elseif ( msg=="hide" ) then
        hideMain();
    elseif ( msg=="version" ) then
        print("You are currently using " .. FS_Name .. " " .. FS_Version .. ".");
    end
end
--------------------------------------------------------------------------------
--
-- Adds the slash commands and sets the slash command handler.
-- Return: void
--
function addSlashCommands()
    SlashCmdList["FS"] = slashCommandHandler;
    SLASH_FS1 = "/fs";
    SLASH_FS2 = "/fspp";
end
--// end event.lua
--//////////////////////////////////////////////////////////////////////////////










--//////////////////////////////////////////////////////////////////////////////
-- main.lua
-- Dependencies: util.lua, form.lua
--------------------------------------------------------------------------------
--
-- Synchronizes or Appends to the friends list.
-- Return: void
--
function doApply(sync)
    if sync then
        synchronize();
    else
        append();
    end
end
--------------------------------------------------------------------------------
--
--  Updates the synchronization list.
-- Return: void
--
function updateSynchronization()
    local count = GetNumFriends();
    friends = {};
    print("Updating Synchronization...");
    for i = 1, count do
        local name = GetFriendInfo(i);
        friends[i] = name;
        print("        Added " .. friends[i] .. " to Synchronization.");
    end
    print("Synchronization Update Complete!");
end
--------------------------------------------------------------------------------
--
-- Synchronizes the friends list with the current synchronization list.
-- Return: void
--
function synchronize()
    local syncSize = table.getn(friends);
    print("Synchronizing your friends...");
    removeFriends();
    addFriends(syncSize);
    print("Your friends list has been synchronized with the current synchronization.");
end
--------------------------------------------------------------------------------
--
-- Appends the synchronization list to the friends list.
-- Return: void
--
function append()
    local syncSize = table.getn(friends);
    local currentSize = GetNumFriends();
    if maxFriends >= newFriendsFromSync()+currentSize then
        print("Appending your current synchronization your friends...");
        addFriends(syncSize);
        print("The current synchronization has been appended to your friends list.");
    else
        print("Your friends list is too large to append the current synchronization.");    
    end
end
--------------------------------------------------------------------------------
--
-- Displays the current synchronization list.
-- Return: void
--
function displaySynchronization()
    local syncSize = table.getn(friends);
    print("Current Synchronization");
    for i = 1, syncSize do
        print("        " .. friends[i]);
    end
end
--------------------------------------------------------------------------------
--
-- Adds friends from the synchronization to your friends list unless you have that friend already.
-- Return: void
-- Helper for: synchronize()
--
function addFriends(syncSize)
    for i = 1, syncSize do
        if not friendExists(friends[i]) then
            AddFriend(friends[i]);
            print("        Added " .. friends[i] .. " to your friends list.");
        end
    end
end
--------------------------------------------------------------------------------
--
-- Removes friends from your friends list if they are not in your synchronization list.
-- Return: void
-- Helper for: synchronize()
--
function removeFriends()
    print("Removing friends not in synchronization...");
    local currentSize = GetNumFriends();
    for i = 1, currentSize do
        local name = GetFriendInfo(i);
        if not friendExistsInSync(name) then
            RemoveFriend(name);
        end
    end
end
--------------------------------------------------------------------------------
--// end main.lua
--//////////////////////////////////////////////////////////////////////////////










--//////////////////////////////////////////////////////////////////////////////
-- form.lua
-- Dependencies: util.lua, 
--------------------------------------------------------------------------------
--
-- Updates the changes form to display which friends are being added and removed.
-- Return: void
--
function updateChangesForm(isSync)
    local inString = getAdded();
    local outString = getRemoved(isSync);
    
    local label = getglobal("ChangesForm" .. "InLabel" .. "Label");
    label:SetText(inString);
    label = getglobal("ChangesForm" .. "OutLabel" .. "Label");
    label:SetText(outString);
    
    if isSync then 
        DoButton:SetText("Sync");
    else
        DoButton:SetText("Append");
    end
end
--------------------------------------------------------------------------------
--
-- Returns a string representing which friends are being added.
-- Return: String
--
function getAdded()
    local syncSize = table.getn(friends);
    local str = "Friends Added\n";
    for i = 1, syncSize do
        if not friendExists(friends[i]) then
            str = str .. "<- " .. friends[i] .. "\n";
        end
    end
    return str;
end
--------------------------------------------------------------------------------
--
-- Returns a string representing which friends are being removed.
-- Return: string
--
function getRemoved(isSync)
    local currentSize = GetNumFriends();
    local str = "Friends Removed\n";
    for i = 1, currentSize do
        local name = GetFriendInfo(i);
        if  friendExists(name) and not friendExistsInSync(name) and isSync then
            str = str .. name .. " ->" .. "\n";
        end
    end
    return str;
end
--------------------------------------------------------------------------------
--
-- Returns the number of new incoming friends in the synchronization list.
-- Return: int
--
function newFriendsFromSync()
    local newFriends = 0;
    local syncSize = table.getn(friends);
    for i = 1, syncSize do
        if not friendExists(friends[i]) then
            newFriends = newFriends + 1;
        end
    end
    return newFriends;
end
--------------------------------------------------------------------------------
--
-- Hides the main form.
-- Return: void
--
function hideMain()
    MainForm:Hide();
end
--------------------------------------------------------------------------------
--
-- Shows the main form.
-- Return: void
--
function showMain()
    MainForm:Show();
end
--------------------------------------------------------------------------------
--
-- Hides the changes form.
-- Return: void
--
function hideChanges()
    ChangesForm:Hide();
end
--------------------------------------------------------------------------------
--
-- Shows the changes form.
-- Return: void
--
function showChanges()
    ChangesForm:Show();
end
--------------------------------------------------------------------------------
--// end form.lua
--//////////////////////////////////////////////////////////////////////////////










--//////////////////////////////////////////////////////////////////////////////
-- util.lua
-- Dependencies: None
--------------------------------------------------------------------------------
--
-- Returns true if the input name exists in your friends list, false otherwise.
--
function friendExists(arg1)
    local currentSize = GetNumFriends();
    for i = 1, currentSize do
        local name = GetFriendInfo(i);
        if name == arg1 then
            return true;
        end
    end
    return false;
end
--------------------------------------------------------------------------------
--
-- Returns true if the input name exists in your synchronization list, false otherwise.
--
function friendExistsInSync(arg1)
    local syncSize = table.getn(friends);
    for i = 1, syncSize do
        if friends[i] == arg1 then
            return true;
        end
    end
    return false;
end
--------------------------------------------------------------------------------
--
-- Helper output function.
--
function print(arg)
    DEFAULT_CHAT_FRAME:AddMessage(arg);
end
--------------------------------------------------------------------------------
--// end util.lua
--//////////////////////////////////////////////////////////////////////////////