local InputManager = {}

local lockNum = 0
local Input = Input
local Notifier = Notifier
local cmdName = cmdName


function InputManager.AddLock()
	lockNum = lockNum + 1
end

function InputManager.ReleaseLock()
	lockNum = lockNum - 1
	if lockNum < 0 then
		lockNum = 0
	end
end

function InputManager.Update()
	if(Input.GetMouseButtonUp(0)) then
          Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN_UP,Input.mousePosition)
    end
    if Input.GetMouseButtonDown(0) then
      Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN_DOWN,Input.mousePosition)
    end

    if Input.GetMouseButton(0) then
      Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN,Input.mousePosition)
    end
end

UpdateBeat:Add(InputManager.Update)

return InputManager