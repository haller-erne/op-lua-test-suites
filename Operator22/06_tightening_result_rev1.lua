-- 06_tightening_result_rev1.lua
-- Subscribe to tightening results (MID 0060 Rev 1) and parse MID 0061 Rev 1.
-- Target: OPERATOR 22 GWK
-- Note: Rev 1 has 23 fields. CellId="0000", ChannelId="00", JobId="00".

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

    log:Step("Wait for tightening result (trigger on OPERATOR 22)")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")

    log:Step("Validate core fields")
    assert:NotNil(result.fields, "Result should have parsed fields")
    assert:NotNil(result.fields.Torque, "Should have Torque field")
    assert:NotNil(result.fields.TighteningStatus, "Should have TighteningStatus")

    log:Step("Parse result fields")
    local torque = tonumber(result.fields.Torque)
    local angle = tonumber(result.fields.Angle)
    log:Info(string.format("Torque: %s Nm", result.fields.Torque or "N/A"))
    log:Info(string.format("Angle: %s deg", result.fields.Angle or "N/A"))
    log:Info("TighteningStatus: " .. (result.fields.TighteningStatus or "N/A"))
    log:Info("TorqueStatus: " .. (result.fields.TorqueStatus or "N/A"))
    log:Info("AngleStatus: " .. (result.fields.AngleStatus or "N/A"))
    log:Info("BatchStatus: " .. (result.fields.BatchStatus or "N/A"))

    -- OPERATOR-specific: CellId always "0000", JobId always "00"
    if result.fields.CellId then
        log:Info("CellId: " .. result.fields.CellId .. " (expected: 0000)")
    end
    if result.fields.JobId then
        log:Info("JobId: " .. result.fields.JobId .. " (expected: 00)")
    end
    if result.fields.TighteningId then
        log:Info("TighteningId: " .. result.fields.TighteningId)
    end
    if result.fields.TimeStamp then
        log:Info("TimeStamp: " .. result.fields.TimeStamp)
    end

    log:Step("Acknowledge result (MID 0062)")
    session:SendMid(62)

    log:Step("Unsubscribe and disconnect")
    session:SendMid(63)
    session:Disconnect()
end
