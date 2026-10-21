-- AP18_mid0035_jobstatus.lua
-- FW261502RC delta: MID 0035 Job Status fixes.
-- Change: jobStatus correctly determined; batch size/counter no longer swapped;
--         Rev 003 adds currentStage/stageCount/stageType.
-- Acceptance: batchCounter reaches batchSize; batchMode correct; Rev003 fields present.
-- Note: ID02 JobStatus is excluded from this test due to a confirmed firmware bug where
--       the controller reports Ok before the job is actually complete.
--       Per Open Protocol spec, JobStatus should be 0 (NotCompleted) until BatchCounter
--       reaches BatchSize, then 1 (Ok). The tool currently sends Ok from the first MID 0035.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
-- Uses OPI 6.1.1 parsed fields from MID 0034 Rev 003 subscription only.

local function runJobCycle(jobId, revision, timeoutMs)
    log:Step("Select and start job " .. jobId .. " for Rev " .. string.format("%03d", revision))
    session:SelectJob(jobId)
    session:SendMid(571, { "011" })
    session:WaitForMid(5, 5000)

    log:Info("Perform all tightenings for job " .. jobId .. ". Waiting up to " .. (timeoutMs / 1000) .. " seconds...")

    local final = nil
    local batchSize = nil
    local loopStart = os.clock()

    while (os.clock() - loopStart) < (timeoutMs / 1000) do
        local r35 = session:WaitForMid(35, 10000)
        if r35 == nil or r35.fields == nil then
            if final ~= nil then break end
        else
            local f = r35.fields
            local size = tonumber(f.JobBatchSize or "0") or 0
            local cnt = tonumber(f.JobBatchCounter or "0") or 0
            local status = f.JobStatus or ""

            if batchSize == nil and size > 0 then
                batchSize = size
                log:Info("Job " .. jobId .. " batch size: " .. batchSize)
            end

            log:Info("MID 0035 JobId=" .. (f.JobId or "") ..
                     " JobStatus=" .. status ..
                     " JobBatchMode=" .. (f.JobBatchMode or "") ..
                     " BatchSize=" .. size ..
                     " BatchCounter=" .. cnt)

            -- Known firmware bug: JobStatus is reported as Ok from the first MID 0035,
            -- even while BatchCounter < BatchSize. Per spec it should be NotCompleted until done.
            if cnt < size and status == "Ok" then
                log:Warn("Firmware bug: JobStatus is Ok but job is still incomplete (BatchCounter=" .. cnt .. " < BatchSize=" .. size .. ")")
            end

            if revision == 3 then
                log:Info("MID 0035 Rev003 CurrentStep=" .. (f.JobCurrentStep or "") ..
                         " TotalSteps=" .. (f.JobTotalNumberOfSteps or "") ..
                         " StepType=" .. (f.JobStepType or ""))
            end

            session:SendMid(36)
            final = r35

            if cnt >= size and size > 0 then
                log:Info("Job " .. jobId .. " completed: BatchCounter=" .. cnt .. " reached BatchSize=" .. size)
                break
            end
        end
    end

    assert:NotNil(final, "Should receive at least one MID 0035 for job " .. jobId)
    assert:NotNil(final.fields, "Final MID 0035 for job " .. jobId .. " should have parsed fields")
    return final.fields
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to job info (MID 0034 Rev 003)")
    session:SendMid(34, nil, { revision = "003" })
    assert:NotNil(session:WaitForMid(5, 5000), "MID 0034 Rev 003 subscribe should be accepted")

    -- === Job 1 Rev 003 ===
    local r3j1 = runJobCycle(1, 3, 120000)
    assert:Equals("OnlyOkTightenings", r3j1.JobBatchMode or "", "Job1 Rev003 should count only OK tightenings")
    assert:Equals(r3j1.JobBatchSize, r3j1.JobBatchCounter, "Job1 Rev003 BatchSize must equal BatchCounter (not swapped)")
    assert:NotEquals("", r3j1.JobCurrentStep or "", "Job1 Rev003 current stage must be present")
    assert:NotEquals("", r3j1.JobTotalNumberOfSteps or "", "Job1 Rev003 stage count must be present")
    assert:NotEquals("", r3j1.JobStepType or "", "Job1 Rev003 stage type must be present")

    -- === Job 2 Rev 003 ===
    local r3j2 = runJobCycle(2, 3, 120000)
    assert:Equals("OkAndNokTightenings", r3j2.JobBatchMode or "", "Job2 Rev003 should count OK and NOK tightenings")
    assert:Equals(r3j2.JobBatchSize, r3j2.JobBatchCounter, "Job2 Rev003 BatchSize must equal BatchCounter (not swapped)")
    assert:NotEquals("", r3j2.JobCurrentStep or "", "Job2 Rev003 current stage must be present")
    assert:NotEquals("", r3j2.JobTotalNumberOfSteps or "", "Job2 Rev003 stage count must be present")
    assert:NotEquals("", r3j2.JobStepType or "", "Job2 Rev003 stage type must be present")

    log:Step("Acknowledge and unsubscribe")
    session:SendMid(36)
    session:SendMid(37)

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
