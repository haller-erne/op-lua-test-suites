-- AP3_wlan.lua
-- FW261502RC delta: WLAN information now included in controller/tool status.
-- Change: Status response contains WLAN FW, WIFI, AP, Socket 1-4 fields.
-- Acceptance: Response contains non-empty WLAN/RF module status fields.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Log WLAN-related fields")
    local f = r41.fields or {}
    local function show(name)
        local v = f[name]
        if v then
            log:Info(name .. ": " .. tostring(v))
        else
            log:Warn(name .. ": not present")
        end
    end
    show("WlanFw")
    show("WifiFw")
    show("AccessPoint")
    show("Socket1Port")
    show("Socket2Port")
    show("Socket3Port")
    show("Socket4Port")
    show("RadioModuleEnabled")

    log:Step("Operator confirmation")
    log:Break("Verify WLAN fields are visible and non-empty on this tool status. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
