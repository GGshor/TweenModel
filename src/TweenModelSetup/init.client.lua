--[[
    Initiliazes the module for client
]]

-- Get reference
local MainModuleReference = script:WaitForChild("MainModuleReference") :: ObjectValue

-- Initiliaze client
require(MainModuleReference)

-- Destroy the script
script:Destroy()