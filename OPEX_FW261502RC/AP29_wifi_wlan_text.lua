-- AP29_wifi_wlan_text.lua
-- FW261502RC delta: All 'WiFi' text replaced with 'WLAN' throughout UI.
-- Change: Terminology consistency.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: WiFi -> WLAN text replacement")
    log:Break("Navigate through the tool display menus and verify all references to 'WiFi' have been replaced with 'WLAN'. Press Continue when verified.")
end
