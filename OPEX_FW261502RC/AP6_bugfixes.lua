-- AP6_bugfixes.lua
-- FW261502RC delta: 4 bugfixes from baseline 26.07.00 / 26.10.02.
-- Change: Tool freeze at yield point, result screen not switching, wrong PIN code on cancel, breakaway torque monitor no result screen.
-- Acceptance: Operator verifies each bug is no longer reproducible.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Bugfix 1/4: Tool freeze at yield point (stand-alone)")
    log:Break("Perform a yield-point tightening on the tool. Confirm the tool does NOT freeze and completes the cycle. Press Continue when done.")

    log:Step("Bugfix 2/4: Result screen not switching")
    log:Break("Perform any tightening and confirm the result screen appears/switches correctly. Press Continue when done.")

    log:Step("Bugfix 3/4: PIN code 'Wrong Pin-Code' on cancel")
    log:Break("Navigate to a PIN entry screen, enter digits, then press Cancel. Confirm NO 'Wrong Pin-Code' error appears. Press Continue when done.")

    log:Step("Bugfix 4/4: Breakaway torque monitor -> no result screen")
    log:Break("Enable breakaway torque monitoring, perform a tightening, and confirm the result screen is shown. Press Continue when done.")

    log:Step("Disconnect")
    session:Disconnect()
end
