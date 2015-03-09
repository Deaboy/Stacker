require "constants"

-- Initialize game
running = false
level = 1
blocks = 3
pos = math.floor(BOARD_WIDTH / 2) - math.floor(blocks / 2)
left = true
timer = 0
atimer = 0
board = {}

-- Initialize board
for i = 1,BOARD_HEIGHT do
  board[i] = {}
  for j = 1,BOARD_WIDTH do
    board[i][j] = 0
  end
end


-- Initialize the game
function love.load()
  
  -- set background color
  love.graphics.setBackgroundColor(unpack(BOARD_COLOR))
  love.graphics.setColor(unpack(BLOCK_COLOR))
  
  -- Set up board with predefined pattern
  for i=1,7 do
    board[i][3] = 1
  end
  for i=1,5 do
    board[i][4] = 1
  end
  for i=1,3 do
    board[i][5] = 1
  end
  
end


-- Update game on step
function love.update(dt)
  -- regulate frame rate by game speed
  if dt < 1/60 then
    love.timer.sleep(1/60 - dt)
  end
  
  -- Decrement the animation timer
  if atimer > 0 then
    atimer = atimer - 1
    
    if atimer == 0 then
      
      -- Remove temporary (flashing) blocks
      for i=1,BOARD_HEIGHT do
        for j=1,BOARD_WIDTH do
          if board[i][j] == 2 then
            board[i][j] = 0
          end
        end
      end
      
      -- Check game over condition
      if blocks == 0 then
        running = false
      end
    end
  end
  
  -- move blocks over
  if running and atimer == 0 then
    if timer <= 0 then
      if left then
        pos = pos - 1
        if pos + blocks-1 == 1 then
          left = false
        end
      else
        pos = pos + 1
        if pos == BOARD_WIDTH then
          left = true
        end
      end
      timer = (MAX_SPEED + ((MIN_SPEED - MAX_SPEED) * (1 - (level / BOARD_HEIGHT)))) * 60
    else
      timer = timer - 1
    end
  end
  
end

function love.keypressed(key, isrepeat)
  
  if key == " " and running then
    -- put blocks onto board
    for i = pos,(pos+blocks-1) do
      if i >= 1 and i <= BOARD_WIDTH then
        board[level][i] = 1
      else
        blocks = blocks - 1
        atimer = ANIMATION_TIME
      end
    end
    
    -- Remove invalid blocks
    if level > 1 then
      for i = 1,BOARD_WIDTH do
        if board[level][i] == 1 and board[level-1][i] == 0 then
          board[level][i] = 2
          blocks = blocks - 1
          atimer = ANIMATION_TIME
        end
      end
    end
    
    -- Check hard limits
    if blocks >= 3 and level >= LIMIT_3 then
      blocks = 2
    end
    if blocks >= 2 and level >= LIMIT_2 then
      blocks = 1
    end
    
    level = level + 1
    pos = math.floor(BOARD_WIDTH / 2)
  end
  
  
  -- Handle reset key
  if key == "return" then
    -- Initialize board
    for i = 1,BOARD_HEIGHT do
      for j = 1,BOARD_WIDTH do
        board[i][j] = 0
      end
    end
    
    -- Reset everything else
    level = 1
    blocks = 3
    pos = math.floor(BOARD_WIDTH / 2) - math.floor(blocks / 2)
    left = true
    running = true
  end
  
  
  -- Handle quit game
  if key == "escape" then
    love.event.quit()
  end
end


function love.draw()
  
  love.graphics.setBackgroundColor(unpack(BOARD_COLOR))
  love.graphics.setColor(unpack(BLOCK_COLOR))
  
  -- Draw stationary blocks
  for i=1,BOARD_HEIGHT do
    for j=1,BOARD_WIDTH do
      if board[i][j] == 1 or (board[i][j] == 2 and atimer > 0 and (atimer % (60 / 2)) < (60/4)) then
        love.graphics.rectangle(
          "fill",
          (j-1) * BLOCK_SIZE + BLOCK_PADDING,
          (BOARD_HEIGHT-i) * BLOCK_SIZE + BLOCK_PADDING,
          BLOCK_SIZE - (2 * BLOCK_PADDING),
          BLOCK_SIZE - (2 * BLOCK_PADDING)
        )
      end
        
    end
  end
  
  -- Draw bouncing blocks
  if running and atimer == 0 then
    for j=pos,(pos+blocks-1) do
      if j >= 1 and j <= BOARD_WIDTH then
        love.graphics.rectangle(
          "fill",
          (j-1) * BLOCK_SIZE + BLOCK_PADDING,
          (BOARD_HEIGHT-level) * BLOCK_SIZE + BLOCK_PADDING,
          BLOCK_SIZE - (2 * BLOCK_PADDING),
          BLOCK_SIZE - (2 * BLOCK_PADDING)
        )
      end
    end
  end
  
  
  -- Draw minor prize marker
  love.graphics.setColor(unpack(MINOR_PRIZE_COLOR))
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle("rough")
  love.graphics.rectangle(
    "line",
    0 + 1,
    (BOARD_HEIGHT - MINOR_PRIZE_LEVEL) * BLOCK_SIZE + 1,
    BOARD_WIDTH * BLOCK_SIZE - 2,
    BLOCK_SIZE - 2
  )
  love.graphics.printf(MINOR_PRIZE_TEXT,
    0 + 1,
    (BOARD_HEIGHT - MINOR_PRIZE_LEVEL) * BLOCK_SIZE + 8 + 1,
    BOARD_WIDTH * BLOCK_SIZE - 2,
    "center"
  )
  
  -- Draw major prize marker
  love.graphics.setColor(unpack(MAJOR_PRIZE_COLOR))
  love.graphics.setLineWidth(2)
  love.graphics.setLineStyle("rough")
  love.graphics.rectangle(
    "line",
    0 + 1,
    (BOARD_HEIGHT - MAJOR_PRIZE_LEVEL) * BLOCK_SIZE + 1,
    BOARD_WIDTH * BLOCK_SIZE - 2,
    BLOCK_SIZE - 2
  )
  love.graphics.printf(MAJOR_PRIZE_TEXT,
    0 + 1,
    (BOARD_HEIGHT - MAJOR_PRIZE_LEVEL) * BLOCK_SIZE + 8 + 1,
    BOARD_WIDTH * BLOCK_SIZE - 2,
    "center"
  )
  
  -- Display help
  if running == false then
    love.graphics.setColor(unpack(HELP_BACKGROUND_COLOR))
    love.graphics.rectangle(
      "fill",
      0,
      (BOARD_HEIGHT - 3) * BLOCK_SIZE,
      BOARD_WIDTH * BLOCK_SIZE,
      BLOCK_SIZE * 3
    )
    
    love.graphics.setColor(unpack(HELP_TEXT_COLOR))
    love.graphics.printf(HELP_TEXT,
      4,
      (BOARD_HEIGHT - 3) * BLOCK_SIZE + 12,
      BOARD_WIDTH * BLOCK_SIZE - 8,
      "center"
    )
  end
end
