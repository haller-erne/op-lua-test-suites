-- AP17_mid0033_batchmode.lua
-- FW261502RC delta: MID 0033 Job Batch Mode (ID06) now correctly determined.
-- Change: Previously hardcoded 0.
-- Acceptance: jobBatchMode reflects actual job configuration.
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
    log:Info("Job " .. jobId .. " (" .. parsed.jobName .. ") JobBatchMode = " .. parsed.jobBatchMode)
    return parsed
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    -- Job 1 "New screw" has no audit params / NOK limits configured → expect mode 0
    log:Step("Query job 1 data and verify jobBatchMode = 0")
    local job1 = requestJobData(1)
    assert:Equals("0", job1.jobBatchMode, "Job 1 should have jobBatchMode = 0 (only OK tightenings counted)")

    -- Job 2 "New screw2" has NOK limits configured → expect mode 1
    log:Step("Query job 2 data and verify jobBatchMode = 1")
    local job2 = requestJobData(2)
    assert:Equals("1", job2.jobBatchMode, "Job 2 should have jobBatchMode = 1 (OK and NOK tightenings counted)")

    -- Job 3 "New screw2" is an audit/NOK job → expect mode 1
    log:Step("Query job 3 data and verify jobBatchMode = 1")
    local job3 = requestJobData(3)
    assert:Equals("1", job3.jobBatchMode, "Job 3 should have jobBatchMode = 1 (OK and NOK tightenings counted)")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
