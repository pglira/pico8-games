function is_wall(x, y)
    return mget(x / 8, y / 8) == 002
end

function is_goal(x, y)
    return mget(x / 8, y / 8) == 003
end

function is_stinky(x, y)
    return x == x_stinky and y == y_stinky
end

function get_dxy_from_direction(direction)
    if direction == 0 then
        dx = -8
        dy = 0
    end
    if direction == 1 then
        dx = 8
        dy = 0
    end
    if direction == 2 then
        dx = 0
        dy = 8
    end
    if direction == 3 then
        dx = 0
        dy = -8
    end
    return dx, dy
end

function start()

    -- start positions
    x_person = 8
    y_person = 8

    x_stinky = 14 * 8
    y_stinky = 1 * 8
    dx_stinky = -8
    dy_stinky = 0

    dframe = 0

    is_playing = true

end

function _init()
    start()
end

function _update()

    dframe = dframe + 1

    if is_playing then

        -- update stinky position
        if dframe == 15 then
            dx_stinky_current = dx_stinky
            dy_stinky_current = dy_stinky
            direction = flr(rnd(4))
            dx_stinky, dy_stinky = get_dxy_from_direction(direction)
            while is_wall(x_stinky + dx_stinky, y_stinky + dy_stinky) do
                direction = flr(rnd(4))
                dx_stinky, dy_stinky = get_dxy_from_direction(direction)
            end
            x_stinky = x_stinky + dx_stinky
            y_stinky = y_stinky + dy_stinky
            dframe = 0
        end

        -- meet stinky?
        if is_stinky(x_person, y_person) then
            message = "You lost!"
            is_playing = false
        end

        -- found treasure?
        if is_goal(x_person, y_person) then
            message = "You won!"
            is_playing = false
        end

        -- left
        if btnp(0) then
            if not is_wall(x_person - 8, y_person) then
                x_person = x_person - 8
            end
        end

        -- right
        if btnp(1) then
            if not is_wall(x_person + 8, y_person) then
                x_person = x_person + 8
            end
        end

        -- down
        if btnp(2) then
            if not is_wall(x_person, y_person - 8) then
                y_person = y_person - 8
            end
        end

        -- up
        if btnp(3) then
            if not is_wall(x_person, y_person + 8) then
                y_person = y_person + 8
            end
        end

    else

        if dframe == 60 then
            start()
        end

    end

end

function _draw()
    cls()
    map(0, 0, 0, 0, 16, 16)
    spr(009, x_person, y_person)
    spr(007, x_stinky, y_stinky)
    if is_playing then
        -- debug
        -- print("x_person = " .. x_person, 0)
        -- print("y_person = " .. y_person, 0)
        -- print("x_stinky = " .. x_stinky, 0)
        -- print("y_stinky = " .. y_stinky, 0)
    else
        rectfill(0, 60, 128, 68, 0)
        print(message, 46, 62, 7)
    end
end
