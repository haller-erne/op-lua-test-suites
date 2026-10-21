-- AP31_mid0573_autostart.lua
-- FW261502RC delta: MID 0573 automatic job start, configurable via console.
-- Change: Without auto-start MID 0573 selects only; with auto-start it selects AND starts.
-- Acceptance: Behavior matches auto-start config.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

local function readJobInCyField(mid40)
    if not mid40 or not mid40.fields then
        return nil
    end

    for _, key in ipairs({ "JobInCy", "jobInCy", "Job_In_Cy", "job_in_cy", "JobInCycle", "jobInCycle" }) do
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

    log:Step("Test with auto-start disabled (default)")
    log:Break("Ensure console config 'Job auto start after selection' = No. Press Continue.")
    session:SendMid(573, { JobId = "1" })
    local r40_off = session:WaitForMid(40, 5000)
    assert:NotNil(r40_off, "Should receive MID 0040 status after MID 0573")
    local inCyOff = readJobInCyField(r40_off) or "0"
    log:Info("JobInCy with auto-start OFF: " .. inCyOff)
    assert:Equals("0", inCyOff, "With auto-start OFF, job should NOT be in cycle")

    log:Step("Test with auto-start enabled")
    log:Break("Enable console config 'Job auto start after selection' = Yes. Press Continue.")
    session:SendMid(573, { JobId = "1" })
    local r40_on = session:WaitForMid(40, 5000)
    assert:NotNil(r40_on, "Should receive MID 0040 status after MID 0573")
    local inCyOn = readJobInCyField(r40_on) or "0"
    log:Info("JobInCy with auto-start ON: " .. inCyOn)
    assert:Equals("1", inCyOn, "With auto-start ON, job should be in cycle immediately")

    log:Step("Test job change during active job")
    log:Break("With auto-start ON and a job active, confirm sending a different JobId via MID 0573 is adopted directly. Press Continue when verified.")
    session:SendMid(573, { JobId = "2" })
    local r40_change = session:WaitForMid(40, 5000)
    assert:NotNil(r40_change, "Should receive MID 0040 status after job change")
    local inCyChange = readJobInCyField(r40_change) or "0"
    log:Info("JobInCy after switching job with auto-start ON: " .. inCyChange)
    assert:Equals("1", inCyChange, "With auto-start ON, switching job should keep job in cycle")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
