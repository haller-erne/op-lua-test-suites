-- 19_signal_status_parse.lua
-- Read I/O signal status (MID 0200/0210/0213) and parse digital signals.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to digital input signals (MID 0200)")
    session:SendMid(200)
    local ack = session:WaitForRawResponse(5000)

    if ack.mid == 4 then
        log:Warn("MID 0200 not supported on this Nexo: ErrorCode=" ..
            (ack.fields.ErrorCode or "?"))
    else
        assert:IsTrue(ack.mid == 5, "Expected acceptance, got MID " .. tostring(ack.mid))
        log:Info("Signal subscription active")

        log:Step("Wait for signal status (MID 0211)")
        local ok, sig = pcall(function()
            return session:WaitForMid(211, 10000)
        end)

        if ok and sig then
            log:Step("Parse signal fields")
            assert:NotNil(sig.fields, "Signal data should have fields")
            log:Info("Raw body: " .. string.sub(sig.body or "", 1, 80))

            -- Enumerate signal fields
            for name, value in pairs(sig.fields) do
                log:Info(string.format("  Signal %s = %s", name, value))
            end
        else
            log:Warn("No signal data within 10s")
        end

        log:Step("Unsubscribe signals (MID 0203)")
        session:SendMid(203)
    end

    log:Step("Disconnect")
    session:Disconnect()
end
