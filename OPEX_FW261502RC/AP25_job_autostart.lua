-- AP25_job_autostart.lua
-- FW261502RC delta: New config CFG_COMMUNICATION_OP_JOB_AUTO_START.
-- Change: After job selection (MID 0038/0573), tool auto-enables if set to Yes. Default No.
-- Acceptance: Auto-enable behavior matches config setting.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

local function readToolEnabledField(mid40)
    if not mid40 or not mid40.fields then
        return nil
    end

    for _, key in ipairs({ "ToolEnabled", "toolEnabled", "Tool_Enable", "tool_enable" }) do
        local value = mid40.fields[key]
        if value ~= nil then
            return tostring(value)
        end
    end

    return nil
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Test with auto-start = No (default)")
    log:Break("Ensure config CFG_COMMUNICATION_OP_JOB_AUTO_START = No. Press Continue.")
    session:SelectJob(1)
    local r40_off = session:WaitForMid(40, 5000)
    assert:NotNil(r40_off, "Should receive MID 0040")
    local enabledOff = readToolEnabledField(r40_off) or "0"
    log:Info("ToolEnabled after job select (auto=No): " .. enabledOff)
    assert:Equals("0", enabledOff, "Tool should NOT auto-enable when job auto-start = No")

    log:Step("Test with auto-start = Yes")
    log:Break("Set config CFG_COMMUNICATION_OP_JOB_AUTO_START = Yes. Press Continue.")
    session:SelectJob(2)
    local r40_on = session:WaitForMid(40, 5000)
    assert:NotNil(r40_on, "Should receive MID 0040")
    local enabledOn = readToolEnabledField(r40_on) or "0"
    log:Info("ToolEnabled after job select (auto=Yes): " .. enabledOn)
    assert:Equals("1", enabledOn, "Tool should auto-enable when job auto-start = Yes")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
