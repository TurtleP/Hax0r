io.stdout:setvbuf("no")
function love.conf(t)
	t.console = false
	t.version = "0.10.0"
	t.window.icon = "graphics/icon.png"
	t.window.title = "Hax0r"
	t.window.fullscreen = true
	t.window.fullscreentype = "desktop"
	t.window.borderless = true
end
