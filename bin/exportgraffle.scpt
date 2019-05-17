on writeCanvas(theGraffleFile, exportFolder, theCanvases)
	tell application "OmniGraffle"
		-- this next call blocks, need to update omnigraffle?
		open file theGraffleFile as POSIX file
		activate

		-- If you get an error about myDoc variable not being set, try enabling a delay here
		-- delay .5
		set myWindow to front window
		set myDoc to document of myWindow

		set exportType to "com.adobe.encapsulated-postscript"
		set exportFileExtension to "eps"

		set exportProperties to {includeborder:false, copylinkedimages:false, drawsbackground:false}

		if (count of theCanvases) = 0 then
			repeat with theCvn in canvases of myDoc
				set theCanvases to theCanvases & (name of theCvn)
			end repeat
		end if

		repeat with theCanvas in theCanvases
			set canvas of front window to canvas theCanvas of myDoc
			set exportFileName to ((exportFolder as string) & "/" & theCanvas & "." & exportFileExtension) as POSIX file
			-- If content is still missing from the exported images, try enabling and adjusting the delay here
			delay 0.1
			export myDoc as exportType scope all graphics to exportFileName with properties exportProperties
		end repeat

		tell myWindow to close
	end tell
	-- tell application "Finder"
	-- set visible of process "OmniGraffle" to false
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
