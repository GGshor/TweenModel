--[[
    Initiliazes the module for client
]]

-- Get reference
local MainModuleReference = script:WaitForChild("MainModuleReference") :: ObjectValue

-- Initiliaze client
require(MainModuleReference.Value)

-- Destroy the script
script:Destroy()
