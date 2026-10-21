-- AP19_buffer_full_0098.lua
-- FW261502RC delta: When "Stop tool if buffer full" is set and buffer is full, error telegram 0098 is sent instead of silent failure.
-- Change: Applies to MID 0043, 0571, 0038, 0573 with "Job auto start after selection".
-- Acceptance: MID 0098 received when buffer-full condition is triggered.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Prepare buffer-full condition")
    log:Break("Ensure the Open Protocol result buffer is full (perform tightenings without reading results, or use tool menu to fill). Press Continue when ready.")

    log:Step("Enable tool (MID 0043) while buffer is full")
    session:SendMid(43, { ToolEnable = "1" })

    log:Step("Wait for error telegram MID 0098")
    local err = session:WaitForMid(98, 10000)
    assert:NotNil(err, "Should receive MID 0098 (Controller internal request timeout) when buffer full")
    log:Info("Received MID 0098 as expected")
    if err.fields and err.fields.ErrorCode then
        log:Info("Error code: " .. err.fields.ErrorCode)
    end

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
