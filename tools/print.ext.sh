#!/bin/bash
# ##############################################################################
# Script Name   : print.ext.sh
# Description   : Extension print.sh
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

colorTest() {
    for clfg in 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97 39; do
        str=""
        for attr in 0 1 2 4 5 7; do
            str="$str\033[${attr};${clfg}m[attr=${attr};clfg=${clfg}]\033[0m"
        done
        echo -e "$str"
    done
}

printInColorTest() {
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printSuccess "Lorem ipsum dolor sit amet"
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printWarn "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printError "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printInfo "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printTip "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printSuccess "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
}
