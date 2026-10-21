-- 20_full_workflow.lua
-- End-to-end workflow: handshake → tool data → select pset → enable →
-- tighten → parse result → disable → disconnect.
-- Target: OPERATOR 22 GWK

function main()
    log:Step("1. Connect and handshake")
    session:Connect()
    local reply = session:Handshake(10000)
    assert:IsTrue(reply.mid == 2, "Handshake should return MID 0002")
    log:Info("Connected, protocol version: " .. (reply.fields.OpenProtocolVersion or "?"))

    log:Step("2. Request tool data (MID 0040)")
    session:SendMid(40)
    local tool = session:WaitForMid(41, 5000)
    assert:NotNil(tool, "Should receive MID 0041")
    log:Info("Tool serial: " .. (tool.fields.ToolSerialNumber or "N/A"))

    log:Step("3. Select parameter set 1 (MID 0018)")
    session:SendMid(18, { ParameterSetId = "004" })
    local psetAck = session:WaitForMid(5, 5000)
    assert:IsTrue(psetAck.mid == 5, "PSet select accepted")
    log:Info("Parameter set 1 selected")

    log:Step("4. Enable tool (MID 0043)")
    session:SendMid(43)
    local enableAck = session:WaitForMid(5, 5000)
    assert:IsTrue(enableAck.mid == 5, "Tool enable accepted")
    log:Info("Tool enabled")

    log:Step("5. Subscribe to tightening results (MID 0060)")
    session:SendMid(60)
    local subAck = session:WaitForMid(5, 5000)
    assert:IsTrue(subAck.mid == 5, "Tightening subscribe accepted")

    log:Step("6. Wait for tightening (trigger on OPERATOR tool)")
    log:Info("Trigger a tightening now...")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")

    log:Step("7. Parse and validate result")
    log:Info("TighteningStatus: " .. (result.fields.TighteningStatus or "?"))
    log:Info("Torque: " .. (result.fields.Torque or "?"))
    log:Info("Angle: " .. (result.fields.Angle or "?"))
    log:Info("ParameterSetId: " .. (result.fields.ParameterSetId or "?"))

    -- Acknowledge result
    session:SendMid(62)
    log:Info("Result acknowledged")

    log:Step("8. Unsubscribe tightening (MID 0063)")
    session:SendMid(63)

    log:Step("9. Disable tool (MID 0042)")
    session:SendMid(42)
    local disableAck = session:WaitForMid(5, 5000)
    assert:IsTrue(disableAck.mid == 5, "Tool disable accepted")
    log:Info("Tool disabled")

    log:Step("10. Communication stop (MID 0003)")
    session:SendMid(3)
    log:Info("Communication stopped")

    log:Step("11. Disconnect")
    session:Disconnect()
    log:Info("=== Full workflow COMPLETE ===")
end
