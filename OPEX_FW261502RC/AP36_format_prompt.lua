-- AP36_format_prompt.lua
-- FW261502RC delta: After switching operating mode, tool prompts 'Format internal memory?'.
-- Change: New format confirmation prompt.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: format internal memory prompt")
    log:Break("Switch the operating mode on the tool and verify a prompt appears asking 'Format internal memory?'. Press Continue when verified.")
end
