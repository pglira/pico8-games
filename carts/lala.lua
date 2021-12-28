function start()
    -- paddle
    padx = 52
    pady = 122
    padw = 24
    padh = 1

    -- ball
    ballx = 64
    bally = 64
    ballradius = 2
    ballxdir = 2
    ballydir = -1

    score = 0
    lives = 3

    is_playing = true
    is_dead = false
    is_gameover = false
end

function movepaddle()
    if btn(0) then
        padx = padx - 2
    elseif btn(1) then
        padx = padx + 2
    end

    -- stop at margins
    if padx < 0 then
        padx = 0
    end
    if padx > 128 - padw then
        padx = 128 - padw
    end
end

function moveball()
    ballx = ballx + ballxdir
    bally = bally + ballydir
end

function losedeadball()
    if bally > 128 - ballradius then
        if lives > 0 then
            -- next life
            sfx(3)
            ballx = 64
            bally = 10
            lives = lives - 1
            frames_since_dead = 0
            is_playing = false
            is_dead = true
        else
            -- game over
            is_playing = false
            is_dead = true
            is_gameover = true
        end
    end
end

function bounceball()
    -- left
    if ballx < ballradius then
        ballxdir = -ballxdir
        sfx(0)
    end
    -- right
    if ballx > 128 - ballradius then
        ballxdir = -ballxdir
        sfx(0)
    end
    -- top
    if bally < ballradius then
        ballydir = -ballydir
        sfx(0)
    end
end

-- bounce the ball off the paddle
function bouncepaddle()
    if ballx >= padx and ballx <= padx + padw + 2 and bally + ballradius == pady then
        sfx(1)
        score = score + 10
        if score % 100 == 0 then
            sfx(3)
        end
        ballydir = -ballydir
        increaseballspeed()
    end
end

function increaseballspeed()

    if score <= 400 and score % 100 == 0 then

        -- increase speed by 1 in both directions
        ballxdir = ballxdir / abs(ballxdir) * (abs(ballxdir) + 1)
        ballydir = ballydir / abs(ballydir) * (abs(ballydir) + 1)

    end

end

function restart()
    if btnp(4) then
        start()
    end
end

function _init()
    start()
end

function _update()
    if is_playing then
        movepaddle()
        bounceball()
        bouncepaddle()
        moveball()
        losedeadball()
    elseif not is_gameover and is_dead then
        frames_since_dead = frames_since_dead + 1
        if frames_since_dead % 60 == 0 then
            is_dead = false
            is_playing = true
        end
    else
        restart()
    end
end

function _draw()
    -- clear the screen
    -- rectfill(0, 0, 128, 128, 2)
    map()

    -- draw the score
    print(score, 8, 6, 15)

    -- draw the lives
    for i = 1, lives do
        spr(004, 90 + i * 8, 4)
    end

    -- draw the paddle
    rectfill(padx, pady, padx + padw, pady + padh, 14)

    -- draw the ball
    circfill(ballx, bally, ballradius, 15)

    -- print debug info
    -- print("ballx = " .. ballx)
    -- print("bally = " .. bally)
    -- print("ballxdir = " .. ballxdir)
    -- print("ballydir = " .. ballydir)
    -- print("padx = " .. padx)

    if is_gameover then
        print("game over - press button", 16, 64, 7)
    end
end
