-- 18_keep_alive.lua
-- Verify keep-alive exchange (MID 9999).
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send keep-alive (MID 9999)")
    session:SendMid(9999)
    log:Info("Keep-alive sent")

    log:Step("Wait for keep-alive response")
    -- Controller may respond with MID 9999 or simply ACK
    local resp = session:WaitForRawResponse(5000)
    log:Info("Response MID: " .. tostring(resp.mid))
    assert:IsTrue(resp.mid == 9999 or resp.mid == 5,
        "Expected MID 9999 or ACK, got " .. tostring(resp.mid))

    log:Step("Send multiple keep-alives (stress test)")
    for i = 1, 5 do
        session:SendMid(9999)
        local r = session:WaitForRawResponse(5000)
        assert:IsTrue(r.mid == 9999 or r.mid == 5, "Keep-alive #" .. i .. " failed")
        log:Info("Keep-alive #" .. i .. " OK")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
