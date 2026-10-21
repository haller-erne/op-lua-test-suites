-- 13_old_tightening_result.lua
-- Test MID 0064 (stored/orphaned result retrieval).
-- Target: OPERATOR 22 GWK
-- Strategy:
--   1. Subscribe to MID 0060, trigger tightening
--   2. Deliberately do NOT acknowledge (no MID 0062)
--   3. Wait for OPERATOR to either retry or drop connection (~15s)
--   4. Tester presses LEFT button on tool to confirm error and store result
--   5. Reconnect and request stored result via MID 0064

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to tightening results (MID 0060)")
    session:SendMid(18, { ParameterSetId = "004" })
    session:WaitForMid(5, 5000)
    session:SendMid(43)
    session:WaitForMid(5, 5000)
    session:SendMid(60)
    session:WaitForMid(5, 5000)
    log:Info("Subscribed -- DO NOT acknowledge the next result")

    log:Step("Wait for tightening (will NOT acknowledge)")
    log:Info("Trigger a tightening on the OPERATOR 22 now...")
    local result = session:WaitForMid(61, 120000)
    assert:NotNil(result, "Should receive MID 0061")
    local tid = result.fields.TighteningId or "0"
    log:Info("Received TighteningId: " .. tid)
    log:Info("DELIBERATELY not sending MID 0062 -- letting retry loop exhaust")

    log:Step("Wait for OPERATOR reaction (retry or disconnect)")
    log:Info("NOT acknowledging -- waiting up to 30s for retries or disconnect...")
    local retryCount = 0
    local disconnected = false
    -- The OPERATOR may either:
    -- (a) Retry MID 0061 up to 4 times on the same TCP session, OR
    -- (b) Drop the TCP connection after no ACK (firmware-dependent)
    -- EnsureConnected in WaitForRawResponse will auto-reconnect if dropped,
    -- so we detect that by catching the exception pattern.
    for i = 1, 6 do
        local r = session:TryWaitForRawResponse(15000)
        if r == nil then
            log:Info("No more messages (15s timeout) -- retries exhausted")
            break
        end
        if r.mid == 61 then
            retryCount = retryCount + 1
            log:Info("Retry #" .. retryCount .. " received (MID 0061) -- NOT acknowledging")
        elseif r.mid == 9999 then
            -- keep-alive, continue
        elseif r.mid == 1 or r.mid == 2 then
            -- MID 0001/0002 = new handshake after auto-reconnect
            log:Info("Auto-reconnected (got MID " .. tostring(r.mid) .. ") -- OPERATOR dropped us")
            disconnected = true
            break
        else
            log:Info("Received MID " .. tostring(r.mid) .. " during wait")
        end
    end
    log:Info("Retries seen: " .. retryCount .. " | Disconnected: " .. tostring(disconnected))

    log:Step("Press LEFT BUTTON on OPERATOR to store result")
    log:Warn(">>> Press the LEFT button on the OPERATOR 22 tool <<<")
    log:Warn(">>> This confirms the error and stores the result in NV buffer <<<")
    log:Break("Press LEFT button on OPERATOR 22, then click Resume")

    log:Step("Reconnect for MID 0064 retrieval")
    if not disconnected then
        log:Info("Still connected -- sending MID 0003 and disconnecting")
        session:DisconnectWithMid3()
    else
        log:Info("Already disconnected by OPERATOR")
    end
    session:Connect()
    session:Handshake(10000)

    log:Step("Request stored result (MID 0064) with TighteningId=" .. tid)
    local tidPadded = string.format("%010d", tonumber(tid) or 0)
    local msg = string.format("%04d", 20 + #tidPadded) .. "0064001         " .. tidPadded
    session:SendRaw(msg)
    log:Info("Sent MID 0064 with body: " .. tidPadded)

    log:Step("Wait for MID 0065 or error")
    local resp = nil
    for i = 1, 5 do
        local r = session:TryWaitForRawResponse(5000)
        if r == nil then
            break
        end
        if r.mid == 65 or r.mid == 4 then
            resp = r
            break
        elseif r.mid == 5 then
            log:Info("Command accepted (MID 0005) -- waiting for MID 0065...")
        end
    end

    if resp == nil then
        log:Warn("No MID 0065 received -- buffer may be empty or unsupported")
    elseif resp.mid == 65 then
        log:Step("SUCCESS: Retrieved stored result (MID 0065)")
        log:Info("TighteningId: " .. (resp.fields.TighteningId or "N/A"))
        log:Info("Torque: " .. (resp.fields.Torque or "N/A"))
        log:Info("Angle: " .. (resp.fields.Angle or "N/A"))
        log:Info("TighteningStatus: " .. (resp.fields.TighteningStatus or "N/A"))
        log:Info("Timestamp: " .. (resp.fields.Timestamp or "N/A"))
    elseif resp.mid == 4 then
        local errCode = resp.fields.ErrorCode or "N/A"
        if errCode == "TighteningIdRequestNotFound" then
            log:Info("Buffer empty (TighteningIdRequestNotFound)")
            log:Info("OPERATOR may need a longer unack window or doesn't buffer via OP")
        else
            log:Warn("Unexpected error: " .. errCode)
        end
    end

    log:Step("Disconnect")
    session:DisconnectWithMid3()
end
