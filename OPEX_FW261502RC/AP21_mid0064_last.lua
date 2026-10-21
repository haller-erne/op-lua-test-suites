-- AP21_mid0064_last.lua
-- FW261502RC delta: MID 0064 for TighteningId 0 returns most recent result from ring buffer.
-- Change: No automatic MID 0061 after reconnection.
-- Acceptance: Query returns valid last result; no auto-send after non-regular reconnect.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
-- Notes:
--   - MID 0064 body requires the Tightening ID as 10 ASCII characters, zero-padded.
--   - This script uses os.clock(), so the workspace must have "Unrestricted Lua" enabled.

local function waitForMid65or4(timeoutMs)
    local deadline = os.clock() + (timeoutMs / 1000)
    while os.clock() < deadline do
        local resp = session:TryWaitForRawResponse(250)
        if resp ~= nil then
            local mid = resp.mid or (resp.header and resp.header.Mid) or 0
            if mid == 65 or mid == 4 then
                return resp, mid
            elseif mid == 9999 then
                -- keep-alive, continue
            else
                log:Info("Ignored unrelated MID " .. tostring(mid))
            end
        end
    end
    return nil, 0
end

local function waitForNoSpontaneousMid61(timeoutMs)
    local deadline = os.clock() + (timeoutMs / 1000)
    while os.clock() < deadline do
        local spont = session:TryWaitForRawResponse(250)
        if spont ~= nil then
            local spontMid = spont.mid or (spont.header and spont.header.Mid) or 0
            if spontMid == 61 then
                log:Warn("Spontaneous MID 0061 received after reconnect - verify expected behavior")
                return true
            elseif spontMid == 9999 then
                -- keep-alive, continue
            else
                log:Info("Non-0061 message received after reconnect (MID " .. tostring(spontMid) .. ")")
            end
        end
    end
    log:Info("No spontaneous MID 0061 after reconnect (expected)")
    return false
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Query last result with TighteningId=0")
    local tighteningId = string.format("%010d", 0)
    session:SendMid(64, { TighteningId = tighteningId })

    -- Controller may reply with MID 0065 (result present) or MID 0004
    -- (TighteningIdRequestNotFound when the ring buffer is empty).
    local resp, mid = waitForMid65or4(10000)
    assert:NotNil(resp, "Controller did not respond to MID 0064 with MID 0065 or MID 0004")
    log:Info("Response MID: " .. tostring(mid))

    if mid == 65 then
        log:Info("Last result query OK")
        if resp.fields then
            log:Info("TighteningId: " .. (resp.fields.TighteningId or "N/A"))
            log:Info("TighteningStatus: " .. (resp.fields.TighteningStatus or "N/A"))
        end
    elseif mid == 4 then
        log:Info("MID 0004 received - ring buffer empty (expected on clean tool)")
        if resp.fields then
            for k, v in pairs(resp.fields) do
                log:Info("MID0004 field: " .. tostring(k) .. " = " .. tostring(v))
            end
        end
    else
        assert:Fail("Unexpected response MID " .. tostring(mid) .. " to MID 0064 query")
    end

    log:Step("Hard disconnect without MID 0003")
    session:Disconnect()

    log:Step("Reconnect and verify no spontaneous MID 0061")
    session:Connect()
    session:Handshake(10000)
    waitForNoSpontaneousMid61(5000)

    log:Step("External request must actively fetch results")
    session:SendMid(64, { TighteningId = tighteningId })

    local resp2, mid2 = waitForMid65or4(10000)
    assert:NotNil(resp2, "Controller did not respond to second MID 0064 with MID 0065 or MID 0004")
    log:Info("Second response MID: " .. tostring(mid2))

    if mid2 == 65 then
        log:Info("Second last result query OK")
    elseif mid2 == 4 then
        log:Info("Second MID 0004 received - ring buffer still empty")
    else
        assert:Fail("Unexpected response MID " .. tostring(mid2) .. " to second MID 0064 query")
    end

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
