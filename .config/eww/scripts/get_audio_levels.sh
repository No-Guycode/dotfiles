#!/usr/bin/env bash
#
# Audio levels script for Eww using cava → “better frequency analysis.”
# If cava is installed and you have a ~/.config/eww/cava_config, it will try to use that;
# otherwise it falls back to pactl‐based “simulated” values.
#

# Step 1: Try cava first
if command -v cava >/dev/null 2>&1 && [ -f ~/.config/eww/cava_config ]; then
    # Run cava for exactly 0.2 s, grab the last line of output
    CAVA_OUTPUT=$(timeout 0.2s cava -p ~/.config/eww/cava_config 2>/dev/null | tail -1)

    # If cava produced something nonempty, convert “;”-delimited output into a Yuck list:
    if [ -n "$CAVA_OUTPUT" ] && [ "$CAVA_OUTPUT" != "" ]; then
        #   • First: “tr ';' '\n'” turns semicolons into newlines
        #   • Then “head -20” picks the first 20 bins
        #   • Then each line is divided by 100, formatted to two decimals (e.g. 60 → 0.60)
        #   • We collect them into space‐separated tokens and wrap in parentheses.
        VALUES=$(
          echo "$CAVA_OUTPUT" \
          | tr ';' '\n' \
          | head -20 \
          | awk '{ printf "%.2f\n", $1/100 }'
        )

        # Now turn those newline-separated numbers into a single parenthesized list
        # e.g. 0.60\n0.62\n0.59 → "(0.60 0.62 0.59 …)"
        printf "("
        first=true
        while IFS= read -r v; do
            if $first; then
                # first element: print without leading space
                printf "%s" "$v"
                first=false
            else
                # subsequent: print a space then the number
                printf " %s" "$v"
            fi
        done <<< "$VALUES"
        printf ")"
        echo  # final newline
        exit 0
    fi
fi

# Step 2: Fallback: pactl‐based volume “simulation”
if command -v pactl >/dev/null 2>&1; then
    # Get the volume (percentage) of the running sink
    VOLUME=$(pactl list sinks \
               | grep -A 15 "State: RUNNING" \
               | grep "Volume:" \
               | head -1 \
               | awk '{print $5}' \
               | sed 's/%//' 2>/dev/null)

    # If none found, try default sink
    if [ -z "$VOLUME" ]; then
        VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ \
                  | awk '{print $5}' \
                  | sed 's/%//' 2>/dev/null)
    fi

    if [ -n "$VOLUME" ] 2>/dev/null && [ "$VOLUME" -gt 0 ] 2>/dev/null; then
        # Convert to a decimal between 0.00 and 1.00
        BASE_LEVEL=$(echo "scale=2; $VOLUME / 100" | bc 2>/dev/null || echo "0.50")

        # Build 20 “frequency‐like” bars
        # We’ll store them line by line and then wrap in ( … ) at the end
        declare -a LEVELS=()

        for i in $(seq 1 20); do
            if [ "$i" -le 5 ]; then
                # bass: higher
                MULTIPLIER=$(echo "scale=2; 0.8 + ($RANDOM % 20)/100" | bc 2>/dev/null || echo "0.90")
            elif [ "$i" -le 12 ]; then
                # mids: medium
                MULTIPLIER=$(echo "scale=2; 0.5 + ($RANDOM % 40)/100" | bc 2>/dev/null || echo "0.70")
            else
                # highs: lower
                MULTIPLIER=$(echo "scale=2; 0.2 + ($RANDOM % 30)/100" | bc 2>/dev/null || echo "0.30")
            fi

            RAW=$(echo "scale=2; $BASE_LEVEL * $MULTIPLIER" | bc 2>/dev/null || echo "0.50")
            # Clamp between 0.05 and 1.00
            if awk "BEGIN {exit !($RAW > 1)}"; then
                RAW=1.00
            elif awk "BEGIN {exit !($RAW < 0.05)}"; then
                RAW=0.05
            fi
            # Ensure two decimals (e.g. “0.5” → “0.50”)
            FORMATTED=$(printf "%.2f" "$RAW")
            LEVELS+=("$FORMATTED")
        done

        # Now print as a Yuck list
        printf "("
        for idx in "${!LEVELS[@]}"; do
            if [ "$idx" -eq 0 ]; then
                printf "%s" "${LEVELS[$idx]}"
            else
                printf " %s" "${LEVELS[$idx]}"
            fi
        done
        printf ")\n"
        exit 0
    else
        # No audio → minimal static bars (all 0.05)
        # Print “(0.05 0.05 … 0.05)” 20 times
        printf "("
        for i in $(seq 1 20); do
            if [ "$i" -eq 1 ]; then
                printf "0.05"
            else
                printf " 0.05"
            fi
        done
        printf ")\n"
        exit 0
    fi
else
    # No pactl → static low levels
    printf "("
    for i in $(seq 1 20); do
        if [ "$i" -eq 1 ]; then
            printf "0.10"
        else
            printf " 0.10"
        fi
    done
    printf ")\n"
    exit 0
fi
