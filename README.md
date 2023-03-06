# localizedCleaner

Localized cleaner is a script built with Swift. The script will scan the Localizable.strings file in your project and then check if any of your Swift files contains any of the localized strings. Right now, the script only scans for Swift files but it could easily be updated to also check for .m files (Objective-C files). 

# How to use? 

1. Download the Swift script 
2. Add it to your project. (This script can live in any directory but make sure you update the projectPath variable accordingly.) 
3. Open terminal, enter ./localizedCleaner and press enter.

# Optional arguments

-h or --help: Prints help information about possible arguments and how to use them.

-d or --delete: Delete unused localized strings found.

-u or --unused: Print all unused localized strings found.

# WIP

The delete functionality is still work in progress.
