on showPreview(filename, x, y, width, height)
    log "update preview"
    tell application "Preview"
         -- disable for now since command line open is faster under Mojave
         -- log "opening file: " & filename
       	 -- open filename
	 activate
	 log "set screen bounds: x=" & x & ", y=" & y & ", width=" & width & ", height=" & height
    	 set theBounds to {x, y, width, height}
    	 set the bounds of the window 1 to theBounds
    end tell
    log "zoom reset via system events"
    tell application "System Events"
    	 tell process "Preview"
	 	 click menu item "Single Page" of menu "View" of menu bar 1
	 	 click menu item "Continuous Scroll" of menu "View" of menu bar 1
	 end tell
    end tell
    tell application "Emacs" to activate
end showPreview

on run argv
    set usage to "usage: showpreview.scpt file.pdf topX topY width hight"
    if (count argv) < 5 then
       return usage
    end if
    set filename to item 1 of argv
    set topX to item 2 of argv
    set topY to item 3 of argv
    set width to item 4 of argv
    set height to item 5 of argv
    showPreview(filename, topX, topY, width, height)
end run
