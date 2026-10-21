-- 16_header_field_validation.lua
-- Validate that all response headers from the Nexo are well-formed.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Send MID 0040 (Tool Data) and validate header")
    session:SendMid(40)
    local resp = session:WaitForRawResponse(10000)

    log:Step("Validate Rexroth header format (20 bytes)")
    assert:NotNil(resp.header, "Response must have header table")
    assert:IsTrue(resp.header.Length > 0, "Length must be positive")
    assert:IsTrue(resp.header.Mid > 0, "MID must be positive")

    log:Info("Header breakdown:")
    log:Info("  Length: " .. tostring(resp.header.Length))
    log:Info("  MID: " .. tostring(resp.header.Mid))
    log:Info("  Revision: " .. tostring(resp.header.Revision))
    log:Info("  NoAckFlag: " .. tostring(resp.header.NoAckFlag))
    log:Info("  Station: " .. tostring(resp.header.Station))
    log:Info("  Spindle: " .. tostring(resp.header.Spindle))
    log:Info("  Sequence: " .. tostring(resp.header.Sequence))
    log:Info("  PartCount: " .. tostring(resp.header.PartCount))
    log:Info("  PartNumber: " .. tostring(resp.header.PartNumber))

    log:Step("Validate raw message matches header length")
    local rawLen = #(resp.raw or "")
    log:Info("Raw message bytes: " .. rawLen)
    -- Header says total length, raw should be close (NUL delimiter not counted in some impls)
    local hdrLen = resp.header.Length
    assert:IsTrue(rawLen >= hdrLen - 1 and rawLen <= hdrLen + 1,
        string.format("Raw length %d should roughly match header length %d",
            rawLen, hdrLen))

    log:Step("Validate sequence number is reasonable")
    local seq = tonumber(resp.header.Sequence) or 0
    assert:IsTrue(seq >= 0 and seq <= 99,
        "Sequence number should be 0-99, got " .. tostring(seq))

    log:Step("Disconnect")
    session:Disconnect()
end
