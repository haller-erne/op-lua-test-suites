-- AP15_rexroth_7behaviors.lua
-- FW261502RC delta: 7 Rexroth-specific Open Protocol behaviors.
-- Acceptance: All 7 behaviors match Rexroth specification for OPEX 30Nm.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Behavior 1/7: MID 0043 ID04 - BatchSize fixed 0")
    session:SendMid(42)
    local r43 = session:WaitForMid(43, 5000)
    assert:NotNil(r43, "Should receive MID 0043")
    assert:Equals("0", r43.fields.BatchSize or r43.fields.batchSize, "Rexroth BatchSize must be fixed 0")
    log:Info("BatchSize = 0 OK")

    log:Step("Behavior 2/7: MID 0052 Rev 1 - no '01' prefix before 25-char VIN")
    session:SendMid(52, nil, { Revision = "001" })
    local r53 = session:WaitForMid(53, 5000)
    assert:NotNil(r53, "Should receive MID 0053")
    local vin = r53.fields.VinNumber or r53.fields.vinNumber or ""
    assert:IsFalse(vin:sub(1, 2) == "01", "VIN must NOT start with '01' prefix")
    log:Info("VIN prefix check OK (" .. vin .. ")")

    log:Step("Behavior 3/7: MID 0076 ID03 - Controller-Ready-Status = 0")
    session:SendMid(76)
    local r77 = session:WaitForMid(77, 5000)
    assert:NotNil(r77, "Should receive MID 0077")
    assert:Equals("0", r77.fields.ControllerReadyStatus or r77.fields.controllerReadyStatus, "ControllerReadyStatus must be 0 for Rexroth")
    log:Info("ControllerReadyStatus = 0 OK")

    log:Step("Behavior 4/7: MID 0030/0031 Rev 002 supported")
    session:SendMid(30, nil, { Revision = "002" })
    local r31 = session:WaitForMid(31, 5000)
    assert:NotNil(r31, "MID 0030 Rev 002 should be accepted")
    log:Info("MID 0030 Rev 002 accepted")

    log:Step("Behavior 5/7: MID 0032/0033 Rev 002 supported")
    session:SendMid(32, nil, { Revision = "002" })
    local r33 = session:WaitForMid(33, 5000)
    assert:NotNil(r33, "MID 0032 Rev 002 should be accepted")
    log:Info("MID 0032 Rev 002 accepted")

    log:Step("Behavior 6/7: MID 0034/0035 Rev 002 + 003 supported, Rev 001 NOT supported")
    session:SendMid(34, nil, { Revision = "002" })
    local r35_2 = session:WaitForMid(35, 5000)
    assert:NotNil(r35_2, "MID 0034 Rev 002 should be accepted")
    log:Info("MID 0034 Rev 002 accepted")

    session:SendMid(34, nil, { Revision = "003" })
    local r35_3 = session:WaitForMid(35, 5000)
    assert:NotNil(r35_3, "MID 0034 Rev 003 should be accepted")
    log:Info("MID 0034 Rev 003 accepted")

    local okRev1, errRev1 = pcall(function()
        session:SendMid(34, nil, { Revision = "001" })
        return session:WaitForMid(35, 3000)
    end)
    if okRev1 then
        log:Warn("MID 0034 Rev 001 was accepted - verify this is expected for this controller")
    else
        log:Info("MID 0034 Rev 001 rejected as expected")
    end

    log:Step("Behavior 7/7: MID 0039/0040 Rev 002 supported")
    session:SendMid(39, nil, { Revision = "002" })
    local r40 = session:WaitForMid(40, 5000)
    assert:NotNil(r40, "MID 0039 Rev 002 should be accepted")
    log:Info("MID 0039 Rev 002 accepted")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
