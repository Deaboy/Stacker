require "constants"

function love.conf(t)
  t.version = "0.9.1"
  t.console = false
  
  t.window.title = "STACKER!"
  t.window.width = BLOCK_SIZE * BOARD_WIDTH
  t.window.height = BLOCK_SIZE * BOARD_HEIGHT
  t.window.borderless = false
  t.window.resizable = false
  
  t.modules.joystick = false
  t.modules.physics = false
end
