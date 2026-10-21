-- 03_alarm_subscribe.lua
-- Subscribes to alarms and waits for alarm data.
-- Difficulty: Medium

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to alarms (MID 0070)")
    session:SendMid(70)
    local ack = session:WaitForMid(5, 5000)
    assert:Equals(5, ack.mid, "Expected acceptance (MID 0005)")
    log:Info("Alarm subscription active")

    log:Step("Wait for alarm (MID 0071/0074 - 15s timeout)")
    local ok, alarm = pcall(function()
        return session:WaitForMid(74, 15000)
    end)

    if ok then
        log:Info("Alarm received: " .. alarm.body)
        assert:NotNil(alarm.fields, "Alarm should have parseable fields")
    else
        log:Warn("No alarm received within 15s (expected in quiet system)")
    end

    log:Step("Unsubscribe (MID 0073)")
    session:SendMid(73)

    log:Step("Disconnect")
    session:Disconnect()
end
