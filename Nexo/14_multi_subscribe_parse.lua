-- 14_multi_subscribe_parse.lua
-- Subscribe to multiple data streams and parse each response type.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to tightening results (MID 0060)")
    session:StartTightening()
    log:Info("Tightening subscription active")

    log:Step("Subscribe to alarms (MID 0070)")
    session:SendMid(70)
    local alarmAck = session:WaitForMid(5, 5000)
    assert:IsTrue(alarmAck.mid == 5, "Alarm subscribe accepted")
    log:Info("Alarm subscription active")

    log:Step("Wait for any message (20s)")
    local msg = session:WaitForRawResponse(20000)
    assert:NotNil(msg, "Should receive at least one message")

    log:Step("Identify and parse received message")
    log:Info("Received MID: " .. tostring(msg.mid))

    if msg.mid == 61 then
        log:Info("=== Tightening Result (MID 0061) ===")
        log:Info("Torque: " .. (msg.fields.Torque or "N/A"))
        log:Info("Angle: " .. (msg.fields.Angle or "N/A"))
        log:Info("Status: " .. (msg.fields.TighteningStatus or "N/A"))
    elseif msg.mid == 71 then
        log:Info("=== Alarm (MID 0071) ===")
        log:Info("ErrorCode: " .. (msg.fields.ErrorCode or "N/A"))
        -- Acknowledge
        session:SendMid(72)
    elseif msg.mid == 9999 then
        log:Info("Received keep-alive (MID 9999)")
    else
        log:Info("Received other MID: " .. tostring(msg.mid))
        log:Info("Body: " .. (msg.body or "(empty)"))
    end

    log:Step("Unsubscribe all")
    session:StopTightening()
    session:SendMid(73)  -- Unsubscribe alarms

    log:Step("Disconnect")
    session:Disconnect()
end
