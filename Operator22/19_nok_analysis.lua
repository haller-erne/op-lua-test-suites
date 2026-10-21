-- 19_nok_analysis.lua
-- Analyze NOK tightening failure modes.
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

    log:Step("Wait for result (trigger a tightening on OPERATOR)")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")

    log:Step("Analyze result status")
    local status = result.fields.TighteningStatus
    log:Info("TighteningStatus: " .. (status or "N/A"))

    if status == "0" then
        log:Step("NOK Result — analyze failure mode")
        log:Info("=== NOK ANALYSIS ===")

        local torqueStatus = result.fields.TorqueStatus
        local angleStatus = result.fields.AngleStatus

        if torqueStatus then
            local torqueNames = {
                ["0"] = "Torque LOW (below minimum)",
                ["1"] = "Torque OK",
                ["2"] = "Torque HIGH (above maximum)"
            }
            log:Info("Torque status: " .. (torqueNames[torqueStatus] or "Unknown: " .. torqueStatus))
        end

        if angleStatus then
            local angleNames = {
                ["0"] = "Angle LOW (below minimum)",
                ["1"] = "Angle OK",
                ["2"] = "Angle HIGH (above maximum)"
            }
            log:Info("Angle status: " .. (angleNames[angleStatus] or "Unknown: " .. angleStatus))
        end

        -- Log actual vs expected values
        local torque = result.fields.Torque
        local angle = result.fields.Angle
        local torqueMin = result.fields.TorqueMinLimit
        local torqueMax = result.fields.TorqueMaxLimit
        local angleMin = result.fields.AngleMinLimit
        local angleMax = result.fields.AngleMaxLimit

        if torque then log:Info("Actual torque: " .. torque) end
        if torqueMin and torqueMax then
            log:Info("Torque limits: [" .. torqueMin .. ", " .. torqueMax .. "]")
        end
        if angle then log:Info("Actual angle: " .. angle) end
        if angleMin and angleMax then
            log:Info("Angle limits: [" .. angleMin .. ", " .. angleMax .. "]")
        end
    elseif status == "1" then
        log:Info("Result is OK — no failure to analyze")
        assert:TorqueWithin(result, 0.0, 99999.0)
    else
        log:Warn("Unknown tightening status: " .. (status or "nil"))
    end

    log:Step("Cleanup")
    session:SendMid(62)  -- acknowledge
    session:SendMid(63)  -- unsubscribe
    session:Disconnect()
end
