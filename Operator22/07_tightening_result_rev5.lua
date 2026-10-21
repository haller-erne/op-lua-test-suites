-- 07_tightening_result_rev5.lua
-- Subscribe to tightening results (MID 0060) and parse fields.
-- Target: OPERATOR 22 GWK
-- Note: OPERATOR 22 typically returns Rev 1 data. Rev 2+ fields like
-- ToolSerialNumber, ParameterSetName, Strategy are only available in Rev 2+.
-- The OPI property for timestamp is "Timestamp" (lowercase 's').

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
    assert:IsTrue(ack.mid == 5, "Expected MID 0005 acceptance")

    log:Step("Wait for tightening result (trigger on OPERATOR 22)")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")
    assert:NotNil(result.fields, "Result should have parsed fields")

    -- Log which revision we received
    log:Info("MID 0061 revision: " .. tostring(result.revision))

    log:Step("Parse torque/angle values")
    log:Info("Torque: " .. (result.fields.Torque or "N/A"))
    log:Info("Angle: " .. (result.fields.Angle or "N/A"))
    log:Info("TorqueMinLimit: " .. (result.fields.TorqueMinLimit or "N/A"))
    log:Info("TorqueMaxLimit: " .. (result.fields.TorqueMaxLimit or "N/A"))
    log:Info("TorqueFinalTarget: " .. (result.fields.TorqueFinalTarget or "N/A"))
    log:Info("AngleMinLimit: " .. (result.fields.AngleMinLimit or "N/A"))
    log:Info("AngleMaxLimit: " .. (result.fields.AngleMaxLimit or "N/A"))
    log:Info("AngleFinalTarget: " .. (result.fields.AngleFinalTarget or "N/A"))

    log:Step("Parse status fields")
    log:Info("TighteningStatus: " .. (result.fields.TighteningStatus or "N/A"))
    log:Info("TorqueStatus: " .. (result.fields.TorqueStatus or "N/A"))
    log:Info("AngleStatus: " .. (result.fields.AngleStatus or "N/A"))
    log:Info("BatchStatus: " .. (result.fields.BatchStatus or "N/A"))
    log:Info("BatchSize: " .. (result.fields.BatchSize or "N/A"))
    log:Info("BatchCounter: " .. (result.fields.BatchCounter or "N/A"))

    log:Step("Parse identifiers and timestamp")
    log:Info("CellId: " .. (result.fields.CellId or "N/A"))
    log:Info("ChannelId: " .. (result.fields.ChannelId or "N/A"))
    log:Info("TorqueControllerName: " .. (result.fields.TorqueControllerName or "N/A"))
    log:Info("VinNumber: " .. (result.fields.VinNumber or "N/A"))
    log:Info("JobId: " .. (result.fields.JobId or "N/A"))
    log:Info("ParameterSetId: " .. (result.fields.ParameterSetId or "N/A"))
    log:Info("TighteningId: " .. (result.fields.TighteningId or "N/A"))
    -- OPI uses "Timestamp" (lowercase 's'), not "TimeStamp"
    log:Info("Timestamp: " .. (result.fields.Timestamp or "N/A"))
    log:Info("LastChangeInParameterSet: " .. (result.fields.LastChangeInParameterSet or "N/A"))

    log:Step("Parse Rev 2+ fields (may be N/A on OPERATOR 22)")
    log:Info("Strategy: " .. (result.fields.Strategy or "N/A"))
    log:Info("ToolSerialNumber: " .. (result.fields.ToolSerialNumber or "N/A"))
    log:Info("ParameterSetName: " .. (result.fields.ParameterSetName or "N/A"))
    log:Info("TorqueValuesUnit: " .. (result.fields.TorqueValuesUnit or "N/A"))

    log:Step("Acknowledge and unsubscribe")
    session:SendMid(62)
    session:SendMid(63)

    log:Step("Disconnect")
    session:Disconnect()
end
