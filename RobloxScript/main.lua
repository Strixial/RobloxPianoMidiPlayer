local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GreenDeno/Venyx-UI-Library/main/source.lua"))()
local venyx = library.new("MIDI Auto Player")

local MainPage = venyx:addPage("Main")

local LoadFileSect = MainPage:addSection("Load File")

local LoadedFile, PlayNextKey

local KeysDown = {}
local InputService = game:GetService("UserInputService")

local PreHookFunc, ShiftKeyHookActive, CtrlKeyHookActive
-- Maybe in the future I'll implement 88-key mode

PreHookFunc = hookfunction(InputService.IsKeyDown, function(Key)
	local Value
	
	-- Auto convert key into number
	if typeof(Key) == "number" then
		Value = Key
	elseif typeof(Key) == "Enum" then
		Value = Key.Value
	end
	
	
	if ShiftKeyHookActive then
		if Value == 303 or Value == 304 then
			ShiftKeyHookActive = false -- Auto disable shift key
			return true
		else
			return PreHookFunc(Value)
		end
	else
		return PreHookFunc(Value)
	end
end)

function PressKey(key, length)
	-- Spoofs UserInputService.InputBegan to simulate a key press
	
	if key == key:lower() then
		-- Key is lowercase, don't use shift key
		firesignal(InputService.InputBegan, {
			UserInputType = Enum.UserInputType.Keyboard,
			UserInputState = Enum.UserInputState.Begin,
			KeyCode = Enum.KeyCode[string.upper(string.char(key))]
		})
	else
		-- Key is uppercase, use shift key
		ShiftKeyHookActive = true
		firesignal(InputService.InputBegan, {
			UserInputType = Enum.UserInputType.Keyboard,
			UserInputState = Enum.UserInputState.Begin,
			KeyCode = Enum.KeyCode[string.upper(string.char(key))]
		})
	end
end

local function LoadFileIntoTable(file)
	-- Create midi events table
	local MidiTable = {}
	MidiTable.PlaybackSpeed = 1.0
	MidiTable.Tempo = 120.0
	MidiTable.Events = {}

	-- split table based on newlines
	local LinesTable = file:split("\n")

	-- remove first line (just tells us about playback speed)
	MidiTable.PlaybackSpeed = tonumber(LinesTable[1]:sub(1, 15))
	table.remove(LinesTable, 1)

	-- parse rest of table
	for i, v in pairs(LinesTable) do

		local LineTable = v:split(" ")

		if LineTable[2]:match("playback_speed") then

		elseif LineTable[2]:match("tempo") then
			MidiTable.Tempo = tonumber(LineTable[2]:sub(6, #LineTable[2]))
		else
			LineTable[1] = tonumber(LineTable[1])
		end
	end
end

local SongPosition = 0



local CurrentLoadedButton = LoadFileSect:addButton("Currently Loaded: false", function() end)
local LoadFileButton = LoadFileSect:addButton("Load New File", function()
	local success, data = readdialog("Open song data")

	if success then
		LoadedFile = data
		LoadFileSect:updateButton("CurrentLoadedButton", "Currently Loaded: true")
	end
end)

local PlayerSect = MainPage:addSection("Player")

Player:addToggle("Playing", function(toggle)

end)