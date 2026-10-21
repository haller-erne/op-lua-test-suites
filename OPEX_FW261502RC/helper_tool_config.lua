-- helper_tool_config.lua
-- Displays key tool configuration from Service Routine 96 Tool Info.
-- Run manually on the tool: sr 96
-- This script just connects and requests MID 0041 for reference.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool info (MID 0040)")
    session:SendMid(40)
    local response = session:WaitForMid(41, 5000)
    assert:NotNil(response, "Should receive MID 0041")

    log:Info("Raw body: [" .. (response.body or "") .. "]")

    if response.fields then
        for k, v in pairs(response.fields) do
            log:Info("ToolInfo " .. tostring(k) .. " = " .. tostring(v))
        end
    end

    log:Info("IMPORTANT: On the tool, run Service Routine 96 (Tool Info) and check:")
    log:Info("  - Is there a parameter set with Mode = 'Job' at position 1?")
    log:Info("  - Does it have sub-steps (Screw 01, Screw 02, ...)?")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
