-- AP33_hw_revision_display.lua
-- FW261502RC delta: Version-minor shortened to 1 digit (e.g. 1.04 -> 1.4) to match PCB print.
-- Change: HW revision display format.
-- Acceptance: Single digit after decimal point.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: hardware revision display")
    log:Break("On the tool display or info screen, verify the hardware revision is shown with a single digit after the decimal point (e.g. '1.4' instead of '1.04'). Press Continue when verified.")
end
