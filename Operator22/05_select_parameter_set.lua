-- 05_select_parameter_set.lua
-- Select a parameter set (MID 0018) and verify acceptance.
-- Target: OPERATOR 22 GWK
-- Note: A valid parameter set must be selected before enabling measurement.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select parameter set 1 (MID 0018)")
    session:SendMid(18, { ParameterSetId = "004" })
    local resp = session:WaitForRawResponse(5000)

    if resp.mid == 5 then
        log:Info("Parameter set 1 selected successfully")
    elseif resp.mid == 4 then
        log:Warn("Parameter set selection rejected — ErrorCode: " ..
            (resp.fields.ErrorCode or "?"))
    else
        log:Info("Unexpected response MID: " .. tostring(resp.mid))
    end

    log:Step("Select parameter set 2 (MID 0018)")
    session:SendMid(18, { ParameterSetId = "002" })
    local resp2 = session:WaitForRawResponse(5000)

    if resp2.mid == 5 then
        log:Info("Parameter set 2 selected successfully")
    elseif resp2.mid == 4 then
        log:Info("Parameter set 2 not available (expected on some configs)")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
