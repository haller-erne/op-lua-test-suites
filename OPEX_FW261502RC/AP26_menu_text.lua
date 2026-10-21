-- AP26_menu_text.lua
-- FW261502RC delta: Menu text changes.
-- Change: Entry 3 'xPico Reset' -> 'WLAN Module Reset'; Entry 4 'Restore Factory Def.' -> 'Format Int. Storage'.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: menu text changes")
    log:Break("On the tool display, verify Setup/Extras menu entry 3 is labeled 'WLAN Module Reset' (not 'xPico Reset') and entry 4 is labeled 'Format Int. Storage' (not 'Restore Factory Def.'). Press Continue when verified.")
end
