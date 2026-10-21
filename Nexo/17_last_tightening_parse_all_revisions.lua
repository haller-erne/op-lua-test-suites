-- 17_last_tightening_parse_all_revisions.lua
-- Request last tightening data directly (MID 0064) and parse fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request last tightening result (MID 0064)")
    session:SendMid(64)

    log:Step("Wait for response")
    local resp = session:WaitForRawResponse(10000)

    if resp.mid == 4 then
        log:Info("MID 0064 not supported or no previous result")
        if resp.fields.ErrorCode then
            log:Info("Error code: " .. resp.fields.ErrorCode)
        end
    elseif resp.mid == 65 then
        log:Step("Parse last tightening data (MID 0065)")
        assert:NotNil(resp.fields, "Should have parsed fields")

        -- Core result fields
        log:Info("=== Last Tightening Result ===")
        log:Info("Torque: " .. (resp.fields.Torque or "N/A"))
        log:Info("Angle: " .. (resp.fields.Angle or "N/A"))
        log:Info("TighteningStatus: " .. (resp.fields.TighteningStatus or "N/A"))
        log:Info("TorqueStatus: " .. (resp.fields.TorqueStatus or "N/A"))
        log:Info("AngleStatus: " .. (resp.fields.AngleStatus or "N/A"))

        -- Context fields
        log:Info("JobId: " .. (resp.fields.JobId or "N/A"))
        log:Info("ParameterSetId: " .. (resp.fields.ParameterSetId or "N/A"))
        log:Info("TimeStamp: " .. (resp.fields.TimeStamp or "N/A"))
        log:Info("TighteningId: " .. (resp.fields.TighteningId or "N/A"))

        -- Strategy info
        if resp.fields.Strategy then
            log:Info("Strategy: " .. resp.fields.Strategy)
        end
        if resp.fields.StrategyOptions then
            log:Info("StrategyOptions: " .. resp.fields.StrategyOptions)
        end
    else
        log:Info("Unexpected response MID: " .. tostring(resp.mid))
        log:Info("Body: " .. (resp.body or "(empty)"))
    end

    log:Step("Disconnect")
    session:Disconnect()
end
