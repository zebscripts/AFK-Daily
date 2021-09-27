#!/system/bin/sh
# ##############################################################################
# Script Name   : afk-daily.ext.sh
# Description   : Extension of the afk-daily.sh script, used for backup & tools
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# ##############################################################################
# Section       : Test
# ##############################################################################

# ##############################################################################
# Function Name : colorTest
# Description   : Print all colors
# Output        : stdout colors test
# ##############################################################################
colorTest() {
    for clfg in 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97 39; do
        str=""
        for attr in 0 1 2 4 5 7; do
            str="$str\033[${attr};${clfg}m[attr=${attr};clfg=${clfg}]\033[0m"
        done
        echo "$str${cNc}"
    done
}

# ##############################################################################
# Function Name : printInColorTest
# Description   : Print all types of messages
# Output        : stdout colors test
# ##############################################################################
printInColorTest() {
    printInColor "DEBUG" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25 W${cNc} / ${cRed}10 L${cNc}]"
    printInColor "DONE" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25${cNc} W / ${cRed}10${cNc} L]"
    printInColor "ERROR" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [25 ${cGreen}W${cNc} / 10 ${cRed}L${cNc}]"
    printInColor "INFO" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25 W${cNc}]"
    printInColor "TEST" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 25)"
    printInColor "WARN" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 25 10)"
    printInColor "" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 0 0)"
}
