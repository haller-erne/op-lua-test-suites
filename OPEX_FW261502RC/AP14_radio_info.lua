-- AP14_radio_info.lua
-- FW261502RC delta: Tool info expanded with radio module settings (display-side).
-- Change: Radio module FW version >= 5.10.0.0C106.0 required for full functionality.
-- Acceptance: Radio module status fields present and populated on the tool display;
--             MID 0041 Tool Data still returns only the standard 4 fields.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
-- Note: Radio/WLAN module settings are NOT transmitted via standard Open Protocol MIDs.
--       The operator must verify them on the tool's Information / Tool Info screen.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Log MID 0041 fields (OPI exposes only the 4 standard tool-data fields)")
    local f = r41.fields or {}
    for k, v in pairs(f) do
        log:Info("MID0041 field: " .. tostring(k) .. " = " .. tostring(v))
    end

    log:Info("Raw body: [" .. (r41.body or "") .. "]")
    log:Info("Header revision: " .. tostring(r41.header and r41.header.Revision))

    log:Step("Operator verification on tool display")
    log:Break("On the tool display, open Information / Tool Info and verify:\n" ..
              "1) A radio/WLAN module section is shown.\n" ..
              "2) Radio module FW version is >= 5.10.0.0C106.0.\n" ..
              "Press Continue when verified.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
