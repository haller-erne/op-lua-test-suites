-- AP8_parallel_sockets_pm80.lua
-- FW261502RC delta: Parallel sockets allow OP (4545) and OpexWin (4002) simultaneously via Preset_Mode 80.
-- Change: New feature; counter readings may reset during parallel parameter transfer.
-- Acceptance: presetMode == "80", Socket1=4002, Socket2=4545.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Verify Preset Mode 80 and socket assignment")
    local f = r41.fields or {}
    local preset = f.PresetMode or f.presetMode or ""
    local s1 = f.Socket1Port or f.socket1Port or ""
    local s2 = f.Socket2Port or f.socket2Port or ""
    log:Info("PresetMode: " .. preset)
    log:Info("Socket1Port: " .. s1)
    log:Info("Socket2Port: " .. s2)

    assert:Equals("80", preset, "Preset mode must be 80 for parallel sockets")
    assert:Equals("4002", s1, "Socket 1 should be OpexWin port 4002")
    assert:Equals("4545", s2, "Socket 2 should be Open Protocol port 4545")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
