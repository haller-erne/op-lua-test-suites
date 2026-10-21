-- 03_tightening_limits_validation.lua
-- Parse torque/angle limits from MID 0061 and validate against actual values.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe and wait for result")
    session:StartTightening()
    local result = session:WaitForResult(60000)

    log:Step("Parse limit fields")
    local torqueMin = tonumber(result.fields.TorqueMinLimit)
    local torqueMax = tonumber(result.fields.TorqueMaxLimit)
    local angleMin = tonumber(result.fields.AngleMinLimit)
    local angleMax = tonumber(result.fields.AngleMaxLimit)

    log:Info(string.format("Torque limits: [%s, %s]",
        tostring(torqueMin), tostring(torqueMax)))
    log:Info(string.format("Angle limits: [%s, %s]",
        tostring(angleMin), tostring(angleMax)))

    log:Step("Validate torque is within limits")
    local torque = tonumber(result.fields.Torque)
    if torqueMin and torqueMax and torque then
        if result.fields.TighteningStatus == "1" then
            assert:IsTrue(torque >= torqueMin and torque <= torqueMax,
                string.format("OK torque %.3f should be within [%.3f, %.3f]",
                    torque, torqueMin, torqueMax))
            log:Info("Torque within limits: PASS")
        else
            log:Info("Tightening NOK — torque may be outside limits")
        end
    else
        log:Warn("Limit fields not available in this revision")
    end

    log:Step("Validate angle is within limits")
    local angle = tonumber(result.fields.Angle)
    if angleMin and angleMax and angle then
        if result.fields.TighteningStatus == "1" then
            assert:IsTrue(angle >= angleMin and angle <= angleMax,
                string.format("OK angle %.1f should be within [%.1f, %.1f]",
                    angle, angleMin, angleMax))
            log:Info("Angle within limits: PASS")
        else
            log:Info("Tightening NOK — angle may be outside limits")
        end
    else
        log:Warn("Angle limit fields not available in this revision")
    end

    log:Step("Cleanup")
    session:StopTightening()
    session:Disconnect()
end
