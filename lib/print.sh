# Colors
cNc='\033[0m'
cRed='\033[0;31m'
cBlue='\033[0;34m'
cGreen='\033[0;32m'
cYellow='\033[0;33m'
cCyan='\033[0;36m'

# Task
function printTask() {
    printf "${cBlue}Task:${cNc} $1\n"
}

# Info
function printInfo() {
    printf "${cCyan}Info:${cNc} $1\n"
}

# Tip
function printTip() {
    printf "${cGreen}Tip:${cNc} $1\n"
}

# Success
function printSuccess() {
    printf "${cGreen}Success:${cNc} $1\n"
}

# Error
function printError() {
    printf "${cRed}Error:${cNc} $1\n"
}

# Warn
function printWarn() {
    printf "${cYellow}Warning:${cNc} $1\n"
}
