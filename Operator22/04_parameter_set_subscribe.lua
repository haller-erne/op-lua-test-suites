-- 04_parameter_set_subscribe.lua
-- Subscribe to parameter set data (MID 0010/0012) and parse response.
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request parameter set ID list (MID 0010)")
    session:SendMid(10)
    -- OPERATOR 22 responds with MID 0011 (parameter set ID list)
    local psetList = session:WaitForMid(11, 5000)
    if psetList then
        log:Info("Parameter set IDs received (MID 0011)")
        log:Info("Raw body: " .. (psetList.body or "(empty)"))
        if psetList.fields then
            for name, value in pairs(psetList.fields) do
                log:Info(string.format("  %s = %s", name, tostring(value)))
            end
        end
    else
        log:Warn("No MID 0011 received within timeout")
    end

    log:Step("Request parameter set details (MID 0012 for PSet 1)")
    session:SendMid(12, { ParameterSetId = "004" })
    local pset = session:WaitForMid(13, 5000)
    if pset then
        log:Info("Parameter set details received (MID 0013)")
        log:Info("Raw body: " .. (pset.body or "(empty)"))
        if pset.fields then
            if pset.fields.ParameterSetId then log:Info("ParameterSetId: " .. pset.fields.ParameterSetId) end
            if pset.fields.ParameterSetName then log:Info("ParameterSetName: " .. pset.fields.ParameterSetName) end
            if pset.fields.BatchSize then log:Info("BatchSize: " .. pset.fields.BatchSize) end
            if pset.fields.MinTorque then log:Info("MinTorque: " .. pset.fields.MinTorque) end
            if pset.fields.MaxTorque then log:Info("MaxTorque: " .. pset.fields.MaxTorque) end
            if pset.fields.FinalTorqueTarget then log:Info("FinalTorqueTarget: " .. pset.fields.FinalTorqueTarget) end
        end
    else
        log:Warn("No MID 0013 received within timeout")
    end

    log:Step("Subscribe to parameter set selected (MID 0014)")
    session:SendMid(14)
    local subResp = session:WaitForMid(5, 5000)
    if subResp then
        log:Info("Parameter set change subscription active")

        log:Step("Unsubscribe (MID 0017)")
        session:SendMid(17)
    else
        log:Warn("No ACK for MID 0014 subscribe")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
