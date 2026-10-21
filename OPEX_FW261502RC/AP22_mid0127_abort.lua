-- AP22_mid0127_abort.lua
-- FW261502RC delta: Tool enable signal is removed for ALL variants on Job Abort (MID 0127).
-- Change: Previously variant-dependent.
-- Acceptance: Tool is disabled after MID 0127 for Rexroth variant.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job and enable tool")
    session:SelectJob(1)
    session:SendMid(43, { ToolEnable = "1" })
    session:WaitForMid(5, 5000)

    log:Step("Start job")
    session:SendMid(570)
    session:WaitForMid(5, 5000)

    log:Step("Abort job via MID 0127")
    session:SendMid(127)
    local ack = session:WaitForMid(5, 5000)
    assert:NotNil(ack, "Should receive ACK for MID 0127")

    log:Step("Verify tool is disabled")
    log:Break("Attempt a tightening on the tool and confirm it is rejected/disabled after MID 0127 abort. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
