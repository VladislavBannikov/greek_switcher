#!/bin/bash

# Initialize variables
availableLayouts=""
currentLayout=""

prevLayoutFile="/tmp/prev_layout_greek_switcher.tmp"

input=$(gdbus introspect --session --dest org.gnome.Shell --object-path /me/madhead/Shyriiwook --only-properties | grep "Layout")

while IFS= read -r line; do
    if [[ $line == *"availableLayouts"* ]]; then
        availableLayouts=$(echo "$line" | awk -F'=' '{print $2}' | sed "s/^[ \t]*//;s/[ ';]//g")
    elif [[ $line == *"currentLayout"* ]]; then
        currentLayout=$(echo "$line" | awk -F'=' '{print $2}' | sed "s/^[ \t]*//;s/[ ';]//g")
    fi
done <<< "$input"

echo "Available Layouts: $availableLayouts"
echo "Current Layout: $currentLayout"

if [[ $currentLayout == "gr" ]]; then
    # Check if the temporary file exists and read prevLayout from it
    if [[ -f "$prevLayoutFile" ]]; then
        prevLayout=$(cat "$prevLayoutFile")
    else
        prevLayout="us"
    fi
    gdbus call --session --dest org.gnome.Shell --object-path /me/madhead/Shyriiwook --method me.madhead.Shyriiwook.activate "$prevLayout"
    # echo "Switched layout from 'gr' to previous"
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"
else
    echo "$currentLayout" > "$prevLayoutFile"    
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru'), ('xkb', 'gr')]"
    gdbus call --session --dest org.gnome.Shell --object-path /me/madhead/Shyriiwook --method me.madhead.Shyriiwook.activate "gr"
    # echo "Switched layout to 'gr'"    
fi
