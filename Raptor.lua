--[[
   Raptor UI Framework
   
   A super easy, simple, and beautiful UI framework for scripts.
   Created by (discord) hekt0r_ / (reddit) Hektor_Gaming
   
   use this script all you want, credits would be nice but not required
   

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

function Raptor.NewWindow(title, width, height, draggable)
	-- Initalize the window
	local newWindow: Window = {}
	newWindow.SGuiObject = Instance.new("ScreenGui")
	newWindow.guiObject = Instance.new("Frame")

	-- Set essential parameters such as size, position, parent, etc.
	newWindow.guiObject.Size = UDim2.new(0, width, 0, height)
	newWindow.guiObject.Position = UDim2.new(0, 50, 0, 50)
	newWindow.SGuiObject.Parent = game.Players.LocalPlayer.PlayerGui
	newWindow.guiObject.Parent = newWindow.SGuiObject
	newWindow.title = title
	newWindow.width = width
	newWindow.height = height
	newWindow.draggable = draggable

	-- Window styling
	
	-- Round the corners of the Frame
	local CornerObject = Instance.new("UICorner")
	CornerObject.CornerRadius = UDim.new(0, 10)
	CornerObject.Parent = newWindow.guiObject
	
	newWindow.guiObject.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	
	-- Make the window draggable
	
	local windowDrag = DraggableObject.new(newWindow.guiObject)
	windowDrag:Enable()
	
	-- Add the top bar (title, and close/minimize buttons)
	
	newWindow.topBarObj = Instance.new("Frame")
	newWindow.topBarObj.Parent = newWindow.guiObject
	newWindow.topBarObj.Size = UDim2.new(0,width,0,48)
	newWindow.topBarObj.BorderColor3 = Color3.fromRGB(100, 100, 100)
	newWindow.topBarObj.BackgroundColor3 = Color3.fromRGB(42,42,42)
	newWindow.topBarObj.BorderSizePixel = 5
	
	-- Round the corners of topbar
	
	local topBarRound = Instance.new("UICorner")
	topBarRound.Parent = newWindow.topBarObj
	
	-- Title of window
	newWindow.titleObject = Instance.new("TextLabel")
	newWindow.titleObject.Parent = newWindow.topBarObj
	
	newWindow.titleObject.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	newWindow.titleObject.BackgroundTransparency = 1.000
	newWindow.titleObject.BorderColor3 = Color3.fromRGB(255, 255,255)
	newWindow.titleObject.BorderSizePixel = 3
	newWindow.titleObject.Size = UDim2.new(0, width, 0, 48)
	newWindow.titleObject.Font = Enum.Font.GothamBold
	newWindow.titleObject.Text = title
	newWindow.titleObject.TextColor3 = Color3.fromRGB(255, 255, 255)
	newWindow.titleObject.TextSize = 26.000
	newWindow.titleObject.TextXAlignment = 0
	newWindow.titleObject.Position = UDim2.new(0,24,0,0)
	
	
	newWindow.closeButtonObj = Instance.new("TextLabel")
	newWindow.closeButtonObj.Parent = newWindow.topBarObj
	newWindow.closeButtonObj.BackgroundTransparency = 1.000
	newWindow.closeButtonObj.BorderColor3 = Color3.fromRGB(255, 255, 255)
	newWindow.closeButtonObj.BorderSizePixel = 2
	newWindow.closeButtonObj.Size = UDim2.new(0, 48, 0, 48)
	newWindow.closeButtonObj.Font = Enum.Font.GothamBold
	newWindow.closeButtonObj.Text = "X"
	newWindow.closeButtonObj.TextColor3 = Color3.fromRGB(240, 240, 240)
	newWindow.closeButtonObj.Position = UDim2.new(0, width - 48,0,0)
	newWindow.closeButtonObj.TextSize = 36
	
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
		while true do
			task.wait(0.1)
			if isHoveringOverObj(newWindow.closeButtonObj) then
				-- create & play a tween toward red
				TweenService:Create(
					newWindow.closeButtonObj, 
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(240, 75, 75) }
				):Play()
			else
				-- tween back to light gray
				TweenService:Create(
					newWindow.closeButtonObj,
					hoverTweenInfo,
					{ TextColor3 = Color3.fromRGB(240, 240, 240) }
				):Play()
			end
		end
	end)
	
end

Raptor.NewWindow("Welcome to RaptorUI", 600, 400, true)