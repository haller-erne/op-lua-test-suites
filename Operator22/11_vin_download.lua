-- 11_vin_download.lua
-- Send VIN to controller (MID 0050) and verify acceptance.
-- Target: OPERATOR 22 GWK
-- Note: VIN is used for the current tightening operation.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send VIN to controller (MID 0050)")
    -- MID 0050: header (20) + VIN string (up to 25 chars, space-padded)
    -- Rexroth header: len(4) + MID(4) + rev(3) + noAck(1) + station(2) + spindle(2) + seq(2) + parts(1) + num(1) = 20
    local vin1 = string.format("%-25s", "4711")
    local msg1 = string.format("%04d", 20 + #vin1) .. "0050001         " .. vin1
    session:SendRaw(msg1)
    local resp = session:WaitForMid(5, 5000)
    assert:IsTrue(resp.mid == 5, "VIN download accepted")
    log:Info("VIN '4711' accepted by controller")

    log:Step("Send longer VIN")
    local vin2 = string.format("%-25s", "TEST-VIN-12345678")
    local msg2 = string.format("%04d", 20 + #vin2) .. "0050001         " .. vin2
    session:SendRaw(msg2)
    local resp2 = session:WaitForRawResponse(5000)
    if resp2.mid == 5 then
        log:Info("Longer VIN accepted")
    elseif resp2.mid == 4 then
        log:Warn("VIN rejected: " .. (resp2.fields.ErrorCode or "?"))
    end

    log:Step("Disconnect")
    session:Disconnect()
end
