-- AP2_xpico_ver.lua
-- FW261502RC delta: XPico module FW now 5.12.0.0C107.0 or higher.
-- Change: Previously lower version.
-- Acceptance: XPico FW version >= 5.12.0.0C107.0.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request tool/controller status (MID 0040)")
    session:SendMid(40)
    local r41 = session:WaitForMid(41, 5000)
    assert:NotNil(r41, "Should receive MID 0041")

    log:Step("Check XPico FW version")
    local f = r41.fields or {}
    local xpico = f.XpicoFw or f.xpicoFw or f.WifiModuleFw or ""
    log:Info("XPico FW: " .. xpico)
    assert:NotEquals("", xpico, "XPico FW field should be present")

    local function parseVersion(s)
        local major, minor, patch, build = s:match("^(%d+)%.(%d+)%.(%d+)%.(.+)$")
        if major then
            return tonumber(major), tonumber(minor), tonumber(patch), build
        end
        return nil
    end

    local maj, min, pat, bld = parseVersion(xpico)
    assert:NotNil(maj, "XPico FW version should be parseable")
    local ok = maj > 5 or (maj == 5 and (min > 12 or (min == 12 and (pat > 0 or (pat == 0 and bld >= "0C107.0")))))
    assert:IsTrue(ok, "XPico FW must be >= 5.12.0.0C107.0")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
