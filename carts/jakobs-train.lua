function _init()
    cls()
    switch_state = 0
    train_segments = {{64, 8}, {72, 8}, {80, 8}}
end

function move_segment(segment, switch_state)
    spd = switch_state * 2
    if (segment[2] == 8) -- top side
    then
        if (segment[1] == 112) -- top right
        then
            segment[2] = segment[2] + spd
        else
            segment[1] = segment[1] + spd
        end
    else
        if (segment[1] == 112) -- right side
        then
            if (segment[2] == 112) -- bottom right
            then
                segment[1] = segment[1] - spd
            else
                segment[2] = segment[2] + spd
            end
        else
            if (segment[2] == 112) -- bottom side
            then
                if (segment[1] == 8) -- bottom side then
                then
                    segment[2] = segment[2] - spd
                else
                    segment[1] = segment[1] - spd
                end
            else
                if (segment[1] == 8) -- left side
                then
                    if (segment[2] == 8) -- top left
                    then
                        segment[1] = segment[1] + spd
                    else
                        segment[2] = segment[2] - spd
                    end
                end
            end
        end
    end
end

function advance_switch()
    num_switch_states = 2
    if (switch_state < num_switch_states - 1) then
        switch_state = switch_state + 1
    else
        switch_state = 0
    end
end

function move_train()
    for segment in all(train_segments) do
        move_segment(segment, switch_state)
    end
end

function _update()
    if (btnp(4)) then
        advance_switch()
    end
    move_train()
end

function draw_train()
    local len = count(train_segments)
    for t = 1, len do
        if (t == 1) then
            sprite = 11
        else
            if (t == len) then
                sprite = 13
            else
                sprite = 12
            end
        end
        spr(sprite, train_segments[t][1], train_segments[t][2])
    end
end

function draw_switch()
    if (switch_state == 1) then
        sspr(0, 16, 16, 16, 56, 56, 16, 16)
    else
        sspr(64, 16, 16, 16, 56, 56, 16, 16)
    end
end

function _draw()
    map(0, 0, 0, 0, 16, 16)
    draw_switch()
    draw_train()
end

