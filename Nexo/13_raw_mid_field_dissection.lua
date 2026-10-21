-- 13_raw_mid_field_dissection.lua
-- Send a raw MID and manually parse the response body vs OPI-parsed fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send raw MID 0040 (Tool Data Request)")
    session:SendRaw("00200040001     00")

    log:Step("Receive and compare raw vs parsed")
    local resp = session:WaitForRawResponse(10000)
    assert:NotNil(resp, "Should receive a response")

    log:Info("Response MID: " .. tostring(resp.mid))
    log:Info("Response length: " .. tostring(resp.length))
    log:Info("Raw message length: " .. tostring(#(resp.raw or "")))
    log:Info("Body length: " .. tostring(#(resp.body or "")))

    log:Step("Check OPI parsing status")
    if resp.parseError then
        log:Warn("OPI parse error: " .. resp.parseError)
        log:Info("Falling back to raw body analysis")
        log:Info("Body (first 100 chars): " .. string.sub(resp.body or "", 1, 100))
    else
        log:Info("OPI parsed successfully")
    end

    log:Step("Enumerate all parsed fields")
    if resp.fields then
        local count = 0
        for fieldName, fieldValue in pairs(resp.fields) do
            count = count + 1
            log:Info(string.format("  %s = %q", fieldName, tostring(fieldValue)))
        end
        log:Info("Total parsed fields: " .. count)
        assert:IsTrue(count > 0, "Should have at least one parsed field")
    else
        log:Warn("No fields table returned")
    end

    log:Step("Verify header consistency")
    assert:IsTrue(resp.header.Mid == resp.mid, "Header MID should match top-level MID")
    assert:IsTrue(resp.header.Length == resp.length, "Header length should match")

    log:Step("Disconnect")
    session:Disconnect()
end
