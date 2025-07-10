#!/bin/bash

echo "=== Audio Debug Script ==="

# Check if cava is installed
echo "1. Checking for cava..."
if command -v cava &> /dev/null; then
    echo "   ✓ cava is installed"
else
    echo "   ✗ cava is NOT installed"
fi

# Check if bc is installed
echo "2. Checking for bc..."
if command -v bc &> /dev/null; then
    echo "   ✓ bc is installed"
else
    echo "   ✗ bc is NOT installed"
fi

# Check PulseAudio
echo "3. Checking PulseAudio..."
if command -v pactl &> /dev/null; then
    echo "   ✓ pactl is available"
    
    echo "4. Checking for running sinks..."
    pactl list sinks short
    
    echo "5. Checking for volume info..."
    VOLUME_INFO=$(pactl list sinks | grep -A 15 "RUNNING" | grep "Volume:" | head -1)
    if [ -n "$VOLUME_INFO" ]; then
        echo "   Volume info found: $VOLUME_INFO"
        VOLUME=$(echo "$VOLUME_INFO" | awk '{print $5}' | sed 's/%//')
        echo "   Extracted volume: $VOLUME"
    else
        echo "   ✗ No volume info found for running sink"
        echo "   Trying default sink..."
        DEFAULT_SINK=$(pactl get-default-sink)
        echo "   Default sink: $DEFAULT_SINK"
        pactl list sinks | grep -A 20 "$DEFAULT_SINK" | grep "Volume:"
    fi
else
    echo "   ✗ pactl is NOT available"
fi

echo "6. Testing simple output..."
echo "[0.1, 0.2, 0.3, 0.4, 0.5]"
