-- jojo
-- by philippus
actor = {} -- all actors

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function make_actor(k, x, y)
    a = {
        k = k, -- sprite number
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        frame = 0,
        t = 0,
        friction = 0.15,
        bounce = 0.3,
        frames = 2, -- number of frames to alter during movement

        -- hit box of actor
        -- half-width and half-height
        -- slightly less than 0.5 so
        -- that will fit through 1-wide
        -- holes.
        w = 0.4,
        h = 0.4
    }

    add(actor, a)

    return a
end

function _init()

    -- create some actors

    -- make player
    pl = make_actor(0, 2, 2)
    pl.frames = 3
    pl.has_yellow_key = false
    pl.has_green_key = false

    -- bouncy ball
    local ball = make_actor(32, 8.5, 11)
    ball.dx = 0.05
    ball.dy = -0.1
    ball.friction = 0.02
    ball.bounce = 1

    -- red ball: bounce forever
    -- (because no friction and
    -- max bounce)
    local ball = make_actor(48, 7, 8)
    ball.dx = -0.1
    ball.dy = 0.15
    ball.friction = 0
    ball.bounce = 1

    -- treasure = coins
    for i = 0, 16 do
        a = make_actor(5, 8 + cos(i / 16) * 3, 10 + sin(i / 16) * 3)
        a.w = 0.25
        a.h = 0.25
    end

    for i = 0, 3 do
        for j = 0, 3 do
            a = make_actor(5, 6.5 + i, 39.5 + j)
            a.w = 0.25
            a.h = 0.25
        end
    end

    -- key
    a = make_actor(8, 1.5, 30.5)
    a = make_actor(24, 62.5, 14.5)

end

-- for any given point on the
-- map, true if there is wall
-- there.
function solid(x, y)
    -- grab the cel value
    val = mget(x, y)

    -- if cel is a key (flag 7)
    if fget(val, 7) then
        if val == 7 and pl.has_yellow_key then -- yellow key
            mset(x, y, 16)
            return false
        elseif val == 23 and pl.has_green_key then -- yellow key
            mset(x, y, 16)
            return false
        else
            return true
        end
    end

    -- check if flag 1 is set, i.e. it is solid
    return fget(val, 1)

end

-- check if a rectangle overlaps
-- with any walls
-- (this version only works for
-- actors less than one tile big)
function solid_area(x, y, w, h)
    return solid(x - w, y - h) or solid(x + w, y - h) or solid(x - w, y + h) or solid(x + w, y + h)
end

-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function solid_actor(a, dx, dy)
    for a2 in all(actor) do
        if a2 ~= a then

            local x = (a.x + dx) - a2.x
            local y = (a.y + dy) - a2.y

            if ((abs(x) < (a.w + a2.w)) and (abs(y) < (a.h + a2.h))) then

                -- moving together?
                -- this allows actors to
                -- overlap initially
                -- without sticking together

                -- process each axis separately

                -- along x

                if (dx ~= 0 and abs(x) < abs(a.x - a2.x)) then

                    v = abs(a.dx) > abs(a2.dx) and a.dx or a2.dx
                    a.dx, a2.dx = v, v

                    local ca = collide_event(a, a2) or collide_event(a2, a)
                    return not ca
                end

                -- along y

                if (dy ~= 0 and abs(y) < abs(a.y - a2.y)) then
                    v = abs(a.dy) > abs(a2.dy) and a.dy or a2.dy
                    a.dy, a2.dy = v, v

                    local ca = collide_event(a, a2) or collide_event(a2, a)
                    return not ca
                end

            end
        end
    end

    return false
end

-- checks both walls and actors
function solid_a(a, dx, dy)
    if solid_area(a.x + dx, a.y + dy, a.w, a.h) then
        return true
    end
    return solid_actor(a, dx, dy)
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other
function collide_event(a1, a2)

    -- player collects treasure
    if (a1 == pl and a2.k == 5) then
        del(actor, a2)
        sfx(3)
        return true
    end

    -- player collects key
    if (a1 == pl and (a2.k == 8 or a2.k == 24)) then
        if a2.k == 8 then
            pl.has_yellow_key = true
        elseif a2.k == 24 then
            pl.has_green_key = true
        end
        del(actor, a2)
        sfx(4)
        return true
    end

    sfx(2) -- generic bump sound

    return false
end

function move_actor(a)

    -- only move actor along x
    -- if the resulting position
    -- will not overlap with a wall

    if not solid_a(a, a.dx, 0) then
        a.x = a.x + a.dx
    else
        a.dx = a.dx * (-a.bounce)
    end

    -- ditto for y
    if not solid_a(a, 0, a.dy) then
        a.y = a.y + a.dy
    else
        a.dy = a.dy * (-a.bounce)
    end

    -- apply friction
    -- (comment for no inertia)
    a.dx = a.dx * (1 - a.friction)
    a.dy = a.dy * (1 - a.friction)

    -- advance one frame every
    -- time actor moves 1/4 of
    -- a tile
    a.frame = a.frame + abs(a.dx) * 4
    a.frame = a.frame + abs(a.dy) * 4
    a.frame = a.frame % a.frames

    a.t = a.t + 1

end

function control_player(pl)

    accel = 0.05
    if (btn(0)) then
        pl.dx = pl.dx - accel
    end
    if (btn(1)) then
        pl.dx = pl.dx + accel
    end
    if (btn(2)) then
        pl.dy = pl.dy - accel
    end
    if (btn(3)) then
        pl.dy = pl.dy + accel
    end

end

function _update()
    control_player(pl)
    foreach(actor, move_actor)
end

function draw_actor(a)
    local sx = (a.x * 8) - 4
    local sy = (a.y * 8) - 4
    spr(a.k + a.frame, sx, sy)
end

function _draw()
    cls()

    room_x = flr(pl.x / 16)
    room_y = flr(pl.y / 16)
    camera(room_x * 128, room_y * 128)

    map()
    foreach(actor, draw_actor)

    print("fps = " .. stat(7))
end
