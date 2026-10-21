-- 01_tightening_result.lua
-- Subscribes to tightening results and validates torque/angle.
-- Difficulty: Medium

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job 1")
    session:SelectJob(1)

    log:Step("Subscribe to tightening results")
    session:StartTightening()

    log:Step("Wait for tightening result (30s timeout)")
    local result = session:WaitForResult(30000)

    log:Step("Validate result")
    assert:TorqueWithin(result, 10.0, 25.0)
    assert:AngleWithin(result, 50.0, 120.0)
    assert:NoAlarm(result)

    local torque = tonumber(result.fields.Torque) or 0
    local angle = tonumber(result.fields.Angle) or 0
    log:Info("Torque: " .. torque .. " Nm")
    log:Info("Angle:  " .. angle .. " deg")

    log:Step("Unsubscribe and disconnect")
    session:StopTightening()
    session:Disconnect()
end
