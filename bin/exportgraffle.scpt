on writeCanvas(theGraffleFile, exportFolder, theCanvases)
	tell application "OmniGraffle"
	     	-- this next call blocks, need to update omnigraffle?
		open file theGraffleFile as POSIX file
		activate
		
		set myWindow to front window
		set myDoc to document of myWindow
		
		set exportType to "EPS"
		set exportFileExtension to "eps"

		set include border of current export settings to false
		set copy linked images of current export settings to false
		set area type of current export settings to selected graphics
		set draws background of current export settings to false
		--set export scale to "100.0" -- not sure of what a 'real' is applescript - a decimal?

		if (count of theCanvases) = 0 then
		   repeat with theCvn in canvases of myDoc
		   	  set theCanvases to theCanvases & (name of theCvn)
		   end repeat
		end if
		
		repeat with theCanvas in theCanvases
			set canvas of front window to canvas theCanvas of myDoc
			set exportFileName to (exportFolder as string & "/" & theCanvas & "." & exportFileExtension) as POSIX file
			save myDoc in exportFileName
		end repeat

		tell myWindow to close
	end tell
	-- tell application "Finder"
	--         set visible of process "OmniGraffle" to false
	-- end tell
end writeCanvas

on run argv
    set usage to "usage: exportgraffle.scpt <OmniGraffle file> <output dir> [canvas1] [canvasN...]"
    if (count argv) < 2 then
       return usage
    end if
    set theGraffleFile to item 1 of argv
    set exportFile to item 2 of argv
    set theCanvases to {}
    repeat with i from 3 to count of argv
    	   set theCanvases to theCanvases & item i of argv
    end repeat
    writeCanvas(theGraffleFile, exportFile, theCanvases)
end run
