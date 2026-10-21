-- 08_tightening_torque_validation.lua
-- Validate torque limits from tightening result.
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select parameter set and enable tool")
    session:SendMid(18, { ParameterSetId = "004" })
    session:WaitForMid(5, 5000)
    session:SendMid(43)
    session:WaitForMid(5, 5000)
    log:Info("PSet 4 selected, tool enabled")

    log:Step("Subscribe to tightening results (MID 0060)")
    session:SendMid(60)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Tightening subscribe accepted")

    log:Step("Wait for result (trigger tightening on OPERATOR)")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")

    log:Step("Validate torque within limits")
    -- OPERATOR 22 torque range: 0–100 Nm (adjust per tool)
    assert:TorqueWithin(result, 0.0, 100.0)
    local torque = tonumber(result.fields.Torque)
    log:Info(string.format("Torque: %.3f Nm", torque))

    log:Step("Check torque limits from result")
    local torqueMin = tonumber(result.fields.TorqueMinLimit)
    local torqueMax = tonumber(result.fields.TorqueMaxLimit)
    if torqueMin and torqueMax then
        log:Info(string.format("Torque limits: [%.3f, %.3f]", torqueMin, torqueMax))
        if result.fields.TighteningStatus == "1" then
            assert:IsTrue(torque >= torqueMin and torque <= torqueMax,
                string.format("OK torque %.3f should be within [%.3f, %.3f]",
                    torque, torqueMin, torqueMax))
            log:Info("Torque within limits: PASS")
        else
            log:Info("Tightening NOK — torque may be outside limits")
        end
    else
        log:Warn("Torque limit fields not available (Rev 1 may not include them)")
    end

    log:Step("Cleanup")
    session:SendMid(62)  -- acknowledge
    session:SendMid(63)  -- unsubscribe
    session:Disconnect()
end
