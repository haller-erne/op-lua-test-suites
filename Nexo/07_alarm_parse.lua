-- 07_alarm_parse.lua
-- Subscribe to alarms (MID 0070) and parse alarm data fields (MID 0071).
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to alarms (MID 0070)")
    session:SendMid(70)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Expected MID 0005 acceptance")
    log:Info("Alarm subscription active")

    log:Step("Wait for alarm data (MID 0071 — 30s timeout)")
    local ok, alarm = pcall(function()
        return session:WaitForMid(71, 30000)
    end)

    if ok and alarm then
        log:Step("Parse alarm fields")
        assert:NotNil(alarm.fields, "Alarm should have parsed fields")

        if alarm.fields.ErrorCode then
            log:Info("ErrorCode: " .. alarm.fields.ErrorCode)
        end
        if alarm.fields.ControllerReadyStatus then
            log:Info("ControllerReadyStatus: " .. alarm.fields.ControllerReadyStatus)
        end
        if alarm.fields.ToolReadyStatus then
            log:Info("ToolReadyStatus: " .. alarm.fields.ToolReadyStatus)
        end
        if alarm.fields.Time then
            log:Info("Alarm Time: " .. alarm.fields.Time)
        end

        -- Acknowledge alarm (MID 0072)
        log:Step("Acknowledge alarm (MID 0072)")
        session:SendMid(72)
    else
        log:Step("No alarm received")
        log:Warn("No alarm within 30s — system is quiet (not an error)")
    end

    log:Step("Unsubscribe (MID 0073)")
    session:SendMid(73)

    log:Step("Disconnect")
    session:Disconnect()
end
