#!/bin/bash
jq -s '.[0].userSettings.customThemeSeedsDark = .[1] | .[0]' ~/.gemini/config/config.json ~/.gemini/config/customThemeSeedsDark.json > ~/.gemini/config/config.tmp
cat ~/.gemini/config/config.tmp > ~/.gemini/config/config.json
rm ~/.gemini/config/config.tmp
