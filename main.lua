WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

push = require 'push'


-- initiate the game
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    player1score = 0
    player2score = 0

    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
    
    gameState = 'start'

    resetBall()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        vsync = true,
        resizable = false
    })
end


function love.update(dt)
    -- movement for left paddle
    if love.keyboard.isDown('w') then
        player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    end

    -- movement for right paddle
    if love.keyboard.isDown('up') then
        player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end



function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' or key =='enter' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'start'
            resetBall()
        end
    end
end


function love.draw()


    push:apply('start')                 -- eveything written after this is done the 'push' way

    -- draw the background color
    love.graphics.clear(62/255, 53/255, 65/255, 225/255)

    -- draw ball
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)
    --draw left paddle
    love.graphics.rectangle('fill', 5, player1Y, 5, 20)
    --draw right paddle
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    -- set title font
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf(
            'Hello Pong',               -- the text that appears on the screen
            0,                          -- starting X 
            20,                         -- starting Y (halfway down the screen ( the -6 is to account for half the font's size))
            VIRTUAL_WIDTH,              -- the number of pixels we want the text to be centered within 
            'center')                   -- alignment mode, can be 'center' 'left' 'right' etc.
    elseif gameState == 'play' then
        love.graphics.printf(
            'Play state',               
            0,                          
            20,                         
            VIRTUAL_WIDTH,              
            'center')                  
    end
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(player2score, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)

    push:apply('end')                   -- ends the 'push' way of writing things
end


-- centers the ball on the screen and gives it a random  speed
function resetBall()
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2
    --[[ this code doesnt work but it is explaining what the below line does
    ballDX = math.random(2)
    if ballDX == 1 then
        ballDX = -100
    else
        ballDX = 100
    end
    ]]
    ballDX = math.random(2) == 1 and -100 or 100
    ballDY = math.random(-50, 50)
end
