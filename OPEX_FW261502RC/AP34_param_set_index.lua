-- AP34_param_set_index.lua
-- FW261502RC delta: Bugfix - active parameter set was incorrectly set to job parameter set, causing index error in MID 0061.
-- Change: Restart job via MID 0039 now keeps correct parameter set index.
-- Acceptance: MID 0061 parameterSetId matches selected job's parameter set.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
-- Note: MID 0040/0041 is tool data, not job data. We use MID 0032/0033 to read the job's parameter set list.
-- Prerequisites: Job 1 must be configured with parameter sets that have no batch counters (or batch size 1 per PSet),
--                so the expected PSet is deterministic.

local function getExpectedParameterSetId(jobData)
    -- Prefer OPI-parsed fields (if available via MidInterpreterService)
    if jobData.fields then
        if jobData.fields.ParameterSetIds then
            local first = jobData.fields.ParameterSetIds:match("^([^,]+)")
            if first and first ~= "" then return first end
        end
        if jobData.fields.NumberOfParameterSets == "1" and jobData.fields.ParameterSetList then
            local first = jobData.fields.ParameterSetList:match("TypeId: (%d+)")
            if first then return first end
        end
    end

    -- Fallback: manual parse of MID 0033 Rev 1 tagged body
    local body = jobData.body or ""
    local fixedLen = 4 + 27 + 3 + 6 + 7 + 3 + 3 + 3 + 3 + 3 + 3 + 4
    if #body <= fixedLen then return nil end
    local list = body:sub(fixedLen + 1)
    local firstEntry = list:match("^([^;]+);")
    if not firstEntry then return nil end
    local _, psetId = firstEntry:match("^(%d+):(%d+):")
    return psetId
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job and read its parameter set via MID 0032/0033")
    session:SelectJob(1)
    session:SendMid(32, { "01" })
    local r33 = session:WaitForMid(33, 5000)
    assert:NotNil(r33, "Should receive MID 0033")
    log:Info("MID 0033 raw body: [" .. (r33.body or "") .. "]")
    local expectedPset = getExpectedParameterSetId(r33)
    log:Info("Expected parameter set from job: " .. (expectedPset or "<not found>"))

    log:Step("Clean up old subscriptions, then subscribe to results")
    session:SendMid(63)
    session:WaitForMid(5, 5000)
    session:SendMid(60)
    session:WaitForMid(5, 5000)
    session:SendMid(571, { "011" })
    session:WaitForMid(5, 5000)

    log:Step("First tightening (job start PSet)")
    local r1 = session:WaitForResult(120000)
    assert:NotNil(r1, "Should receive first tightening result")
    local pset1 = r1.fields.ParameterSetId or r1.fields.parameterSetId or ""
    log:Info("First tightening MID 0061 ParameterSetId: " .. pset1)
    session:SendMid(62)

    log:Step("Second tightening (advance job batch)")
    local r2 = session:WaitForResult(120000)
    assert:NotNil(r2, "Should receive second tightening result")
    local pset2 = r2.fields.ParameterSetId or r2.fields.parameterSetId or ""
    log:Info("Second tightening MID 0061 ParameterSetId: " .. pset2)
    assert:NotEquals(pset1, pset2, "Job should advance to the next parameter set after two tightenings")
    session:SendMid(62)

    log:Step("Restart job via MID 0039 with job number 1")
    -- OPEX OPERATOR manual documents MID 0039 Revision 1 (2-digit job ID)
    session:SendMid(39, { "01" })
    session:WaitForMid(5, 5000)

    log:Step("Third tightening after restart")
    local r3 = session:WaitForResult(120000)
    assert:NotNil(r3, "Should receive post-restart tightening result")
    session:SendMid(62)

    log:Step("Verify MID 0061 parameter set index after restart")
    local pset = r3.fields.ParameterSetId or r3.fields.parameterSetId or ""
    log:Info("Post-restart MID 0061 ParameterSetId: " .. pset)
    if expectedPset and expectedPset ~= "" then
        assert:Equals(expectedPset, pset, "Parameter set index must match selected job's parameter set after restart")
    end

    log:Step("Acknowledge and unsubscribe")
    session:SendMid(62)
    session:SendMid(63)

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
