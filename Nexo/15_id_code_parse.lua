-- 15_id_code_parse.lua
-- Set and read VIN/ID code (MID 0050/0051/0054) and parse response.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to VIN (MID 0050)")
    session:SendMid(50)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "VIN subscribe accepted")

    log:Step("Send VIN code (MID 0051)")
    session:SendMid(51, {
        VinNumber = "TEST-VIN-12345678"
    })

    log:Step("Wait for VIN acknowledgement")
    local resp = session:WaitForRawResponse(5000)
    log:Info("Response to VIN set: MID " .. tostring(resp.mid))

    if resp.mid == 5 then
        log:Info("VIN accepted")
    elseif resp.mid == 4 then
        log:Warn("VIN rejected — ErrorCode: " .. (resp.fields.ErrorCode or "?"))
    elseif resp.mid == 52 then
        log:Info("Received VIN data back (MID 0052)")
        if resp.fields.VinNumber then
            log:Info("VIN: " .. resp.fields.VinNumber)
        end
    end

    log:Step("Unsubscribe VIN (MID 0053)")
    session:SendMid(53)

    log:Step("Disconnect")
    session:Disconnect()
end
