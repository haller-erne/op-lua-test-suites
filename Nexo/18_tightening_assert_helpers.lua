-- 18_tightening_assert_helpers.lua
-- Demonstrate all assert helpers for tightening validation.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe and wait for result")
    session:StartTightening()
    local result = session:WaitForResult(120000)

    log:Step("assert:TorqueWithin - validate torque range")
    -- Nexo typical torque range depends on the program
    assert:TorqueWithin(result, 0.0, 999.0)
    local torque = tonumber(result.fields.Torque)
    log:Info(string.format("Torque %.3f Nm is within [0, 999]", torque))

    log:Step("assert:AngleWithin - validate angle range")
    assert:AngleWithin(result, 0.0, 9999.0)
    local angle = tonumber(result.fields.Angle)
    log:Info(string.format("Angle %.1f deg is within [0, 9999]", angle))

    log:Step("assert:NoAlarm - verify no error code")
    assert:NoAlarm(result)
    log:Info("No alarm present in result")

    log:Step("assert:MidFieldEquals - exact field match")
    -- TighteningStatus should be "0" or "1"
    local status = result.fields.TighteningStatus
    assert:IsTrue(status == "0" or status == "1",
        "TighteningStatus should be 0 or 1, got: " .. tostring(status))
    log:Info("TighteningStatus = " .. status)

    log:Step("assert:NotNil - verify fields exist")
    assert:NotNil(result.fields.Torque, "Torque field must exist")
    assert:NotNil(result.fields.Angle, "Angle field must exist")
    assert:NotNil(result.fields.TighteningStatus, "TighteningStatus must exist")
    log:Info("All critical fields present")

    log:Step("Cleanup")
    session:StopTightening()
    session:Disconnect()
end
