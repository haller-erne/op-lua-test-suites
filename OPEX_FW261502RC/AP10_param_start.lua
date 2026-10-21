-- AP10_param_start.lua
-- FW261502RC delta: New parameter/job start selection options.
-- Change: Parameter start: Restart from beginning / Continue. Job start: Restart from beginning / Restart from selection / Continue.
-- Acceptance: Monitor result IDs to verify continuity vs. restart.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to tightening results")
    session:SendMid(60)
    session:WaitForMid(5, 5000)

    log:Step("Option A: Restart parameter set from beginning")
    log:Break("Start a parameter set, interrupt it, then choose 'Restart from beginning'. Perform tightening and note result ID. Press Continue.")
    local r_a = session:WaitForResult(120000)
    assert:NotNil(r_a, "Should receive result for option A")
    log:Info("Option A TighteningId: " .. (r_a.fields.TighteningId or "N/A"))
    session:SendMid(62)

    log:Step("Option B: Continue parameter set")
    log:Break("Start same parameter set, interrupt it, then choose 'Continue the parameter set'. Perform tightening and note result ID. Press Continue.")
    local r_b = session:WaitForResult(120000)
    assert:NotNil(r_b, "Should receive result for option B")
    log:Info("Option B TighteningId: " .. (r_b.fields.TighteningId or "N/A"))
    session:SendMid(62)

    log:Step("Option C: Restart job from beginning")
    log:Break("Start a job, interrupt it, then choose 'Restart from beginning'. Perform tightening and note result ID. Press Continue.")
    local r_c = session:WaitForResult(120000)
    assert:NotNil(r_c, "Should receive result for option C")
    log:Info("Option C TighteningId: " .. (r_c.fields.TighteningId or "N/A"))
    session:SendMid(62)

    log:Step("Option D: Continue job")
    log:Break("Start same job, interrupt it, then choose 'Continue the job'. Perform tightening and note result ID. Press Continue.")
    local r_d = session:WaitForResult(120000)
    assert:NotNil(r_d, "Should receive result for option D")
    log:Info("Option D TighteningId: " .. (r_d.fields.TighteningId or "N/A"))
    session:SendMid(62)

    log:Step("Unsubscribe and disconnect")
    session:SendMid(63)
    session:SendMid(3)
    session:Disconnect()
end
