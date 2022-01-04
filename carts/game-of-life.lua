-- game-of-life
-- by pippo & sons

-- get value of a board
function get(bi, x, y)
    if ((x < 1) or (x > width) or (y < 1) or (y > height)) then
        return 0 -- values outside the board are dead, i.e. 0
    end
    return boards[bi][y][x]
end

alive_color = 7
width = 128
height = 128

board_i = 1

-- define two boards, the current one and the next one
boards = {{}, {}}

-- initialize all values with 0
for y = 1, height do
    boards[1][y] = {}
    boards[2][y] = {}
    for x = 1, width do
        boards[1][y][x] = 0
        boards[2][y][x] = 0
    end
end

-- initialize board with an r pentomino
-- boards[1][60][64] = 1
-- boards[1][60][65] = 1
-- boards[1][61][63] = 1
-- boards[1][61][64] = 1
-- boards[1][62][64] = 1

-- initialize board with random values
-- for y = 1, height do
--     for x = 1, width do
--         boards[1][y][x] = flr(rnd(2))
--     end
-- end

-- initialize board where each n-th row is alive
for y = 1, height do
    for x = 1, width do
        if y % 3 == 0 then
           boards[1][y][x] = 1
        end
    end
end

cls()

while true do
    -- draw board_i
    for y = 1, height do
        for x = 1, width do
            pset(x - 1, y - 1, boards[board_i][y][x] * alive_color)
        end
    end

    -- set index of other board
    other_i = (board_i % 2) + 1
    -- ... which corresponds to
    -- if board_i == 1 then
    --     other_i = 2
    -- elseif board_i == 2 then
    --     other_i = 1
    -- end

    -- change state (dead=0/alive=1) of cells
    for y = 1, height do
        for x = 1, width do
            -- count neighbors which are alive
            neighbors = (get(board_i, x - 1, y - 1) + get(board_i, x, y - 1) + get(board_i, x + 1, y - 1) +
                            get(board_i, x - 1, y) + get(board_i, x + 1, y) + get(board_i, x - 1, y + 1) +
                            get(board_i, x, y + 1) + get(board_i, x + 1, y + 1))
            if ((neighbors == 3) or ((boards[board_i][y][x] == 1) and neighbors == 2)) then
                boards[other_i][y][x] = 1
            else
                boards[other_i][y][x] = 0
            end
        end
    end

    -- switch board indices
    board_i = other_i

    -- draw board
    flip()
end
