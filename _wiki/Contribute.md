Thank you for thinking about contributing! Help is always welcome.

- [Join the project](#join-the-project)
- [Editor](#editor)
  - [Extensions](#extensions)
  - [Settings](#settings)
- [Check before a pull request](#check-before-a-pull-request)
- [Clean code](#clean-code)
  - [Markdown - MarkdownLint](#markdown---markdownlint)
  - [Shell - ShellCheck](#shell---shellcheck)
  - [Best Practices](#best-practices)
- [Useful config files](#useful-config-files)

## Join the project

Here are the first steps to your first contributions. You can either use the command line or GitHub Desktop:

- [GitHub - First Contributions](https://github.com/firstcontributions/first-contributions)
- [GitHub Desktop - First Contributions](https://github.com/firstcontributions/first-contributions/blob/master/gui-tool-tutorials/github-desktop-tutorial.md)

## Editor

We use [![Visual Studio Code](https://img.shields.io/badge/Visual_Studio_Code-0078D4?style=flat-square&logo=visual%20studio%20code&logoColor=white)](https://code.visualstudio.com/) to develop this project.

### Extensions

Mandatory extensions:

- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)

Some other useful extensions:

- [Guides](https://marketplace.visualstudio.com/items?itemName=spywhere.guides)
- [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)
- [Trailing Spaces](https://marketplace.visualstudio.com/items?itemName=shardulm94.trailing-spaces)

### Settings

Visual Studio Code generates a custom file inside repositories (`.vscode/settings.json`) for settings regarding the IDE and extensions. If you want, you can use our settings:

```js
{
    // Global > Ruller
    "workbench.colorCustomizations": {
        "editorRuler.foreground": "#333" // rulers color
    },
    // Global > EOL > LF
    "files.eol": "\n",
    // shellscript
    "[shellscript]": {
        // Ruller
        "editor.rulers": [
            80, // Terminal windows
            125 // GitHub diff view
        ],
        // Tab
        "editor.insertSpaces": true,
        "editor.tabSize": 4,
        // EOL > LF
        "files.eol": "\n"
    },
    // Extension - markdownlint > https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
    "markdownlint.config": {
        "default": true,
        "MD033": false, // https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md033
        "MD036": false, // https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md036
        "MD041": false  // https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md041
    },
    // Extension - shellcheck > https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck
    "shellcheck.customArgs": [
        "-x" // https://github.com/koalaman/shellcheck/wiki/SC1091
    ],
    "shellcheck.exclude": [
        "1090", // https://github.com/koalaman/shellcheck/wiki/SC1090
        "1091", // https://github.com/koalaman/shellcheck/wiki/SC1091
        "2009", // https://github.com/koalaman/shellcheck/wiki/SC2009
        "2034", // https://github.com/koalaman/shellcheck/wiki/SC2034
        "2039", // https://github.com/koalaman/shellcheck/wiki/SC2039
        "2154", // https://github.com/koalaman/shellcheck/wiki/SC2154
        "3057", // https://github.com/koalaman/shellcheck/wiki/SC3057
        "3060"  // https://github.com/koalaman/shellcheck/wiki/SC3060
    ],
    // Extension - Todo Tree > https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree
    "todo-tree.general.tags": [
        "FIXME",
        "TODO",
        "WARN"
    ]
    // Extension - Guides > https://marketplace.visualstudio.com/items?itemName=spywhere.guides
    // Extension - shell-format > https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format
    // Extension - Trailing Spaces > https://marketplace.visualstudio.com/items?itemName=shardulm94.trailing-spaces
}
```

## Check before a pull request

Before doing a pull request, please check that everything is still working, and that your development is clean and has comments.

You can use tools like [![WinMerge](https://img.shields.io/badge/WinMerge-yellow?style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAALiUExURTB9v////+/y9n+w2+by/N/t+9nr+9Ln+svj+cHc87jT7a3L5qLC3Zq51OHh4U19pm2i0oy33e32/c7l+cHe97PX9aXP85jI8YS552+n2VuXzUSDuZaxyJWqvC12tL3X7PX5/u72/Z64zUJ0nl6bzs3g8fr9/+nz/dvs+s/m+ViSx6a90oaes4243czf8r5fYt/v+z1zoUWKxpK7350IDapNUC55uev0/b3M2nqYsKggIerHxKVQUCFSiff39+Hv+7DG2VF/prK/zFyCo5aWlq8sI/js7Nqdm14iKtPS0/b396q/08bKzU9ic3B7hX9/f/Xl4/HW0c15cKNIQcni+H+So2BygnCElba2trEnE7c3JO3NyPPe2+e5rtWKf40uCqtnANiUAOCcAOCZANqXAM+OAL2DAMKHAO3t7bs+I+i8s+SsnMttXa1WOdLLsvTv0fz32MJJJvDRyOe0pOezo+Cdh+Cbh9aCatDGn/Ppu/vxweGmAMlTJ/HLu+mvleeni+eoi+KVdNNoSqM6C8tYAPd+AP+FAP+CAPTRP89dKOyuiOOKUuaVY+edbuqkeOKJWN10QuB/QddmJaNPGpyJOtnCUfDWWfDXWeGvANVnKvC2gOeKMuV/HuBmGOBwGos5C0kyBqVhAOeFAP+WAP+TAPDZbuG1ANtwKPTAde+iNO6dJO+dJO+bJOuHHaJWG1pQL42BTMi3bOjVfvHcguO7BeF2Jt9uGPW8LPa/NvKqH+2fI5NHD4VwGL2fIty5JuO/KOK+J3BwcOeBKvzme/vcP6tlKT1DSGJsdI2bpqm2wrbAyrzEysLHy+2LLv76iodMHF9dXH6lyJrF66jQ9LHV9bnZ9tfp+uvz+/GRLLh7OhEmN5WVlfH4/vSPH8qNR2FgXxxJcLXU7oC774i/75DE8aHN8+qrXo6Niyhon7fY9r7c98bh+OPw+2iu63Gz7Xm37avS9Fel6V2n67rb98Pf9wAAAOGw/W4AAAD2dFJOU///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AEo/IKkAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAJUSURBVDhPY/hKACAUMKACqCiyAkYEYGJghkkgK2BhZWPn4OTi5uHl4xcQhMogKxASFhEVE5eQlJKWkZWTh6pAVqCgCDNDiU9ZRRWiAlmBmrqGJsQMLW0dBl09sAqoAn2QAkY1oBkGYDO0+QyNjMEqoApMTL+agRSYs0LcIWBhyWBkZKTCAFNgZW1jawf0H9AMdXsNoBkOfAyOTk7ODC5QBa5u7h6eXiAF6qxgdzB78/n4+lkw+MMUBAQGBYNUwMwIcQgNCwuPACqIjAKB6Bjr2Lj4hMSkZBBISkpOSklNS0/NACrIDISArOzYnNy8/AJkkMQIVFBYFFsMBCXZpdll5bkVlVVIoBqkoKa2rr6+ob6+vrGhsb6puaW1rb29va2tDYg7wAo6u7q7e3r7+vr6eyZMnDR5ytRp06dPmzZtOhBOmwFSMHPW7DlgMHfO3HnzFyxctHjx4iUgvGTJ0mUgBctXrFy1etWaNavWrpm3bv2GjZs2I8AWkIJ5W+dt27Zt+47tO3ftXrBn7779B/YfOADGQBKk4KvLQSA4dPjIzqPHjp846XTq1OnTZ874+PicOXP6NFgBGJw913H+QvjFS5evXBUJEb7GymIudF2dRQih4Mbhm7duK3GGCLNf02C1Z1EXuqOgoHDnDkLB3Xv3H3g+fPT4ifhTsCHsbKwsLCxICp49d3lh9/LqK5HXEEPeAO24g2wCEJgxXnn77j2yIQaKKAoYGD9cEUUzBE3B5Y+f3sIM+XDl8xcOdTQFYpc/oBmCpgALQFGAFSAp+OqPBfj7AwB9xPbYOIb0FQAAAABJRU5ErkJggg==)](https://winmerge.org/) to check every modification.

## Clean code

The principles of [Clean Code](https://www.pearson.com/us/higher-education/program/Martin-Clean-Code-A-Handbook-of-Agile-Software-Craftsmanship/PGM63937.html) apply to Bash as well. It really helps in having a robust script.

> Many people hack together shell scripts quickly to do simple tasks, but these soon take on a life of their own. Unfortunately shell scripts are full of subtle effects which result in scripts failing in unusual ways. It’s possible to write scripts which minimise these problems.

*[source](https://www.davidpashley.com/articles/writing-robust-shell-scripts/)*

### Markdown - MarkdownLint

It's a bit useless, but well, if we are trying to do robust code, why not have robust Markdown too?

We are using [MarkdownLint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint). Please try to have 0 warnings and/or errors.

I did remove some rules because they are too restrictive for a good looking ReadMe on GitHub:

- [MD033](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md033): As you know, Markdown can't center elements. Because of this, we are using HTML instead.
- [MD036](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md036): Without removing it you can't do `**Lorem ipsum dolor sit amet**`.
- [MD041](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md041): We are using HTML header because it's sexy instead of the classic `# AFK-Daily`.

### Shell - ShellCheck

We are using [ShellCheck](https://github.com/koalaman/shellcheck). Please try to have 0 warnings and/or errors.

If you need to remove rules, please be certain that is your only choice. Here the list of the already removes rules:

- [1090](https://github.com/koalaman/shellcheck/wiki/SC1090): Can't follow non-constant source
- [1091](https://github.com/koalaman/shellcheck/wiki/SC1091): Not following (Source not found) -> link to the previous one
- [2009](https://github.com/koalaman/shellcheck/wiki/SC2009): `pgrep` doesn't exixts in Git Bash
- [2034](https://github.com/koalaman/shellcheck/wiki/SC2034): `foo` appears unused. Verify it or export it
- [2154](https://github.com/koalaman/shellcheck/wiki/SC2154): var is referenced but not assigned -> link to the previous one
- [3057](https://github.com/koalaman/shellcheck/wiki/SC3057): In POSIX `sh`, string indexing is undefined (Well, it works)
- [3060](https://github.com/koalaman/shellcheck/wiki/SC3060): In POSIX `sh`, string replacement is undefined (Well, it works)

### Best Practices

Here is the [source](https://www.javacodegeeks.com/2013/10/shell-scripting-best-practices.html) of our best practices. We edited some of it for more portability and maintainability.

1. Use functions

    > Unless you’re writing a very small script, use functions to modularise your code and make it more readable, reusable and maintainable.

    ```sh
    myfunc() {
        if [ $DEBUG -ge 3 ]; then echo "[DEBUG] myfunc" >&1; fi
    }
    ```

    If you want more info: [source](https://unix.stackexchange.com/questions/73750/difference-between-function-foo-and-foo).

2. Document your functions

    > Add sufficient documentation to your functions to specify what they do and what arguments are required to invoke them.

    Please complete this comment to explain every function:

    ```sh
    # ##############################################################################
    # Function Name  : myfunc
    # Description    : Test function
    # Args           :
    # Return         :
    # Remark         :
    # ##############################################################################
    myfunc() {
        if [ $DEBUG -ge 3 ]; then echo "[DEBUG] myfunc" >&1; fi
        test 800 600            # do test
    }
    ```

    Or at least:

    ```sh
    # myfunc <Args>
    # description if not explicit name
    # return values
    myfunc() {
        if [ $DEBUG -ge 3 ]; then echo "[DEBUG] myfunc" >&1; fi
        test 800 600            # do test
    }
    ```

    - Try to comment everything, every click, condition, loop. It really helps maintain the code.
    - Try to align comments, it helps for the visibility of them.

3. ~~Use `shift` to read function arguments~~
4. *Declare your variables*

    Instead of `local`, prefix your variable with the name of the function (`local` is undefined in `sh`).

    ```sh
    myfunc() {
        _myfunc_local=0
    }
    ```

5. Quote all parameter expansions

    > To prevent word-splitting and file globbing you must quote all variable expansions. In particular, you must do this if you are dealing with filenames that may contain whitespace (or other special characters).

6. ~~Use arrays where appropriate~~
7. Use `"$@"` to refer to all arguments

    > Don’t use `$*`.

    The only exception is a direct output like in Debug (`$@` is an array where `$*` is a string).

8. Use uppercase variable names for environment variables only

    > My personal preference is that all variables should be lowercase, except for environment variables.

9. Prefer shell builtins over external programs

    > The shell has the ability to manipulate strings and perform simple arithmetic...

10. Avoid unnecessary pipelines

    > Pipelines add extra overhead to your script so try to keep your pipelines small. Common examples of useless pipelines are `cat` and `echo`...

11. ~~Avoid parsing ls~~
12. ~~Use globbing~~
13. ~~Use null delimited output where possible~~
14. Don’t use backticks

    > Use `$(command)` instead of `` `command` `` because it is easier to nest multiple commands and makes your code more readable.

15. ~~Use process substitution instead of creating temporary files~~
16. Use `mktemp` if you have to create temporary files

    > Try to avoid creating temporary files. If you must, use `mktemp` to create a temporary directory and then write your files to it. Make sure you remove the directory after you are done.

17. ~~Use [[ and (( for test conditions~~

    > Note that if you desire portability, you have to stick to the old-fashioned `[ ... ]`

    If you want more info: [source](https://unix.stackexchange.com/questions/382003/what-are-the-differences-between-and-in-conditional-expressions).

18. Use commands in test conditions instead of exit status

    > If you want to check whether a command succeeded before doing something, use the command directly in the condition of your if-statement instead of checking the command’s exit status.

19. ~~Use set -e~~
20. Write error messages to stderr

    > Error messages belong on stderr not stdout.

    ```sh
    echo "[ERROR]" >&2
    ```

Some other useful documentation:

- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line#the-art-of-command-line)
- [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible#pure-bash-bible)

*If you have any doubt, just ask, there will always be someone to answer (well, I hope so)!*

## Useful config files

<details>
  <summary>config-Debug.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=false
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=0
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedGoldOffer=false
buyStoreLimitedDiamOffer=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=true
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Test_Campaign.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=10
maxKingsTowerFights=0
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedGoldOffer=false
buyStoreLimitedDiamOffer=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=true
doChallengeBoss=true
doFastRewards=true
doCollectFriendsAndMercenaries=true

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Test_Dark_Forest.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=10
totalAmountArenaTries=2+6+2
totalAmountTournamentTries=5
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedGoldOffer=false
buyStoreLimitedDiamOffer=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=true
doTeamBounties=true
doArenaOfHeroes=true
doLegendsTournament=true
doKingsTower=true

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Test_Ranhorn.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=true

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=0
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=3
totalAmountTwistedRealmBossTries=3

# Store
buyStoreDust=true
buyStorePoeCoins=true
buyStorePrimordialEmblem=true
buyStoreAmplifyingEmblem=true
buyStoreSoulstone=true
buyStoreLimitedGoldOffer=true
buyStoreLimitedDiamOffer=true
buyWeeklyGuild=true
buyWeeklyLabyrinth=true

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=true
doTwistedRealmBoss=true
doBuyFromStore=true
doStrengthenCrystal=true
doTempleOfAscension=true
doCompanionPointsSummon=true
doCollectOakPresents=true

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Test_End.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=0
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedGoldOffer=false
buyStoreLimitedDiamOffer=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=true
doCollectMail=true
doCollectMerchantFreebies=true

```

</details>

<!-- <hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Contribute">Previous page</a>
</div> -->
