-- AP11_cycle_reset_screen.lua
-- FW261502RC delta: Cycle number reset screen added in measurement mode (down arrow key).
-- Change: Target cycle number can be specified.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: cycle number reset screen")
    log:Break("Enter measurement mode on the tool, press the DOWN arrow key, and verify a cycle number reset screen appears where you can specify the target cycle number. Press Continue when verified.")
end
