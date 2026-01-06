#!/bin/sh

# List your tickers (Stock: AAPL, Crypto: BTC-USD)
SYMBOLS="BTC-USD,ETH-USD,INVE-B.ST,AAPL"

# Fetch data using ticker
DATA=$(ticker -w "$SYMBOLS" -format json)

# Format the output for Waybar
# This creates a string like: BTC: 94k | AAPL: 230
TEXT=$(echo "$DATA" | jq -r '.[] | "\(.symbol | split("-")[0]): \(.price)"' | paste -sd " | " -)

# Create a more detailed tooltip
TOOLTIP=$(echo "$DATA" | jq -r '.[] | "\(.symbol): \(.price) (\(.change_percent)%)"' | paste -sd "\n" -)

# Output JSON for Waybar
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
