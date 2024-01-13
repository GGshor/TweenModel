--[[

	  _   _  ____ _______ _____ _____ ______ 
	 | \ | |/ __ \__   __|_   _/ ____|  ____|
	 |  \| | |  | | | |    | || |    | |__   
	 | . ` | |  | | | |    | || |    |  __|  
	 | |\  | |__| | | |   _| || |____| |____ 
	 |_| \_|\____/  |_|  |_____\_____|______|
                                         
                                         
	If you're reading this, you can just get rid of this module and parent
	the "TweenModel" module to "ReplicatedStorage". This module is only meant for
	developers who require the module like this: "require(6019253834)".
]]

-- Just get types just in case
local Types = require(script:WaitForChild("TweenModel"):WaitForChild("Types"))

-- Setup for asset id require
return require(script:WaitForChild("TweenModel")) :: Types.TweenModelAPI