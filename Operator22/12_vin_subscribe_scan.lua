-- 12_vin_subscribe_scan.lua
-- Subscribe to VIN (MID 0051) and wait for scanned barcode (MID 0052).
-- Target: OPERATOR 22 GWK
-- Note: Requires scanning a barcode on the OPERATOR tool.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to VIN (MID 0051)")
    session:SendMid(51)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "VIN subscribe accepted")
    log:Info("VIN subscription active — scan a barcode on the tool")

    log:Step("Wait for scanned VIN (MID 0052 — 60s timeout)")
    local ok, vin = pcall(function()
        return session:WaitForMid(52, 60000)
    end)

    if ok and vin then
        log:Step("Parse VIN data")
        assert:NotNil(vin.fields, "MID 0052 should have fields")
        if vin.fields.VinNumber then
            log:Info("Scanned VIN: " .. vin.fields.VinNumber)
            assert:IsTrue(#vin.fields.VinNumber > 0, "VIN should not be empty")
        else
            log:Info("VIN from body: " .. (vin.body or ""))
        end

        log:Step("Acknowledge VIN (MID 0053)")
        session:SendMid(53)
    else
        log:Info("No barcode scanned within 60s (not an error)")
    end

    log:Step("Unsubscribe VIN (MID 0054)")
    session:SendMid(54)

    log:Step("Disconnect")
    session:Disconnect()
end
