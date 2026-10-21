-- AP13_manual_cycle_reset.lua
-- FW261502RC delta: Option to reset cycle count when starting manual parameter sets.
-- Change: Cycle count reset available for manual parameter sets.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: cycle count reset for manual parameter sets")
    log:Break("Start a manual parameter set on the tool and verify there is an option to reset the cycle count. Press Continue when verified.")
end
