-- 02_tightening_result_full_parse.lua
-- Subscribe to tightening and parse all fields from MID 0061.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to tightening results")
    session:StartTightening()

    log:Step("Wait for tightening result (MID 0061)")
    local result = session:WaitForResult(60000)

    log:Step("Validate core result fields")
    assert:NotNil(result.fields, "Result should have parsed fields")
    assert:NotNil(result.fields.Torque, "Should have Torque field")
    assert:NotNil(result.fields.Angle, "Should have Angle field")
    assert:NotNil(result.fields.TighteningStatus, "Should have TighteningStatus")

    log:Step("Parse numeric fields")
    local torque = tonumber(result.fields.Torque)
    local angle = tonumber(result.fields.Angle)
    assert:IsTrue(torque ~= nil, "Torque should be numeric")
    assert:IsTrue(angle ~= nil, "Angle should be numeric")
    log:Info(string.format("Torque: %.3f Nm", torque))
    log:Info(string.format("Angle: %.1f deg", angle))

    log:Step("Parse status fields")
    local status = result.fields.TighteningStatus
    log:Info("TighteningStatus: " .. status .. " (1=OK, 0=NOK)")
    if result.fields.TorqueStatus then
        log:Info("TorqueStatus: " .. result.fields.TorqueStatus)
    end
    if result.fields.AngleStatus then
        log:Info("AngleStatus: " .. result.fields.AngleStatus)
    end

    log:Step("Parse identification fields")
    if result.fields.CellId then log:Info("CellId: " .. result.fields.CellId) end
    if result.fields.ChannelId then log:Info("ChannelId: " .. result.fields.ChannelId) end
    if result.fields.JobId then log:Info("JobId: " .. result.fields.JobId) end
    if result.fields.ParameterSetId then log:Info("ParameterSetId: " .. result.fields.ParameterSetId) end
    if result.fields.BatchSize then log:Info("BatchSize: " .. result.fields.BatchSize) end
    if result.fields.BatchCounter then log:Info("BatchCounter: " .. result.fields.BatchCounter) end

    log:Step("Parse timestamp and serial number")
    if result.fields.TimeStamp then log:Info("TimeStamp: " .. result.fields.TimeStamp) end
    if result.fields.ToolSerialNumber then log:Info("ToolSerialNumber: " .. result.fields.ToolSerialNumber) end
    if result.fields.TighteningId then log:Info("TighteningId: " .. result.fields.TighteningId) end

    log:Step("Unsubscribe and disconnect")
    session:StopTightening()
    session:Disconnect()
end
