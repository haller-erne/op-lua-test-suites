-- 17_flash_green_led.lua
-- Flash the green LED on the OPERATOR tool (MID 0113).
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Flash green LED (MID 0113)")
    session:SendMid(113)
    local resp = session:WaitForRawResponse(5000)
    if resp.mid == 5 then
        log:Info("Green LED flash command accepted")
    elseif resp.mid == 4 then
        log:Warn("Flash LED rejected: " .. (resp.fields.ErrorCode or "?"))
    end

    log:Step("Disconnect")
    session:Disconnect()
end
