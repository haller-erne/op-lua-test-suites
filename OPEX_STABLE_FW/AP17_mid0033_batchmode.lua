-- AP17_mid0033_batchmode.lua
-- STABLE FW re-test (suite: OPEX_STABLE_FW) — derived from the FW261502RC beta suite.
-- Delta under test: MID 0033 ID06 Job Batch Mode must reflect the actual job
--       configuration (beta FW previously hardcoded 0).
-- Config on tool: JOB1 = no NOK limits -> mode 0 (only OK counted);
--       JOB2 = NOK limits parameterized -> mode 1 (OK and NOK counted).
-- Setup was done via gwk-cli (replaces EasyWin GUI):
--   python tools\gwk-cli\gwk_cli.py --live set-nok T22 1   (JOB2 member)
--   python tools\gwk-cli\gwk_cli.py --live set-nok T1 2    (JOB2 member, idx 5)
-- Ground truth cross-check: python tools\gwk-cli\gwk_cli.py get-nok T22  -> 1
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
-- This script requests job data via MID 0032 and parses the MID 0033 reply manually,
-- because OPI 6.1.1 does not expose JobBatchMode in the parsed Lua fields.

local function parseMid0033Rev1(body)
    local d = {}
    local pos = 1
    local len = #body

    local function readTagged(tagExpected, valueLen)
        if pos + 2 + valueLen - 1 > len then
            return nil, "Body too short for tag " .. tagExpected
        end
        local tag = body:sub(pos, pos + 1)
        pos = pos + 2
        if tag ~= tagExpected then
            return nil, "Expected tag " .. tagExpected .. " at pos " .. (pos - 2) .. ", got " .. tag
        end
        local value = body:sub(pos, pos + valueLen - 1)
        pos = pos + valueLen
        return value
    end

    d.jobId, d.error = readTagged("01", 2)
    if d.error then return d end
    d.jobName, d.error = readTagged("02", 25)
    if d.error then return d end
    d.forcedOrder, d.error = readTagged("03", 1)
    if d.error then return d end
    d.maxTimeFirstTightening, d.error = readTagged("04", 4)
    if d.error then return d end
    d.maxTimeToComplete, d.error = readTagged("05", 5)
    if d.error then return d end
    d.jobBatchMode, d.error = readTagged("06", 1)
    if d.error then return d end
    d.lockAtJobDone, d.error = readTagged("07", 1)
    if d.error then return d end
    d.useLineControl, d.error = readTagged("08", 1)
    if d.error then return d end
    d.repeatJob, d.error = readTagged("09", 1)
    if d.error then return d end
    d.toolLoosening, d.error = readTagged("10", 1)
    if d.error then return d end
    d.reserved, d.error = readTagged("11", 1)
    if d.error then return d end
    d.numberOfParameterSets, d.error = readTagged("12", 2)
    if d.error then return d end

    return d
end

local function requestJobData(jobId)
    -- MID 0032 Rev 1 body: 2-digit job ID
    session:SendMid(32, { string.format("%02d", jobId) })
    local r33 = session:WaitForMid(33, 5000)
    assert:NotNil(r33, "Should receive MID 0033 reply for job " .. jobId)
    log:Info("MID 0033 raw body for job " .. jobId .. ": [" .. (r33.body or "") .. "]")
    local parsed = parseMid0033Rev1(r33.body or "")
    assert:IsTrue(parsed.error == nil, "Failed to parse MID 0033: " .. (parsed.error or "unknown error"))
    log:Info("Job " .. jobId .. " (" .. parsed.jobName .. ") JobBatchMode = " .. parsed.jobBatchMode ..
             " ParameterSets = " .. (parsed.numberOfParameterSets or "?"))
    return parsed
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    -- JOB1 has no NOK limits configured -> expect mode 0 (only OK tightenings counted)
    log:Step("Query job 1 data and verify jobBatchMode = 0")
    local job1 = requestJobData(1)
    assert:Equals("0", job1.jobBatchMode, "Job 1 should have jobBatchMode = 0 (only OK tightenings counted)")

    -- JOB2 has NOK limits configured -> expect mode 1 (OK and NOK tightenings counted)
    log:Step("Query job 2 data and verify jobBatchMode = 1")
    local job2 = requestJobData(2)
    assert:Equals("1", job2.jobBatchMode, "Job 2 should have jobBatchMode = 1 (OK and NOK tightenings counted)")

    -- Cross-check with MID 0035 parsed names from the AP18 run:
    -- mode 0 <-> "OnlyOkTightenings", mode 1 <-> "OkAndNokTightenings"
    log:Step("Verify parameter set count matches job definition")
    assert:Equals("2", job1.numberOfParameterSets, "Job 1 should have 2 parameter sets (T1, T2)")
    assert:Equals("2", job2.numberOfParameterSets, "Job 2 should have 2 parameter sets (T1, T22)")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
