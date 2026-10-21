-- AP1_clean_startup.lua
-- FW261502RC delta: Clean startup behavior after FW upgrade.
-- Change: First boot after upgrade may show "Open Protocol Result Buffer full" until mode switch + format. Second boot must be clean.
-- Acceptance: Connect+Handshake succeeds on clean startup and MID 0064 query works without prior operator mode change.
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

function main()
    log:Step("Connect and handshake on clean startup")
    session:Connect()
    local hs = session:Handshake(10000)
    assert:NotNil(hs, "Handshake should succeed without operator intervention")
    log:Info(string.format("Handshake OK - MID %d revision %s", hs.mid or 0, hs.revision or "?"))

    log:Step("Query last tightening result (MID 0064 id=0) to verify no buffer-full lock")
    local tighteningId = string.format("%010d", 0)
    session:SendMid(64, { TighteningId = tighteningId })

    -- The controller may reply with MID 0065 (result present) or MID 0004
    -- (TighteningIdRequestNotFound when the ring buffer is empty). Both are valid.
    -- WaitForMid now ignores keep-alive MID 9999 internally, so we can poll cleanly.
    local resp, mid = waitForMid65or4(10000)
    assert:NotNil(resp, "Controller did not respond to MID 0064 with MID 0065 or MID 0004")

    log:Info("Response MID: " .. tostring(mid))

    if mid == 65 then
        log:Info("Last result query accepted")
        if resp.fields then
            log:Info("TighteningId: " .. (resp.fields.TighteningId or "N/A"))
            log:Info("TighteningStatus: " .. (resp.fields.TighteningStatus or "N/A"))
        end
    elseif mid == 4 then
        -- Empty ring buffer is a valid state; the delta behavior is that the controller
        -- responds with a defined error (TighteningIdRequestNotFound) rather than being
        -- locked by a buffer-full condition.
        log:Info("MID 0004 received - ring buffer empty (acceptable for clean startup)")
        if resp.fields then
            for k, v in pairs(resp.fields) do
                log:Info("MID0004 field: " .. tostring(k) .. " = " .. tostring(v))
            end
        end
    else
        assert:Fail("Unexpected response MID " .. tostring(mid) .. " to MID 0064 query")
    end

    log:Step("Disconnect cleanly (MID 0003)")
    session:SendMid(3)
    session:Disconnect()
end
