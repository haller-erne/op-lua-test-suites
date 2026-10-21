-- 06_tool_data_parse.lua
-- Request tool data (MID 0040/0041) and parse response fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool data (MID 0040)")
    session:SendMid(40)

    log:Step("Wait for tool data response (MID 0041)")
    local tool = session:WaitForMid(41, 10000)
    assert:NotNil(tool, "Should receive MID 0041")
    assert:NotNil(tool.fields, "MID 0041 should have parsed fields")

    log:Step("Parse tool identification")
    if tool.fields.ToolSerialNumber then
        log:Info("ToolSerialNumber: " .. tool.fields.ToolSerialNumber)
    end
    if tool.fields.ToolNumberOfTightenings then
        log:Info("ToolNumberOfTightenings: " .. tool.fields.ToolNumberOfTightenings)
    end
    if tool.fields.LastCalibrationDate then
        log:Info("LastCalibrationDate: " .. tool.fields.LastCalibrationDate)
    end
    if tool.fields.ControllerSerialNumber then
        log:Info("ControllerSerialNumber: " .. tool.fields.ControllerSerialNumber)
    end
    if tool.fields.ToolMaxTorque then
        log:Info("ToolMaxTorque: " .. tool.fields.ToolMaxTorque)
    end
    if tool.fields.OpenEndData then
        log:Info("OpenEndData: " .. tool.fields.OpenEndData)
    end

    log:Step("Verify tool serial is non-empty")
    if tool.fields.ToolSerialNumber then
        assert:IsTrue(#tool.fields.ToolSerialNumber > 0,
            "Tool serial number should not be empty")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
