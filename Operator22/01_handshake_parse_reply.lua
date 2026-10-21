-- 01_handshake_parse_reply.lua
-- Parse the Communication Start Acknowledge (MID 0002) response.
-- Target: OPERATOR 22 GWK

function main()
    log:Step("Connect to OPERATOR 22")
    session:Connect()

    log:Step("Send MID 0001 and wait for MID 0002")
    session:SendMid(1)
    local resp = session:WaitForMid(2, 10000)

    log:Step("Validate response structure")
    assert:NotNil(resp, "Should receive MID 0002")
    assert:IsTrue(resp.mid == 2, "Response MID should be 2, got " .. tostring(resp.mid))
    assert:NotNil(resp.fields, "MID 0002 should have parsed fields")
    assert:NotNil(resp.header, "Response should have header table")

    log:Step("Parse MID 0002 fields")
    log:Info("Raw body: " .. (resp.body or "(empty)"))
    log:Info("Revision: " .. tostring(resp.revision))

    if resp.fields.CellId then
        log:Info("CellId: " .. resp.fields.CellId)
    end
    if resp.fields.ChannelId then
        log:Info("ChannelId: " .. resp.fields.ChannelId)
    end
    if resp.fields.ControllerName then
        log:Info("ControllerName: " .. resp.fields.ControllerName)
    end

    log:Step("Validate header fields")
    assert:IsTrue(resp.header.Mid == 2, "Header MID should be 2")
    log:Info("Header revision: " .. tostring(resp.header.Revision))
    log:Info("Header length: " .. tostring(resp.header.Length))

    log:Step("Disconnect")
    session:Disconnect()
end
