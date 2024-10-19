#!/bin/bash

# Define the frequencies for 3 octaves (C=1, D=2, ..., B=7 in each octave)
declare -A frequencies

# Octave 4 (Middle C is C4)
frequencies["1_4"]=261.63    # C4
frequencies["1#_4"]=277.18   # C#4
frequencies["2_4"]=293.66    # D4
frequencies["2#_4"]=311.13   # D#4
frequencies["3_4"]=329.63    # E4
frequencies["4_4"]=349.23    # F4
frequencies["4#_4"]=369.99   # F#4
frequencies["5_4"]=392.00    # G4
frequencies["5#_4"]=415.30   # G#4
frequencies["6_4"]=440.00    # A4
frequencies["6#_4"]=466.16   # A#4
frequencies["7_4"]=493.88    # B4

# Octave 5
frequencies["1_5"]=523.25    # C5
frequencies["1#_5"]=554.37   # C#5
frequencies["2_5"]=587.33    # D5
frequencies["2#_5"]=622.25   # D#5
frequencies["3_5"]=659.25    # E5
frequencies["4_5"]=698.46    # F5
frequencies["4#_5"]=739.99   # F#5
frequencies["5_5"]=783.99    # G5
frequencies["5#_5"]=830.61   # G#5
frequencies["6_5"]=880.00    # A5
frequencies["6#_5"]=932.33   # A#5
frequencies["7_5"]=987.77    # B5

# Octave 6
frequencies["1_6"]=1046.50   # C6
frequencies["1#_6"]=1108.73  # C#6
frequencies["2_6"]=1174.66   # D6
frequencies["2#_6"]=1244.51  # D#6
frequencies["3_6"]=1318.51   # E6
frequencies["4_6"]=1396.91   # F6
frequencies["4#_6"]=1479.98  # F#6
frequencies["5_6"]=1567.98   # G6
frequencies["5#_6"]=1661.22  # G#6
frequencies["6_6"]=1760.00   # A6
frequencies["6#_6"]=1864.66  # A#6
frequencies["7_6"]=1975.53   # B6

# Default values for beep length and delay (can be overridden per note)
default_beep_length="500ms"
default_delay="350ms"

# Function to convert numeric notation to Mikrotik beep commands with custom length and delay
convert_to_mikrotik_beep() {
    local file=$1
    local beep_length=$2
    local delay=$3

    # Use default values if beep_length or delay is not provided
    [ -z "$beep_length" ] && beep_length=$default_beep_length
    [ -z "$delay" ] && delay=$default_delay

    # Read the file line by line and convert the notation to beep commands
    while IFS= read -r line; do
        for note in $line; do
            base_note=""
            octave=""
            modifier=""

            # Handle sharp notes
            if [[ "${note:1:1}" == "#" ]]; then
                base_note="${note:0:1}#"
                octave="${note:3:1}"
            else
                base_note="${note:0:1}"
                octave="${note:2:1}"
            fi

            # Mikrotik script comment for debugging: Print what note is being processed
            echo "# Processing note: $base_note in octave: $octave"

            # Get the frequency corresponding to the note and octave
            freq=${frequencies["${base_note}_${octave}"]}

            # Mikrotik script comment for debugging: Print frequency found
            # echo "# Frequency found: $freq"

            if [ -z "$freq" ]; then
                echo "# Error: No frequency found for ${base_note}_${octave}"
            else
                # Generate the beep command
                echo ":beep length=${beep_length} frequency=${freq}"

                # Generate the delay command
                echo ":delay ${delay}"
            fi
        done
    done < "$file"
}

# Check if a file input is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <notation_file> [beep_length] [delay]"
    exit 1
fi

# Get the input file, beep length, and delay
notation_file=$1
beep_length=$2  # Optional custom beep length
delay=$3        # Optional custom delay

# Call the function with the input file
convert_to_mikrotik_beep "$notation_file" "$beep_length" "$delay"
