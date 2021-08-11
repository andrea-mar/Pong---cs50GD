WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'


-- initialize the game
function love.load()
    love.window.setTitle('Pong')
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    -- initialize score at the start of the game
    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPlayer = 0
    
    paddle1 = Paddle(10, 30, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

    gameState = 'start'
    -- start with the ball in the center of the screen
    ball:reset()
    
    
    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        vsync = true,
        resizable = false
    })
end


function love.update(dt)
    if gameState == 'play' then
        -- keep score player1/paddle1 
        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1score = player1score + 1
            servingPlayer = 2
            ball:reset()
            ball.dx = -100
            if player1score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end
        -- keep score player2/paddle2 
        if ball.x <= 0 then
            player2score = player2score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = 100
            if player2score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end
        
        if ball:collides(paddle1) then
            -- deflect ball to the right
            ball.dx = - ball.dx
        end

        if ball:collides(paddle2) then
            -- deflect ball to the left
            ball.dx = - ball.dx
        end

        -- deflect ball down if it touches top edge
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
        end

        -- deflect ball up if it touches bottom edge
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
        end
    end

    -- movement for left paddle
    paddle1:update(dt)
    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    -- movement for right paddle
    paddle2:update(dt)
    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end

    -- movement for the ball (only in play state)
    if gameState == 'play' then
        ball:update(dt)
    end
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' or key =='enter' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end


function love.draw()
    push:apply('start')                 -- eveything written after this is done the 'push' way

    -- draw the background color
    love.graphics.clear(62/255, 53/255, 65/255, 225/255)

    displayFPS()

    -- draw ball
    ball:render()

    --draw left paddle
    paddle1:render()
    
    --draw right paddle
    paddle2:render()

    -- set title font 
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf(
            'Welcome to Pong',              -- the text that appears on the screen
            0,                              -- starting X 
            20,                             -- starting Y (halfway down the screen ( the -6 is to account for half the font's size))
            VIRTUAL_WIDTH,                  -- the number of pixels we want the text to be centered within 
            'center')                       -- alignment mode, can be 'center' 'left' 'right' etc.
        love.graphics.printf('Press Enter to Play', 0, 32, VIRTUAL_WIDTH,'center')  
    elseif gameState == 'serve' then
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s turn.", 0, 20, VIRTUAL_WIDTH,'center')  
        love.graphics.printf('Press Enter to Serve', 0, 32, VIRTUAL_WIDTH,'center')  
    elseif gameState == 'play' then
        -- no message to display in play state
    elseif gameState == 'victory' then
        -- draw a victory message
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player ".. tostring(winningPlayer).." wins.", 0, 10, VIRTUAL_WIDTH,'center')  
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Play Again', 0, 42, VIRTUAL_WIDTH,'center')  
    end

    -- set score font 
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(player2score, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)

    push:apply('end')                   -- ends the 'push' way of writing things
end


function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 4)
    love.graphics.setColor(1, 1, 1, 1)
end
