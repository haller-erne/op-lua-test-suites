-- 16_display_text.lua
-- Display text on the OPERATOR tool screen (MID 0111).
-- Target: OPERATOR 22 GWK
-- Note: 4 lines × 25 chars max. Field 01=seconds, 02=confirm mode, 03-06=lines.
-- Rexroth header: len(4) + MID(4) + rev(3) + noAck(1) + station(2) + spindle(2) + seq(2) + msgParts(1) + msgNum(1) = 20

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send display text (MID 0111) — 5 seconds, timer mode")
    -- Fields: 01=duration(4 chars), 02=mode(1 char: 0=timer, 1=confirm)
    -- 03-06=lines (25 chars each, space-padded)
    local line1 = string.format("%-25s", "=== TEST MESSAGE ===")
    local line2 = string.format("%-25s", "OPERATOR 22 GWK")
    local line3 = string.format("%-25s", "Open Protocol Tester")
    local line4 = string.format("%-25s", "Please wait...")
    local body = "0100050200" .. "03" .. line1 .. "04" .. line2 .. "05" .. line3 .. "06" .. line4
    local header = string.format("%04d", 20 + #body) .. "0111001         "
    session:SendRaw(header .. body)
    log:Info("Display text sent (body length=" .. #body .. ", total=" .. (20 + #body) .. ")")

    -- Try to read ACK but don't fail if none comes
    local ok, resp = pcall(function()
        return session:WaitForRawResponse(3000)
    end)
    if ok and resp then
        log:Info("Response MID: " .. tostring(resp.mid))
    else
        log:Info("No ACK received (expected for some firmware)")
    end

    log:Step("Send confirm-mode message (operator must press button)")
    local line1b = string.format("%-25s", "CONFIRM REQUIRED")
    local line2b = string.format("%-25s", "Press trigger button")
    local line3b = string.format("%-25s", "to continue")
    local line4b = string.format("%-25s", "")
    local body2 = "0100100201" .. "03" .. line1b .. "04" .. line2b .. "05" .. line3b .. "06" .. line4b
    local header2 = string.format("%04d", 20 + #body2) .. "0111001         "
    session:SendRaw(header2 .. body2)
    log:Info("Confirm message sent")

    log:Step("Disconnect")
    session:Disconnect()
end
