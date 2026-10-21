-- 03_enable_disable_tool.lua
-- Test tool enable/disable cycle (MID 0042/0043).
-- Target: OPERATOR 22 GWK
-- Note: On OPERATOR 22, MID 0042 = Disable tool, MID 0043 = Enable tool

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select parameter set (required before enable)")
    session:SendMid(18, { ParameterSetId = "004" })
    local psetAck = session:WaitForMid(5, 5000)
    assert:IsTrue(psetAck.mid == 5, "PSet select accepted")

    log:Step("Enable tool (MID 0043)")
    session:SendMid(43)
    local ack1 = session:WaitForMid(5, 5000)
    assert:IsTrue(ack1.mid == 5, "Expected MID 0005 acceptance for enable")
    log:Info("Tool enabled")

    log:Step("Disable tool (MID 0042)")
    session:SendMid(42)
    local ack2 = session:WaitForMid(5, 5000)
    assert:IsTrue(ack2.mid == 5, "Expected MID 0005 acceptance for disable")
    log:Info("Tool disabled")

    log:Step("Re-enable tool (MID 0043)")
    session:SendMid(43)
    local ack3 = session:WaitForMid(5, 5000)
    assert:IsTrue(ack3.mid == 5, "Re-enable accepted")
    log:Info("Tool re-enabled — cycle complete")

    log:Step("Disconnect")
    session:Disconnect()
end
