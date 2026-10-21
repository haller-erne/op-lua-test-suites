-- 08_time_sync_parse.lua
-- Read controller time (MID 0080/0081) and parse the timestamp fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request controller time (MID 0080)")
    session:SendMid(80)

    log:Step("Wait for time response (MID 0081)")
    local timeResp = session:WaitForMid(81, 5000)
    assert:NotNil(timeResp, "Should receive MID 0081")
    assert:NotNil(timeResp.fields, "MID 0081 should have parsed fields")

    log:Step("Parse time fields")
    log:Info("Raw body: " .. (timeResp.body or "(empty)"))

    if timeResp.fields.Time then
        log:Info("Controller time: " .. timeResp.fields.Time)
        assert:IsTrue(#timeResp.fields.Time > 0, "Time should not be empty")
    else
        log:Warn("Time field not parsed (check revision)")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
