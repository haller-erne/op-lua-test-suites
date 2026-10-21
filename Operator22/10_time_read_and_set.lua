-- 10_time_read_and_set.lua
-- Read controller time (MID 0080/0081) and set new time (MID 0082).
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request controller time (MID 0080)")
    session:SendMid(80)

    log:Step("Wait for time response (MID 0081)")
    local timeResp = session:WaitForMid(81, 5000)
    assert:NotNil(timeResp, "Should receive MID 0081")
    log:Info("Raw body: " .. (timeResp.body or "(empty)"))

    if timeResp.fields and timeResp.fields.Time then
        log:Info("Controller time: " .. timeResp.fields.Time)
        assert:IsTrue(#timeResp.fields.Time > 0, "Time should not be empty")
    else
        log:Info("Time from body: " .. (timeResp.body or ""))
    end

    log:Step("Set controller time (MID 0082)")
    -- Format: YYYY-MM-DD:HH:MM:SS
    local newTime = os.date("!%Y-%m-%d:%H:%M:%S")
    log:Info("Setting time to: " .. newTime)
    session:SendRaw("0039008200100000    " .. newTime)

    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Time set accepted")
    log:Info("Time set confirmed")

    log:Step("Disconnect")
    session:Disconnect()
end
