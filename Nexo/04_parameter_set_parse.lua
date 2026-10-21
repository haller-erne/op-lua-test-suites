-- 04_parameter_set_parse.lua
-- Request parameter set data (MID 0010/0012) and parse response fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to parameter set data (MID 0010)")
    session:SendMid(10)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Expected MID 0005 acceptance")

    log:Step("Wait for parameter set data (MID 0012)")
    local pset = session:WaitForMid(12, 10000)
    assert:NotNil(pset, "Should receive MID 0012")
    assert:NotNil(pset.fields, "MID 0012 should have parsed fields")

    log:Step("Parse parameter set fields")
    log:Info("Raw body: " .. (pset.body or "(empty)"))

    if pset.fields.ParameterSetId then
        log:Info("ParameterSetId: " .. pset.fields.ParameterSetId)
    end
    if pset.fields.ParameterSetName then
        log:Info("ParameterSetName: " .. pset.fields.ParameterSetName)
    end
    if pset.fields.BatchSize then
        log:Info("BatchSize: " .. pset.fields.BatchSize)
    end
    if pset.fields.MinTorque then
        log:Info("MinTorque: " .. pset.fields.MinTorque)
    end
    if pset.fields.MaxTorque then
        log:Info("MaxTorque: " .. pset.fields.MaxTorque)
    end
    if pset.fields.FinalTorqueTarget then
        log:Info("FinalTorqueTarget: " .. pset.fields.FinalTorqueTarget)
    end
    if pset.fields.MinAngle then
        log:Info("MinAngle: " .. pset.fields.MinAngle)
    end
    if pset.fields.MaxAngle then
        log:Info("MaxAngle: " .. pset.fields.MaxAngle)
    end
    if pset.fields.FinalAngleTarget then
        log:Info("FinalAngleTarget: " .. pset.fields.FinalAngleTarget)
    end

    log:Step("Unsubscribe (MID 0011)")
    session:SendMid(11)

    log:Step("Disconnect")
    session:Disconnect()
end
