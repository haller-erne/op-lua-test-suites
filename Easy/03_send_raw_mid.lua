-- 03_send_raw_mid.lua
-- Demonstrates sending a raw ASCII MID and reading any response.
-- Difficulty: Easy

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send raw MID string")
    session:SendRaw("00200010001     00")

    log:Step("Wait for any response (5s)")
    local resp = session:WaitForRawResponse(5000)
    log:Info("Response MID: " .. resp.mid)
    log:Info("Response body: " .. (resp.body or ""))

    if resp.mid == 5 then
        log:Info("Command accepted (MID 0005)")
    elseif resp.mid == 4 then
        log:Warn("Command error (MID 0004)")
    else
        log:Info("Received MID " .. resp.mid)
    end

    log:Step("Disconnect")
    session:Disconnect()
end
