--[[
   Raptor UI Framework
   
   A super easy, simple, and beautiful UI framework for scripts.
   Created by (discord) hekt0r_ / (reddit) Hektor_Gaming / (github) Hekt000r
   
   use this script all you want, credits would be nice but not required
   
   credits to Spynaz for draggable module

]]

--[[
	@Author: Spynaz
	@Description: Enables dragging on GuiObjects. Supports both mouse and touch.
	
	For instructions on how to use this module, go to this link:
	https://devforum.roblox.com/t/simple-module-for-creating-draggable-gui-elements/230678
--]]

local UDim2_new = UDim2.new

local UserInputService = game:GetService("UserInputService")

local DraggableObject 		= {}
DraggableObject.__index 	= DraggableObject

-- Sets up a new draggable object
function DraggableObject.new(Object)
	local self 			= {}
	self.Object			= Object
	self.DragStarted	= nil
	self.DragEnded		= nil
	self.Dragged		= nil
	self.Dragging		= false

	setmetatable(self, DraggableObject)

	return self
end

-- Enables dragging
function DraggableObject:Enable()
	local object			= self.Object
	local dragInput			= nil
	local dragStart			= nil
	local startPos			= nil
	local preparingToDrag	= false

	-- Updates the element
	local function update(input)
		local delta 		= input.Position - dragStart
		local newPosition	= UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		object.Position 	= newPosition

		return newPosition
	end

	self.InputBegan = object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			preparingToDrag = true
			--[[if self.DragStarted then
				self.DragStarted()
			end
			
			dragging	 	= true
			dragStart 		= input.Position
			startPos 		= Element.Position
			--]]

			local connection 
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and (self.Dragging or preparingToDrag) then
					self.Dragging = false
					connection:Disconnect()

					if self.DragEnded and not preparingToDrag then
						self.DragEnded()
					end

					preparingToDrag = false
				end
			end)
		end
	end)

	self.InputChanged = object.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
		if object.Parent == nil then
			self:Disable()
			return
		end

		if preparingToDrag then
			preparingToDrag = false

			if self.DragStarted then
				self.DragStarted()
			end

			self.Dragging	= true
			dragStart 		= input.Position
			startPos 		= object.Position
		end

		if input == dragInput and self.Dragging then
			local newPosition = update(input)

			if self.Dragged then
				self.Dragged(newPosition)
			end
		end
	end)
end

-- Disables dragging
function DraggableObject:Disable()
	self.InputBegan:Disconnect()
	self.InputChanged:Disconnect()
	self.InputChanged2:Disconnect()

	if self.Dragging then
		self.Dragging = false

		if self.DragEnded then
			self.DragEnded()
		end
	end
end



-- ____________________________________________________________________



-- Creating and managing a Window.

Raptor = {}

type Window = {title: string, width: number, height: number, draggable: boolean}

-- Creates a new Raptor Window.
function Raptor.NewWindow(title, width, height, draggable)
	-- Initalize the window
	local window: Window = {}
	window.SGuiObject = Instance.new("ScreenGui")
	window.guiObject = Instance.new("Frame")
	window.isHidden = false

	-- Essential window functions

	-- Destroys the window and removes all children and code connected
	function window:Remove()
		print("Deleting window...")
		window.SGuiObject:ClearAllChildren()
		task.wait(0.1)
		window.SGuiObject:Destroy()

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

	
end

Raptor.NewWindow("Welcome to RaptorUI")