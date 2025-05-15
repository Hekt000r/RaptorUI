--[[
   Raptor UI Framework
   
   A super easy, simple, and beautiful UI framework for scripts.
   Created by (discord) hekt0r_ / (reddit) Hektor_Gaming / (github) Hekt000r
   
   use this script all you want, credits would be nice but not required
   
   credits to Spynaz for draggable module

]]

--[[
	@Author: Spynaz

	Heavily modified by me (Hekt000r) so the dragging is smooth and a few other changes.

	@Description: Enables dragging on GuiObjects. Supports both mouse and touch.
	
	For instructions on how to use this module, go to this link:
	https://devforum.roblox.com/t/simple-module-for-creating-draggable-gui-elements/230678
--]]

local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UDim2_new       = UDim2.new

local DraggableObject = {}
DraggableObject.__index = DraggableObject

-- Constructor
function DraggableObject.new(Object)
    local self = setmetatable({
        Object       = Object,
        DragStarted  = nil,
        DragEnded    = nil,
        Dragged      = nil,
        Dragging     = false,
        _renderConn  = nil,    -- RunService connection
        _targetPos   = nil,    -- UDim2 goal
    }, DraggableObject)
    return self
end

-- Enable dragging with smooth interpolation
function DraggableObject:Enable()
    local object          = self.Object
    local dragInput       = nil
    local dragStart       = nil
    local startPos        = nil
    local preparingToDrag = false

    -- When the user clicks down
    self._connBegan = object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            preparingToDrag = true

            -- Listen for release to end drag
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                    releaseConn:Disconnect()
                    preparingToDrag = false

                    -- stop the RenderStepped loop
                    if self._renderConn then
                        self._renderConn:Disconnect()
                        self._renderConn = nil
                    end
                    self._targetPos = nil

                    if self.DragEnded then
                        self.DragEnded()
                    end
                end
            end)
        end
    end)

    -- Track which input is the drag
    self._connChangedLocal = object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- Main drag logic
    self._connChangedGlobal = UserInputService.InputChanged:Connect(function(input)
        if object.Parent == nil then
            self:Disable()
            return
        end

        if preparingToDrag then
            preparingToDrag = false
            self.Dragging      = true
            dragStart          = input.Position
            startPos           = object.Position

            if self.DragStarted then
                self.DragStarted()
            end

            -- Begin smooth-follow loop
            self._renderConn = RunService.RenderStepped:Connect(function(dt)
                if self._targetPos then
                    -- dt*12 gives a “stiff” but smooth follow
                    local alpha = math.clamp(dt * 12, 0, 1)
                    object.Position = object.Position:Lerp(self._targetPos, alpha)
                end
            end)
        end

        -- Update the target on each movement
        if self.Dragging and input == dragInput then
            local delta      = input.Position - dragStart
            local desiredPos = UDim2_new(
                startPos.X.Scale,  startPos.X.Offset + delta.X,
                startPos.Y.Scale,  startPos.Y.Offset + delta.Y
            )
            self._targetPos = desiredPos

            if self.Dragged then
                self.Dragged(desiredPos)
            end
        end
    end)
end

-- Disable dragging and clean up
function DraggableObject:Disable()
    if self._connBegan      then self._connBegan:Disconnect()      end
    if self._connChangedLocal  then self._connChangedLocal:Disconnect()  end
    if self._connChangedGlobal then self._connChangedGlobal:Disconnect() end

    if self.Dragging and self.DragEnded then
        self.DragEnded()
    end

    if self._renderConn then
        self._renderConn:Disconnect()
        self._renderConn = nil
    end
    self._targetPos = nil
    self.Dragging   = false
end




-- ____________________________________________________________________



-- Creating and managing a Window.

Raptor = {}

-- Raptor Variables

Raptor.AccentColor = Color3.fromRGB(87, 255, 101)
Raptor.ActiveTabID = 0
Raptor.AvailableTabID = 0
Raptor.CTabOff = 70

-- Getters

function Raptor.GetCurrentTabOffset()
	Raptor.CTabOff = Raptor.CTabOff + 54
	return Raptor.CTabOff - 54
end



-- Helper functions

-- Gets a TextureID that can be used in Image labels/buttons by a name.
function Raptor.GetIconFromName(name)
	if name == "Home" then return "rbxassetid://137149858518531" end
	if name == "Script" then return "rbxassetid://102776318872445" end
	if name == "Settings" then return "rbxassetid://113217690053239" end
	if name == "Info" then return "rbxassetid://138184429776239" end
end

-- Creates a new Raptor Window.
function Raptor.NewWindow(title, width, height, draggable)
	-- Initalize the window
	local window = {}
	window.SGuiObject = Instance.new("ScreenGui")
	window.guiObject = Instance.new("Frame")
	window.isHidden = false
	window.tabs = {}

	-- Essential window functions

	-- Destroys the window and removes all children and code connected
	function window:Remove()
		print("Deleting window...")
		window.SGuiObject:ClearAllChildren()
		task.wait(0.1)
		window.SGuiObject:Destroy()

	end

	--Gets a tab object from its ID
	function window.FindTabByID(id)
    for _, tab in ipairs(window.tabs) do
        if tab.id == id then
            return tab
        end
    end
    -- no match found
    return nil
end


	-- Show the content for a tab through its ID
function window.ShowContentArea(id)
	local TabObj = window.FindTabByID(id)
	TabObj.ContentArea.Visible = true
end

-- Hide the content for a tab through its ID
function window.HideContentArea(id)
	local TabObj = window.FindTabByID(id)
	TabObj.ContentArea.Visible = false
end

	-- Set essential parameters such as size, position, parent, etc.
	width = width or 600
	height = height or 400
	draggable = draggable or true

	window.guiObject.Size = UDim2.new(0, width, 0, height)
	window.guiObject.Position = UDim2.new(0, 50, 0, 50)
	window.SGuiObject.Parent = game.Players.LocalPlayer.PlayerGui
	window.guiObject.Parent = window.SGuiObject
	window.title = title
	window.width = width
	window.height = height
	window.draggable = draggable

	-- Window styling
	
	-- Round the corners of the Frame
	local CornerObject = Instance.new("UICorner")
	CornerObject.CornerRadius = UDim.new(0, 10)
	CornerObject.Parent = window.guiObject
	
	window.guiObject.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	
	-- Make the window draggable
	
	local windowDrag = DraggableObject.new(window.guiObject)
	windowDrag:Enable()
	
	-- Add the top bar (title, and close/minimize buttons)
	
	window.topBarObj = Instance.new("Frame")
	window.topBarObj.Parent = window.guiObject
	window.topBarObj.Size = UDim2.new(0,width,0,48)
	window.topBarObj.BorderColor3 = Color3.fromRGB(100, 100, 100)
	window.topBarObj.BackgroundColor3 = Color3.fromRGB(42,42,42)
	window.topBarObj.BorderSizePixel = 5
	
	-- Round the corners of topbar
	
	local topBarRound = Instance.new("UICorner")
	topBarRound.Parent = window.topBarObj
	
	-- Title of window
	window.titleObject = Instance.new("TextLabel")
	window.titleObject.Parent = window.topBarObj
	
	window.titleObject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	window.titleObject.BackgroundTransparency = 1.000
	window.titleObject.BorderColor3 = Color3.fromRGB(255, 255,255)
	window.titleObject.BorderSizePixel = 3
	window.titleObject.Size = UDim2.new(0, width, 0, 48)
	window.titleObject.Font = Enum.Font.GothamBold
	window.titleObject.Text = title
	window.titleObject.TextColor3 = Color3.fromRGB(255, 255, 255)
	window.titleObject.TextSize = 26.000
	window.titleObject.TextXAlignment = 0
	window.titleObject.Position = UDim2.new(0,24,0,0)
	
	-- close button
	window.closeButtonObj = Instance.new("TextButton")
	window.closeButtonObj.Parent = window.topBarObj
	window.closeButtonObj.BackgroundTransparency = 1.000
	window.closeButtonObj.BorderColor3 = Color3.fromRGB(255, 255, 255)
	window.closeButtonObj.BorderSizePixel = 2
	window.closeButtonObj.Size = UDim2.new(0, 48, 0, 48)
	window.closeButtonObj.Font = Enum.Font.GothamBold
	window.closeButtonObj.Text = "X"
	window.closeButtonObj.TextColor3 = Color3.fromRGB(240, 240, 240)
	window.closeButtonObj.Position = UDim2.new(0, width - 48,0,0)
	window.closeButtonObj.TextSize = 36

	-- minimize button
	window.minimizeButtonObj = Instance.new("TextButton")
	window.minimizeButtonObj.Parent = window.topBarObj
	window.minimizeButtonObj.BackgroundTransparency = 1.000
	window.minimizeButtonObj.BorderColor3 = Color3.fromRGB(255, 255, 255)
	window.minimizeButtonObj.BorderSizePixel = 2
	window.minimizeButtonObj.Size = UDim2.new(0, 48, 0, 48)
	window.minimizeButtonObj.FontFace = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	window.minimizeButtonObj.Text = "-"
	window.minimizeButtonObj.TextColor3 = Color3.fromRGB(240, 240, 240)
	window.minimizeButtonObj.Position = UDim2.new(0, width - 96,0,0)
	window.minimizeButtonObj.TextSize = 48

	
	-- Hovering effects
	
	local mouse = game.Players.LocalPlayer:GetMouse()
	
	local function isHoveringOverObj(obj)
		local tx = obj.AbsolutePosition.X
		local ty = obj.AbsolutePosition.Y
		local bx = tx + obj.AbsoluteSize.X
		local by = ty + obj.AbsoluteSize.Y
		
		if mouse.X >= tx and mouse.Y >= ty and mouse.X <= bx and mouse.Y <= by then
			return true
		end
	end
	
	local TweenService = game:GetService("TweenService")
	local hoverTweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	-- an efficient way to check for mouse over object
	local hoveringThread = task.spawn(function()
		while not window.isHidden == true do
			task.wait(0.1)
			--[[ Close Button ]]
			if isHoveringOverObj(window.closeButtonObj) then
				-- create & play a tween toward red
				TweenService:Create(
					window.closeButtonObj, 
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(240, 75, 75) }
				):Play()
			else
				-- tween back to light gray
				TweenService:Create(
					window.closeButtonObj,
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(240, 240, 240) }
				):Play()
			end
			--[[Minimize Button]]
			if isHoveringOverObj(window.minimizeButtonObj) then
				-- create & play a tween toward red
				TweenService:Create(
					window.minimizeButtonObj, 
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(138, 75, 240) }
				):Play()
			else
				-- tween back to light gray
				TweenService:Create(
					window.minimizeButtonObj,
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(240, 240, 240) }
				):Play()
			end
		end
	end)


	-- Minimizing the GUI
	-- Smoothly fade the background out

	window.minimizeButtonObj.MouseButton1Click:Connect(function()
	-- pretty complicated function, view docs for help.

    window.isHidden = true

    local roots = {
        window.guiObject,   
        window.topBarObj,   
		window.closeButtonObj,
		window.minimizeButtonObj
    }


    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

    local tweens = {}


    for _, root in ipairs(roots) do
        -- Fade the frame’s background
        if root:IsA("GuiObject") then
            local goals = { BackgroundTransparency = 1 }
            local tw = TweenService:Create(root, tweenInfo, goals) 
            tw:Play()
            table.insert(tweens, tw)
        end

        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local goals = { TextTransparency = 1 }
                local tw = TweenService:Create(obj, tweenInfo, goals)  
                tw:Play()
                table.insert(tweens, tw)

            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                local goals = { ImageTransparency = 1 }
                local tw = TweenService:Create(obj, tweenInfo, goals)  
                tw:Play()
                table.insert(tweens, tw)
            end
        end
    end

    for _, tw in ipairs(tweens) do
        tw.Completed:Wait()
    end

    window.SGuiObject.Enabled = false
end)

window.closeButtonObj.MouseButton1Click:Connect(function()
	-- pretty complicated function, view docs for help.
    window.isHidden = true

    local roots = {
        window.guiObject,   
        window.topBarObj,   
		window.closeButtonObj,
		window.minimizeButtonObj
    }


    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

    local tweens = {}


    for _, root in ipairs(roots) do
        -- Fade the frame’s background
        if root:IsA("GuiObject") then
            local goals = { BackgroundTransparency = 1 }
            local tw = TweenService:Create(root, tweenInfo, goals) 
            tw:Play()
            table.insert(tweens, tw)
        end

        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local goals = { TextTransparency = 1 }
                local tw = TweenService:Create(obj, tweenInfo, goals)  
                tw:Play()
                table.insert(tweens, tw)

            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                local goals = { ImageTransparency = 1 }
                local tw = TweenService:Create(obj, tweenInfo, goals)  
                tw:Play()
                table.insert(tweens, tw)
            end
        end
    end

    for _, tw in ipairs(tweens) do
        tw.Completed:Wait()
		window:Remove()
    end
	
end)

	-- Other methods/ functions

	-- "Refreshes" every tab, so that new effects can be applied.
	function window.UpdateTabRendering()
		for _, tab in ipairs(window.tabs)do
			if tab.id == Raptor.ActiveTabID then
			tab.lbl.TextColor3 = Raptor.AccentColor
            tab.ico.ImageColor3 = Raptor.AccentColor
			window.ShowContentArea(tab.id)
            tab.guiObject.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
		else
			tab.lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
            tab.ico.ImageColor3 = Color3.fromRGB(240, 240, 240)
			window.HideContentArea(tab.id)
            tab.guiObject.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
			end
		end

	end

	-- Create a new Raptor "Tab" in the specified window.
	function window:NewTab(title, icon, id)
	
    local tab = {}
	table.insert(window.tabs, tab)
	id = id or (function ()
		Raptor.AvailableTabID = Raptor.AvailableTabID + 1
		print("Automatically assigned tab id for: " .. title .. " is: " .. Raptor.AvailableTabID - 1)
		return Raptor.AvailableTabID - 1
	end)()
	tab.id = id
	icon = icon or "Home"
    -- container
    tab.guiObject = Instance.new("Frame")
    tab.guiObject.Name = "Tab"
    tab.guiObject.Size = UDim2.new(0, window.width/4, 0, 48)
    tab.guiObject.Position = UDim2.new(0, 24, 0, Raptor.GetCurrentTabOffset(id))
    tab.guiObject.BackgroundColor3 = Color3.fromRGB(42,42,42)
    tab.guiObject.Parent = window.guiObject

    -- rounded corners
    local RO = Instance.new("UICorner", tab.guiObject)
    RO.CornerRadius = UDim.new(0, 8)

    -- list layout
    local list = Instance.new("UIListLayout", tab.guiObject)


list.FillDirection        = Enum.FillDirection.Horizontal
list.HorizontalAlignment  = Enum.HorizontalAlignment.Center
list.VerticalAlignment    = Enum.VerticalAlignment.Center   -- ← add this
list.SortOrder            = Enum.SortOrder.LayoutOrder
list.Padding              = UDim.new(0, 8)                   -- gap between icon and text

-- add left padding to list

	local PO = Instance.new("UIPadding", tab.guiObject)
	PO.PaddingLeft = UDim.new(0,8)
    -- icon
    local ico = Instance.new("ImageLabel", tab.guiObject)
    ico.Name               = "Icon"
    ico.Size               = UDim2.fromOffset(24,24)
    ico.LayoutOrder        = 1
    ico.BackgroundTransparency = 1
    ico.Image              = Raptor.GetIconFromName(icon)
	tab.ico = ico
    -- text
    local lbl = Instance.new("TextLabel", tab.guiObject)
    lbl.Name            = "Label"
    lbl.LayoutOrder     = 2
    lbl.BackgroundTransparency = 1
    lbl.Size            = UDim2.new(1, -32, 1, 0)  -- take remaining width
    lbl.Font            = Enum.Font.GothamBold
    lbl.TextSize        = 20
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text            = title
	tab.lbl = lbl 
    tab.title = title
    tab.window = window
	tab.currentComponentIndex = 0
	tab.currentComponentOffset = 12
    tab.componentMargin = 8 -- The vertical distance between components in pixels.

	function tab.CalculateComponentOffset(comp)
		tab.currentComponentOffset = tab.currentComponentOffset + comp.guiObject.AbsoluteSize.Y + tab.componentMargin
        print(tab.currentComponentOffset - comp.guiObject.AbsoluteSize.Y)
        print(comp.guiObject.Parent)
		return tab.currentComponentOffset - comp.guiObject.AbsoluteSize.Y
	end
    function tab.CalculateComponentOffset2(comp)
        print(comp.layout)
		tab.currentComponentOffset = tab.currentComponentOffset + comp.layout.AbsoluteContentSize.Y + tab.componentMargin
        print(tab.currentComponentOffset - comp.layout.AbsoluteContentSize.Y)
        print(comp.guiObject.Parent)
		return tab.currentComponentOffset - comp.layout.AbsoluteContentSize.Y
	end
	function tab.CalculateComponentIndex()
		tab.currentComponentIndex = tab.currentComponentIndex + 1
		return tab.currentComponentIndex - 1
	end


	function tab.CreateContentArea(id)
	local contentF = Instance.new("ScrollingFrame")
contentF.Parent = window.guiObject
contentF.Position = UDim2.new(0,window.width / 3,0,48)
contentF.Size = UDim2.new(0,window.width / 1.60, 0, window.height / 1.2 )
contentF.CanvasSize = UDim2.new(0,window.width / 2, 0, window.height * 2)
contentF.BackgroundColor3 = Color3.fromRGB(255,255,255)
contentF.TopImage = "rbxassetid://16600089027"
contentF.MidImage = "rbxassetid://16600089027"
contentF.BottomImage = "rbxassetid://16600089027"
contentF.BackgroundColor3 = Color3.fromRGB(42,42,42)
contentF.BorderSizePixel = 0
contentF.Visible = false
tab.ContentArea = contentF
tab.ContentAreaID = id
end

tab.CreateContentArea(id)
	window.UpdateTabRendering()
	-- hovering effects

local hoverInfo  = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local normalColor = Color3.fromRGB(42,42,42)
local hoverColor  = Color3.fromRGB(60,60,60)

--[[ DEPRECATED ]]
--Following code is commented out, and not used, although stays here for future reference and in case i need it.
-- MouseEnter: fade to hover
--[[
tab.guiObject.MouseEnter:Connect(function()
    local tween = TweenService:Create(tab.guiObject, hoverInfo, { BackgroundColor3 = hoverColor })
    tween:Play()
end)

-- MouseLeave: fade back (or stay if active)
tab.guiObject.MouseLeave:Connect(function()
    local target = (Raptor.ActiveTabID == id) and hoverColor or normalColor
    local tween  = TweenService:Create(tab.guiObject, hoverInfo, { BackgroundColor3 = target })
    tween:Play()
end)
]]
-- Efficient and extremely precise way to check if mouse is over a tab (yes again, because Roblox doesn't know how to do it themselves.)
local hoverTask2 = task.spawn(function()
	while not window.isHidden == true do
		task.wait(0.1)
		if isHoveringOverObj(tab.guiObject) then
			local tween = TweenService:Create(tab.guiObject, hoverInfo, { BackgroundColor3 = hoverColor })
    		tween:Play()
		else
			  local target = (Raptor.ActiveTabID == id) and hoverColor or normalColor
    local tween  = TweenService:Create(tab.guiObject, hoverInfo, { BackgroundColor3 = target })
    tween:Play()
		end
	end
end)


-- Handle clicking the frame
mouse.Button1Down:Connect(function()
	if isHoveringOverObj(tab.guiObject) then
		Raptor.ActiveTabID = id
		window.UpdateTabRendering()
	end
end)
--[[     COMPONENTS     ]]
-- tab content
tab.components = {}

-- Creates a basic Toggle Component: header row, description row, and a vertically centered toggle
function tab:NewToggleComponent(Ctitle: string, Description: string, defaultValue: boolean)
    -- initialize component data
    local component = {}
    component.index = tab.CalculateComponentIndex()
    component.value = defaultValue
    component.isHidden = false
    table.insert(tab.components, component)

    -- container frame: fixed header (24px) + desc (24px) + padding (16px) total 64px
    component.guiObject = Instance.new("Frame")
    component.guiObject.Parent = tab.ContentArea
    component.guiObject.BackgroundColor3 = Color3.fromRGB(60,60,60)
    component.guiObject.Size = UDim2.new(0.8, 0, 0, 42)
    component.guiObject.Position = UDim2.new(0,24,0,tab.CalculateComponentOffset(component))

    -- header row
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = component.guiObject
    header.Size = UDim2.new(1,0,0,24)
    header.BackgroundTransparency = 1
    -- title centered horizontally
    local title = Instance.new("TextLabel")
    title.Name                 = "Title"
    title.Parent               = header
    title.AnchorPoint          = Vector2.new(0.5, 0.5)
    title.Position             = UDim2.new(0.5,0,0.9,0)
    title.Size                 = UDim2.new(0.9,0,0.9,0)
    title.BackgroundTransparency = 1
    title.Font                 = Enum.Font.GothamBold
    title.TextSize             = 22
    title.Text                 = Ctitle
    title.TextXAlignment       = Enum.TextXAlignment.Left
    title.TextYAlignment       = Enum.TextYAlignment.Top
    title.TextColor3           = Color3.new(240,240,240)


 -- toggle: absolutely positioned, vertically centered
    local toggle = Instance.new("ImageButton")
    toggle.Name        = "ToggleSwitch"
    toggle.Parent      = component.guiObject
    toggle.Image       = "rbxassetid://104414845845962"
	toggle.BackgroundTransparency = 1
    toggle.ImageColor3 = Color3.new(1,1,1)
    toggle.Size        = UDim2.new(0, 33.9, 0, 30)
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position    = UDim2.new(1, -16, 0.5, 0)

    -- corner rounding
    local ro = Instance.new("UICorner")
    ro.Parent = component.guiObject
    ro.CornerRadius = UDim.new(0,10)

    -- hover behavior
    local hoverInfo   = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local normalColor = Color3.fromRGB(60,60,60)
    local hoverColor  = Color3.fromRGB(80,80,80)

	-- "refreshes" the toggle button, so new effects can be applied.
	-- Customize these
local FADE_TIME   = 0.2
local ON_IMAGE    = "rbxassetid://139201960422415"
local OFF_IMAGE   = "rbxassetid://104414845845962"
local ON_COLOR    = Raptor.AccentColor
local OFF_COLOR   = Color3.fromRGB(240, 240, 240)

-- Pre‐make a TweenInfo
local tweenInfo = TweenInfo.new(
    FADE_TIME,               -- Time
    Enum.EasingStyle.Quad,   -- EasingStyle
    Enum.EasingDirection.InOut
)

function component:UpdateToggleRender()
    -- figure out target image & color
    local targetImage = component.value and ON_IMAGE or OFF_IMAGE
    local targetColor = component.value and ON_COLOR or OFF_COLOR

    -- 1) Fade out
    local fadeOut = TweenService:Create(toggle, tweenInfo, { ImageTransparency = 1 })
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        -- 2) swap image & color
        toggle.Image      = targetImage
        toggle.ImageColor3 = targetColor

        -- 3) Fade back in
        local fadeIn = TweenService:Create(toggle, tweenInfo, { ImageTransparency = 0 })
        fadeIn:Play()
    end)
end
	mouse.Button1Down:Connect(function()
		if isHoveringOverObj(component.guiObject) then
			component.value = not component.value
			component:UpdateToggleRender()
		end
	end)




    task.spawn(function()
        while not window.isHidden and not component.isHidden do
            task.wait(0.1)
            if isHoveringOverObj(component.guiObject) then
                TweenService:Create(component.guiObject, hoverInfo, { BackgroundColor3 = hoverColor }):Play()
            else
                TweenService:Create(component.guiObject, hoverInfo, { BackgroundColor3 = normalColor }):Play()
            end
        end
    end)
end

-- Creates a basic Toggle Component: header row, description row, and a vertically centered toggle
function tab:NewCheckboxComponent(Ctitle: string, Description: string, defaultValue: boolean)
    -- initialize component data
    local component = {}
    component.index = tab.CalculateComponentIndex()
    component.value = defaultValue
    component.isHidden = false
    table.insert(tab.components, component)

    -- container frame: fixed header (24px) + desc (24px) + padding (16px) total 64px
    component.guiObject = Instance.new("Frame")
    component.guiObject.Parent = tab.ContentArea
    component.guiObject.BackgroundColor3 = Color3.fromRGB(60,60,60)
    component.guiObject.Size = UDim2.new(0.8, 0, 0, 42)
    component.guiObject.Position = UDim2.new(0,24,0,tab.CalculateComponentOffset(component))

    -- header row
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = component.guiObject
    header.Size = UDim2.new(1,0,0,24)
    header.BackgroundTransparency = 1
    -- title centered horizontally
    local title = Instance.new("TextLabel")
    title.Name                 = "Title"
    title.Parent               = header
    title.AnchorPoint          = Vector2.new(0.5, 0.5)
    title.Position             = UDim2.new(0.5,0,0.9,0)
    title.Size                 = UDim2.new(0.9,0,0.9,0)
    title.BackgroundTransparency = 1
    title.Font                 = Enum.Font.GothamBold
    title.TextSize             = 22
    title.Text                 = Ctitle
    title.TextXAlignment       = Enum.TextXAlignment.Left
    title.TextYAlignment       = Enum.TextYAlignment.Top
    title.TextColor3           = Color3.new(240,240,240)



 -- toggle: absolutely positioned, vertically centered
    local toggle = Instance.new("ImageButton")
    toggle.Name        = "ToggleSwitch"
    toggle.Parent      = component.guiObject
    toggle.Image       = "rbxassetid://107586994656693"
	toggle.BackgroundTransparency = 1
    toggle.ImageColor3 = Color3.new(1,1,1)
    toggle.Size        = UDim2.new(0, 22, 0, 25)
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position    = UDim2.new(1, -16, 0.5, 0)

    -- corner rounding
    local ro = Instance.new("UICorner")
    ro.Parent = component.guiObject
    ro.CornerRadius = UDim.new(0,10)

    -- hover behavior
    local hoverInfo   = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local normalColor = Color3.fromRGB(60,60,60)
    local hoverColor  = Color3.fromRGB(80,80,80)

	-- "refreshes" the toggle button, so new effects can be applied.
	-- Customize these
local FADE_TIME   = 0.2
local ON_IMAGE    = "rbxassetid://135358865064003"
local OFF_IMAGE   = "rbxassetid://107586994656693"
local ON_COLOR    = Raptor.AccentColor
local OFF_COLOR   = Color3.fromRGB(240, 240, 240)

-- Pre‐make a TweenInfo
local tweenInfo = TweenInfo.new(
    FADE_TIME,               -- Time
    Enum.EasingStyle.Quad,   -- EasingStyle
    Enum.EasingDirection.InOut
)

function component:UpdateToggleRender()
    -- figure out target image & color
    local targetImage = component.value and ON_IMAGE or OFF_IMAGE
    local targetColor = component.value and ON_COLOR or OFF_COLOR

    -- 1) Fade out
    local fadeOut = TweenService:Create(toggle, tweenInfo, { ImageTransparency = 1 })
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        -- 2) swap image & color
        toggle.Image      = targetImage
        toggle.ImageColor3 = targetColor

        -- 3) Fade back in
        local fadeIn = TweenService:Create(toggle, tweenInfo, { ImageTransparency = 0 })
        fadeIn:Play()
    end)
end
	mouse.Button1Down:Connect(function()
		if isHoveringOverObj(component.guiObject) then
			component.value = not component.value
			component:UpdateToggleRender()
		end
	end)




    task.spawn(function()
        while not window.isHidden and not component.isHidden do
            task.wait(0.1)
            if isHoveringOverObj(component.guiObject) then
                TweenService:Create(component.guiObject, hoverInfo, { BackgroundColor3 = hoverColor }):Play()
            else
                TweenService:Create(component.guiObject, hoverInfo, { BackgroundColor3 = normalColor }):Play()
            end
        end
    end)
end

-- Creates a new Label component used to display information or text on the screen.
function tab:NewLabelComponent(Ctitle: string, Description: string, defaultValue: boolean)
    -- initialize component data
    local component = {}
    component.index = tab.CalculateComponentIndex()
    component.value = defaultValue
    component.isHidden = false
    table.insert(tab.components, component)

    -- container frame: fixed header (24px) + desc (24px) + padding (16px) total 64px
    component.guiObject = Instance.new("Frame")
    component.guiObject.Parent = tab.ContentArea
    component.guiObject.BackgroundColor3 = Color3.fromRGB(60,60,60)
    component.guiObject.Size = UDim2.new(0.8, 0, 0, 42)
    component.guiObject.Position = UDim2.new(0,24,0,tab.CalculateComponentOffset(component))

    -- header row
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = component.guiObject
    header.Size = UDim2.new(1,0,0,24)
    header.BackgroundTransparency = 1
    -- title centered horizontally
    local title = Instance.new("TextLabel")
    title.Name                 = "Title"
    title.Parent               = header
    title.AnchorPoint          = Vector2.new(0.5, 0.5)
    title.Position             = UDim2.new(0.5,0,0.9,0)
    title.Size                 = UDim2.new(0.9,0,0.9,0)
    title.BackgroundTransparency = 1
    title.Font                 = Enum.Font.GothamBold
    title.TextSize             = 22
    title.Text                 = Ctitle
    title.TextXAlignment       = Enum.TextXAlignment.Left
    title.TextYAlignment       = Enum.TextYAlignment.Top
    title.TextColor3           = Color3.new(240,240,240)

    -- corner rounding
    local ro = Instance.new("UICorner")
    ro.Parent = component.guiObject
    ro.CornerRadius = UDim.new(0,10)

end

-- Creates a new Description component used to display information or describe something on the screen.
function tab:NewDescriptionComponent(Description: string, lines: number, defaultValue: boolean)
    -- initialize component data
    local component = {}
    component.index = tab.CalculateComponentIndex()
    component.value = defaultValue
    component.isHidden = false
    table.insert(tab.components, component)

    -- container frame: auto-sized vertically, with 6px margin on all sides
    component.guiObject = Instance.new("Frame")
    component.guiObject.Parent = tab.ContentArea
    component.guiObject.BackgroundColor3 = Color3.fromRGB(60,60,60)
    component.guiObject.ClipsDescendants = false

    -- add padding for margin
    local padding = Instance.new("UIPadding")
    local margin = 8
    padding.Parent = component.guiObject
    padding.PaddingLeft = UDim.new(0, margin)
    padding.PaddingRight = UDim.new(0, margin)
    padding.PaddingTop = UDim.new(0, margin)
    padding.PaddingBottom = UDim.new(0, margin)

    -- layout to stack header & description
    component.layout = Instance.new("UIListLayout")
    component.layout.Parent = component.guiObject
    component.SortOrder = Enum.SortOrder.LayoutOrder
    component.Padding = UDim.new(0, 8)  -- 8px between header & desc


    -- (Optionally add a title or header text here)

    -- description row (LayoutOrder = 2)
    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.Parent = component.guiObject
    desc.LayoutOrder = 2
    desc.Size = UDim2.new(1,0,0,0)        -- full width inside padding, auto height
    desc.BackgroundTransparency = 1
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 16
    desc.Text = Description
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextColor3 = Color3.new(240,240,240)
    desc.TextWrapped = true                -- wrap long text
    desc.AutomaticSize = Enum.AutomaticSize.Y  -- auto-grow height

    -- corner rounding
    local ro = Instance.new("UICorner")
    ro.Parent = component.guiObject
    ro.CornerRadius = UDim.new(0,10)

    print(desc.AbsoluteSize.Y)

    component.guiObject.Size = UDim2.new(0.8, 0, 0, 16 * lines + tab.componentMargin + tab.componentMargin)           -- height will grow
    component.guiObject.Position = UDim2.new(0,24,0,tab.CalculateComponentOffset(component))

end
-- Creates a new Divider component used to seperate components
function tab:NewDividerComponent()
    -- initialize component data
    local component = {}
    component.index = tab.CalculateComponentIndex()
    component.isHidden = false
    table.insert(tab.components, component)

    -- container frame: auto-sized vertically, with 6px margin on all sides
    component.guiObject = Instance.new("Frame")
    component.guiObject.Parent = tab.ContentArea
    component.guiObject.BackgroundColor3 = Color3.fromRGB(60,60,60)
    component.guiObject.ClipsDescendants = false

    -- add padding for margin
    local padding = Instance.new("UIPadding")
    local margin = 8
    padding.Parent = component.guiObject
    padding.PaddingLeft = UDim.new(0, margin)
    padding.PaddingRight = UDim.new(0, margin)
    padding.PaddingTop = UDim.new(0, margin)
    padding.PaddingBottom = UDim.new(0, margin)

    -- layout to stack header & description
    component.layout = Instance.new("UIListLayout")
    component.layout.Parent = component.guiObject
    component.layout.SortOrder = Enum.SortOrder.LayoutOrder
    component.layout.Padding = UDim.new(0, 12)  -- 8px between header & desc


    -- (Optionally add a title or header text here)


    -- corner rounding
    local ro = Instance.new("UICorner")
    ro.Parent = component.guiObject
    ro.CornerRadius = UDim.new(0,10)


    component.guiObject.Size = UDim2.new(0.8, 0, 0, 4)           -- height will grow
    component.guiObject.Position = UDim2.new(0,24,0,tab.CalculateComponentOffset(component))

end


    return tab
end

return window
end



-- Sample Usage code

local Window = Raptor.NewWindow("Welcome to RaptorUI")

local HomeTab = Window:NewTab("Home")
local ScriptsTab = Window:NewTab("Scripts", "Script")
local SettingsTab = Window:NewTab("Settings", "Settings")

local TestToggle = HomeTab:NewToggleComponent("Test", "This is a test toggle.", false)

local PerformanceLabel = ScriptsTab:NewLabelComponent("Performance")
local PerformanceDesc = ScriptsTab:NewDescriptionComponent("These scripts help decrease lag and make gameplay smoother.", 2)
ScriptsTab:NewDividerComponent()

local AntiLag = ScriptsTab:NewToggleComponent("Anti-Lag", "Lowers graphics and removes textures to decrease lag",false)

local DebugModeToggle =HomeTab:NewToggleComponent("Debug-mode", "Enables debug mode", false)

local AntiKick = ScriptsTab:NewCheckboxComponent("Anti-Kick", "Prevents client-side scripts from kicking you.", false)

local DebugModeToggle2 =ScriptsTab:NewToggleComponent("Debug-mode", "Enables debug mode", false)
local AntiLag2 = ScriptsTab:NewToggleComponent("Anti-Lag", "Lowers graphics and removes textures to decrease lag",false)


