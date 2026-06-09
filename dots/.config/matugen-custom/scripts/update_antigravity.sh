#!/bin/bash
jq -s '.[0].userSettings.customThemeSeedsDark = .[1] | .[0]' ~/.gemini/antigravity-ide/config.json ~/.gemini/antigravity-ide/customThemeSeedsDark.json > ~/.gemini/antigravity-ide/config.tmp
cat ~/.gemini/antigravity-ide/config.tmp > ~/.gemini/antigravity-ide/config.json
rm ~/.gemini/antigravity-ide/config.tmp
