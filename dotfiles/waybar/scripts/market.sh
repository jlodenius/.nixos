#!/bin/sh

TICKER_FILE="./tickers.txt"

# Check if file exists
if [ ! -f "$TICKER_FILE" ]; then
    echo "{\"text\": \"No Ticker File\"}"
    exit 1
fi

# Read symbols and join them for the command
SYMBOLS=$(grep -v '^#' "$TICKER_FILE" | tr '\n' ',' | sed 's/,$//')

# Fetch data
DATA=$(ticker -w "$SYMBOLS" -format json)

# Use jq to find the entry with the highest absolute change_percent
TOP_MOVER=$(echo "$DATA" | jq -c 'sort_by(.change_percent | tonumber | abs) | last')

# Extract values for the display
SYMBOL=$(echo "$TOP_MOVER" | jq -r '.symbol | split("-")[0]')
PRICE=$(echo "$TOP_MOVER" | jq -r '.price')
CHANGE=$(echo "$TOP_MOVER" | jq -r '.change_percent')

# Determine trend icon/color class
if [ "$(echo "$CHANGE > 0" | bc -l)" -eq 1 ]; then
    ICON="▲"
    CLASS="up"
else
    ICON="▼"
    CLASS="down"
fi

# Create a full list for the tooltip
TOOLTIP=$(echo "$DATA" | jq -r '.[] | "\(.symbol): \(.price) (\(.change_percent)%)"' | paste -sd "\n" -)

# Output JSON to Waybar
echo "{\"text\": \"$SYMBOL $ICON $CHANGE%\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
