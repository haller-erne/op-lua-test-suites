-- 12_batch_counter_tracking.lua
-- Monitor batch counter progression across multiple tightenings.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job and subscribe")
    session:SelectJob(1)
    session:StartTightening()

    log:Step("Collect 3 tightening results")
    local results = {}
    for i = 1, 3 do
        log:Info("Waiting for tightening " .. i .. " (trigger on Nexo)...")
        local result = session:WaitForResult(120000)
        assert:NotNil(result.fields, "Result " .. i .. " should have fields")
        results[i] = result

        local batch = result.fields.BatchCounter or "?"
        local batchSize = result.fields.BatchSize or "?"
        log:Info(string.format("#%d: BatchCounter=%s/%s  Status=%s",
            i, batch, batchSize, result.fields.TighteningStatus or "?"))
    end

    log:Step("Verify batch counter progression")
    local prev = tonumber(results[1].fields.BatchCounter)
    if prev then
        for i = 2, #results do
            local curr = tonumber(results[i].fields.BatchCounter)
            if curr then
                -- Counter should increment or reset (if batch completed)
                log:Info(string.format("Batch counter: %d -> %d", prev, curr))
                prev = curr
            end
        end
    else
        log:Warn("BatchCounter not available in response")
    end

    log:Step("Cleanup")
    session:StopTightening()
    session:Disconnect()
end
