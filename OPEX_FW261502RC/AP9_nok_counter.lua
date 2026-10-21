-- AP9_nok_counter.lua
-- FW261502RC delta: NOK counter implemented.
-- Change: NOK counter increments only on NOK results; present in MID 0035.
-- Acceptance: Counter unchanged after OK, increments after NOK.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Read initial NOK counter from MID 0035")
    session:SendMid(34)
    local r35_before = session:WaitForMid(35, 5000)
    assert:NotNil(r35_before, "Should receive MID 0035")
    local nokBefore = tonumber(r35_before.fields.JobNokCounter or r35_before.fields.jobNokCounter or "0") or 0
    log:Info("Initial NOK counter: " .. nokBefore)

    log:Step("Subscribe to results and perform OK tightening")
    session:SendMid(60)
    session:WaitForMid(5, 5000)
    log:Break("Perform an OK tightening on the tool, then press Continue.")
    session:SendMid(62)

    log:Step("Read NOK counter after OK tightening")
    session:SendMid(34)
    local r35_after_ok = session:WaitForMid(35, 5000)
    local nokAfterOk = tonumber(r35_after_ok.fields.JobNokCounter or r35_after_ok.fields.jobNokCounter or "0") or 0
    log:Info("NOK counter after OK: " .. nokAfterOk)
    assert:Equals(nokBefore, nokAfterOk, "NOK counter should NOT change after OK tightening")

    log:Step("Perform NOK tightening")
    log:Break("Perform a NOK tightening on the tool, then press Continue.")
    session:SendMid(62)

    log:Step("Read NOK counter after NOK tightening")
    session:SendMid(34)
    local r35_after_nok = session:WaitForMid(35, 5000)
    local nokAfterNok = tonumber(r35_after_nok.fields.JobNokCounter or r35_after_nok.fields.jobNokCounter or "0") or 0
    log:Info("NOK counter after NOK: " .. nokAfterNok)
    assert:Equals(nokAfterOk + 1, nokAfterNok, "NOK counter should increment by 1 after NOK tightening")

    log:Step("Unsubscribe and disconnect")
    session:SendMid(63)
    session:SendMid(3)
    session:Disconnect()
end
