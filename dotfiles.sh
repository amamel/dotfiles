#!/bin/bash

EXECUTABLE_DIR="api"

cat $EXECUTABLE_DIR/assets/welcome.txt
cat $EXECUTABLE_DIR/assets/menu.txt

PS3='Number to execute: '
os=("Apple OSX" "Raspberry Pi Ubuntu")
select opt in "${os[@]}"
do
    case $opt in
        "Apple OSX")
            echo "Launching the installer..."
            . $EXECUTABLE_DIR/macos.sh
            ;;
        "Raspberry Pi Ubuntu")
            echo "Launching the installer..."
            . $EXECUTABLE_DIR/pi.sh
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done