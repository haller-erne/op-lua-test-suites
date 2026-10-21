-- AP12_batch_status.lua
-- FW261502RC delta: Batch status meanings changed in MID 0061/0065.
-- New mapping: 0=batch NOK, 1=batch OK, 2=batch not used, 3=batch running.
-- Acceptance: BatchStatus follows the new mapping for a completed OK batch.
-- Tool: OPEX 30Nm (Rexroth variant). PSet 2 must allow Open Protocol batch control.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Abort any running job and drain stale messages")
    session:SendMid(127)
    session:TryWaitForRawResponse(1000)

    -- Drain any leftover messages from previous subscriptions or tightenings.
    local drained = session:TryWaitForRawResponse(500)
    while drained do
        log:Info("Drained stale message (MID " .. drained.mid .. ")")
        drained = session:TryWaitForRawResponse(500)
    end

    log:Step("Select parameter set 2, reset batch counter, set batch size to 3")
    session:SendMid(18, { ParameterSetId = "002" })
    session:WaitForMid(5, 5000)

    session:SendMid(20, { "002" })
    session:WaitForMid(5, 5000)

    session:SendMid(19, { "00203" })
    session:WaitForMid(5, 5000)

    session:SendMid(43, { ToolEnable = "1" })
    session:WaitForMid(5, 5000)

    log:Step("Subscribe to tightening results (MID 0060)")

    -- Clean up any stale subscription left from a previous run.
    -- If no subscription exists, the controller replies with MID 0004 error 10, which we ignore.
    session:SendMid(63)
    local cleanup = session:TryWaitForRawResponse(2000)
    if cleanup ~= nil then
        log:Info("Unsubscribe cleanup ack received (MID " .. cleanup.mid .. ")")
    end

    session:SendMid(60)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Tightening subscribe accepted")

    log:Step("Run 3 OK tightenings to complete the batch")
    local batchSize = 3
    local lastResult = nil
    for i = 1, batchSize do
        log:Info("Tightening " .. i .. " of " .. batchSize .. " — trigger on tool")
        local result = session:WaitForResult(120000)
        assert:NotNil(result, "Should receive tightening result " .. i)
        assert:NotNil(result.fields, "Result " .. i .. " should have parsed fields")

        local tighteningStatus = result.fields.TighteningStatus or ""
        log:Info("Tightening " .. i .. " status: " .. tighteningStatus)
        assert:Equals("True", tighteningStatus, "Expected OK tightening " .. i)

        local actualBatchSize = tonumber(result.fields.BatchSize or "0") or 0
        local counter = tonumber(result.fields.BatchCounter or "0") or 0
        local status = result.fields.BatchStatus or ""
        log:Info("Batch: counter " .. counter .. " of " .. actualBatchSize .. ", status " .. status)

        assert:Equals(batchSize, actualBatchSize, "BatchSize should be " .. batchSize .. " after MID 0019")
        assert:Equals(i, counter, "BatchCounter should be " .. i .. " after MID 0020 reset")

        -- Acknowledge each MID 0061 with MID 0062 per Open Protocol spec.
        session:SendMid(62)

        lastResult = result
    end

    log:Step("Validate new batch status mapping on completed batch")
    local finalBatchStatus = lastResult.fields.BatchStatus or lastResult.fields.batchStatus or ""
    log:Info("Final BatchStatus: " .. finalBatchStatus)
    assert:Equals("Ok", finalBatchStatus,
        "Completed OK batch should report batchStatus = Ok (new mapping: 1=batch OK)")

    log:Step("Acknowledge and unsubscribe")
    session:SendMid(62)
    session:SendMid(63)

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
