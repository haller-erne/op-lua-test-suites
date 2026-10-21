-- 09_mid_acceptance_rejection.lua
-- Test MID 0005 (accepted) and MID 0004 (rejected) response parsing.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send valid command — expect MID 0005")
    session:SendMid(10)  -- Subscribe to parameter sets
    local resp = session:WaitForRawResponse(5000)

    if resp.mid == 5 then
        log:Info("Got MID 0005 (Command Accepted)")
        log:Info("Accepted MID field: " .. (resp.fields.MidNumber or resp.body or "N/A"))
        -- Unsubscribe
        session:SendMid(11)
    elseif resp.mid == 4 then
        log:Info("Got MID 0004 (Command Error)")
        if resp.fields.ErrorCode then
            log:Info("ErrorCode: " .. resp.fields.ErrorCode)
        end
    else
        log:Info("Unexpected response MID: " .. tostring(resp.mid))
    end

    log:Step("Send invalid/unsupported command — expect MID 0004")
    -- Send a subscribe that might be rejected (e.g., re-subscribe without unsubscribe)
    session:SendRaw("00200010001     00")  -- MID 0010 raw
    local resp2 = session:WaitForRawResponse(5000)

    log:Step("Parse error response")
    log:Info("Response to duplicate subscribe: MID " .. tostring(resp2.mid))
    if resp2.mid == 4 then
        assert:NotNil(resp2.fields, "MID 0004 should have error fields")
        if resp2.fields.ErrorCode then
            log:Info("Error code: " .. resp2.fields.ErrorCode)
        end
    elseif resp2.mid == 5 then
        log:Info("Controller accepted duplicate subscribe (some do)")
        session:SendMid(11)
    end

    log:Step("Disconnect")
    session:Disconnect()
end
