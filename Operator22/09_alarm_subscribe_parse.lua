-- 09_alarm_subscribe_parse.lua
-- Subscribe to alarms (MID 0070) and parse alarm/status messages.
-- Target: OPERATOR 22 GWK
-- Note: OPERATOR alarms: E000=None, E001=Battery weak, E002=Overload, E003=Overspeed

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to alarms (MID 0070)")
    session:SendMid(70)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Alarm subscribe accepted")

    log:Step("Wait for alarm status (MID 0076 — may be sent once after subscribe)")
    local ok76, status = pcall(function()
        return session:WaitForMid(76, 10000)
    end)

    if ok76 and status then
        log:Info("Alarm status MID 0076 received")
        log:Info("Raw body: " .. (status.body or "(empty)"))
        if status.fields and status.fields.ErrorCode then
            log:Info("Current alarm: " .. status.fields.ErrorCode)
        end

        log:Step("Acknowledge alarm status (MID 0077)")
        session:SendMid(77)
    else
        log:Info("No MID 0076 received (not all firmware versions send it)")
    end

    log:Step("Wait for alarm indication (MID 0071 — 30s timeout)")
    local ok, alarm = pcall(function()
        return session:WaitForMid(71, 30000)
    end)

    if ok and alarm then
        log:Step("Parse alarm fields")
        log:Info("Alarm received!")
        if alarm.fields.ErrorCode then
            local code = alarm.fields.ErrorCode
            log:Info("ErrorCode: " .. code)
            local alarmNames = {
                ["E000"] = "No alarm",
                ["E001"] = "Battery weak",
                ["E002"] = "Overload (>110% capacity)",
                ["E003"] = "Overspeed"
            }
            log:Info("Alarm meaning: " .. (alarmNames[code] or "Unknown"))
        end

        log:Step("Acknowledge alarm (MID 0072)")
        session:SendMid(72)
    else
        log:Info("No alarm within 30s — system is quiet (not an error)")
    end

    log:Step("Unsubscribe alarms (MID 0073)")
    session:SendMid(73)

    log:Step("Disconnect")
    session:Disconnect()
end
