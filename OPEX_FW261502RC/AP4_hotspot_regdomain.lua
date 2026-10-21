-- AP4_hotspot_regdomain.lua
-- FW261502RC delta: XPico FW 5.6->5.12 improved regulatory domain handling.
-- Change: Hotspot visibility issues reduced; domain should be EU after factory reset.
-- Acceptance: regulatoryDomain == "EU" and wifiChannel in 1..13.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Inspect regulatory domain and channel")
    local f = r41.fields or {}
    local domain = f.RegulatoryDomain or f.regulatoryDomain or ""
    local channel = f.WifiChannel or f.wifiChannel or ""
    log:Info("RegulatoryDomain: " .. domain)
    log:Info("WifiChannel: " .. channel)

    if domain ~= "" then
        assert:Equals("EU", domain, "Regulatory domain should be EU")
    end
    if channel ~= "" then
        local ch = tonumber(channel)
        assert:NotNil(ch, "WifiChannel should be numeric")
        assert:IsTrue(ch >= 1 and ch <= 13, "WifiChannel must be in EU range 1-13")
    end

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
