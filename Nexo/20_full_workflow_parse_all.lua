-- 20_full_workflow_parse_all.lua
-- Complete Nexo workflow: connect, select job, tighten, parse everything.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect to Nexo")
    session:Connect()

    log:Step("Parse handshake reply")
    session:SendMid(1)
    local mid2 = session:WaitForMid(2, 10000)
    assert:NotNil(mid2.fields, "Handshake reply should have fields")
    log:Info("Controller: " .. (mid2.fields.ControllerName or "(not reported)"))
    log:Info("Cell: " .. (mid2.fields.CellId or "?") ..
        " Channel: " .. (mid2.fields.ChannelId or "?"))

    log:Step("Request tool data")
    session:SendMid(40)
    local tool = session:WaitForMid(41, 10000)
    if tool.fields then
        log:Info("Tool SN: " .. (tool.fields.ToolSerialNumber or "?"))
        log:Info("Max Torque: " .. (tool.fields.ToolMaxTorque or "?"))
    end

    log:Step("Select job 1")
    session:SelectJob(1)
    log:Info("Job 1 selected")

    log:Step("Subscribe and perform tightening")
    session:StartTightening()
    log:Info("Waiting for tightening — trigger on Nexo...")
    local result = session:WaitForResult(120000)

    log:Step("Full result parse")
    assert:NotNil(result.fields, "Result must have fields")
    local fields = result.fields

    -- Build a summary table
    local summary = {
        {"Torque", fields.Torque},
        {"Angle", fields.Angle},
        {"TighteningStatus", fields.TighteningStatus},
        {"TorqueStatus", fields.TorqueStatus},
        {"AngleStatus", fields.AngleStatus},
        {"TorqueMinLimit", fields.TorqueMinLimit},
        {"TorqueMaxLimit", fields.TorqueMaxLimit},
        {"AngleMinLimit", fields.AngleMinLimit},
        {"AngleMaxLimit", fields.AngleMaxLimit},
        {"JobId", fields.JobId},
        {"ParameterSetId", fields.ParameterSetId},
        {"BatchSize", fields.BatchSize},
        {"BatchCounter", fields.BatchCounter},
        {"TighteningId", fields.TighteningId},
        {"TimeStamp", fields.TimeStamp},
        {"ToolSerialNumber", fields.ToolSerialNumber},
    }

    for _, pair in ipairs(summary) do
        local name, value = pair[1], pair[2]
        if value then
            log:Info(string.format("  %-20s = %s", name, value))
        end
    end

    log:Step("Validate result integrity")
    assert:TorqueWithin(result, 0.0, 999.0)
    assert:AngleWithin(result, 0.0, 9999.0)
    assert:NoAlarm(result)

    local torque = tonumber(fields.Torque)
    local angle = tonumber(fields.Angle)
    assert:IsTrue(torque ~= nil, "Torque must be parseable as number")
    assert:IsTrue(angle ~= nil, "Angle must be parseable as number")

    log:Step("Verify header matches")
    assert:IsTrue(result.mid == 61, "Result MID should be 61")
    assert:IsTrue(result.header.Mid == 61, "Header MID should be 61")

    log:Step("Count total parsed fields")
    local count = 0
    for _ in pairs(fields) do count = count + 1 end
    log:Info("Total fields parsed from MID 0061: " .. count)

    log:Step("Cleanup")
    session:StopTightening()
    session:Disconnect()
    log:Info("Full workflow complete!")
end
