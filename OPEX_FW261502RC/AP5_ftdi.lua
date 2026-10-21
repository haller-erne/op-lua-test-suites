-- AP5_ftdi.lua
-- FW261502RC delta: FTDI interface / serial bridge verification.
-- Change: Verify FTDI-related identification and version fields are reported.
-- Acceptance: FTDI fields present and operator confirms USB/serial behavior.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Log FTDI/identification fields")
    local f = r41.fields or {}
    local function show(name)
        local v = f[name]
        log:Info(name .. ": " .. (v or "N/A"))
    end
    show("ToolModel")
    show("ToolSerialNumber")
    show("ControllerSerialNumber")
    show("HardwareRevision")
    show("SoftwareVersion")
    show("FtdiVersion")
    show("UsbVendorId")
    show("UsbProductId")

    log:Step("Operator confirmation")
    log:Break("Verify FTDI/USB connection is stable and tool is recognized. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
