-- Shared colored chat message system

if SERVER then
    util.AddNetworkString("QualSystem_ColoredChat")
else
    -- Client receives and displays colored message
    net.Receive("QualSystem_ColoredChat", function()
        local message = net.ReadString()
        
        chat.AddText(
            Color(100, 255, 150), "[Qualification System] ",
            Color(255, 255, 255), message
        )
    end)
end

print("[Qualification System] Colored chat system loaded!")
