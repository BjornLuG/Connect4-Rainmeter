function Initialize()
    discColor1 = SKIN:GetVariable("DiscColor1")
    discColor2 = SKIN:GetVariable("DiscColor2")
    name1 = SKIN:GetVariable("DiscName1")
    name2 = SKIN:GetVariable("DiscName2")

    col = SKIN:GetVariable("BoardCol") + 0
    row = SKIN:GetVariable("BoardRow") + 0
    spacing = SKIN:GetVariable("DiscSpacing") + 0
    discRadius = SKIN:GetVariable("DiscRadius") + 0
    dropHeight = SKIN:GetVariable("DropHeight") + 0

    size = col * row

    game = {}
    for i=1, col do
        game[i] = {}
        for j=1, row do
            game[i][j] = 0
        end
    end

    gameEnded = false

    currentDiscIndex = 0
    -- Turn 1 = Player 1, Turn 2 = Player 2
    currentTurn = 1
    currentDiscMeter = nil
    currentDiscMeterName = ""

    gravity = 1000
    velocity = 0
    endY = 0

    dt = 0
    prevTime = os.clock()

    lastX = 0
    lastY = 0
end

function Update()
    dt = (os.clock() - prevTime)
    prevTime = os.clock()

    UpdateCurrentDisc()
end

function UpdateCurrentDisc()
    if currentDiscMeter ~= nil then
        if velocity >= 0 and currentDiscMeter:GetY() >= endY then
            if velocity <= 50 then
                velocity = 0
                currentDiscMeter:SetY(endY)
                currentDiscMeter = nil

                UpdateRedraw(currentDiscMeterName)

                CheckWin()
                return
            else
                velocity = -velocity / 3
            end
        end

        velocity = velocity + gravity * dt
        currentDiscMeter:SetY(currentDiscMeter:GetY() + velocity * dt)

        UpdateRedraw(currentDiscMeterName)
    end
end

function FinishCurrentDisc()
    if (currentDiscMeter ~= nil) then
        velocity = 0
        currentDiscMeter:SetY(endY)

        UpdateCurrentDisc()
    end
end

function DropDisc(column)
    if currentDiscIndex + 1 > size then return end

    -- Calc drop Y
    local canDrop = false
    local indexY = 0
    for i,v in ipairs(game[column]) do
        if v ~= 0 and i-1 >= 1 then
            canDrop = true
            game[column][i-1] = currentTurn
            indexY = i-1
            break
        elseif i >= row then
            canDrop = true
            game[column][i] = currentTurn
            indexY = i
            break
        end
    end

    if not canDrop then return end

    if currentDiscMeter ~= nil then
        FinishCurrentDisc()
    end

    if gameEnded then return end

    currentDiscIndex = currentDiscIndex + 1
    currentDiscMeterName = "Disc" .. currentDiscIndex
    currentDiscMeter = SKIN:GetMeter(currentDiscMeterName)

    SKIN:Bang("!SetOption", currentDiscMeterName, "Hidden", "0")
    if currentTurn == 1 then
        SKIN:Bang("!SetOption", currentDiscMeterName, "DiscColor", "Fill Color " .. discColor1)
        SetGhostColor(discColor2 .. ',80')
    elseif currentTurn == 2 then
        SKIN:Bang("!SetOption", currentDiscMeterName, "DiscColor", "Fill Color " .. discColor2)
        SetGhostColor(discColor1 .. ',80')
    end
    UpdateRedraw(currentDiscMeterName)

    -- There's a weird bug that says this variable is nil, eventhough i had assigned it above
    currentDiscMeter = SKIN:GetMeter(currentDiscMeterName)

    currentDiscMeter:SetX((column - 1) * discRadius * 2 + column * spacing)
    currentDiscMeter:SetY(0)

    endY = dropHeight + (indexY - 1) * discRadius * 2 + indexY * spacing

    lastX = column
    lastY = indexY

    SwitchTurn()
end

function UpdateRedraw(meterName)
    SKIN:Bang("!UpdateMeter", meterName)
    -- SKIN:Bang("!Redraw")
end

function SwitchTurn()
    if currentTurn == 1 then
        currentTurn = 2
        SetTurnText(name2 .. "'s turn")
    elseif currentTurn == 2 then
        currentTurn = 1
        SetTurnText(name1 .. "'s turn")
    end
end

function CheckWin()
    if lastX < 1 or lastY < 1 or lastX > col or lastY > row then return end

    local playerNum = game[lastX][lastY]
    local count = 1
    local winned = false
    local matchCallback = function()
        count = count + 1
    end
    local win = function()
        if count >= 4 then winned = true end
        count = 1
    end

    -- Check horizontal |
    CheckDisc(lastX, lastY, playerNum, "l", matchCallback)
    CheckDisc(lastX, lastY, playerNum, "r", matchCallback)

    win()

    -- Check vertical -
    CheckDisc(lastX, lastY, playerNum, "t", matchCallback)
    CheckDisc(lastX, lastY, playerNum, "b", matchCallback)

    win()

    -- Check left diagonal \
    CheckDisc(lastX, lastY, playerNum, "tl", matchCallback)
    CheckDisc(lastX, lastY, playerNum, "br", matchCallback)

    win()

    -- Check right diagonal /
    CheckDisc(lastX, lastY, playerNum, "tr", matchCallback)
    CheckDisc(lastX, lastY, playerNum, "bl", matchCallback)

    win()

    if winned then
        gameEnded = true

        if playerNum == 1 then
            SetWinText(name1 .. " wins")
        elseif playerNum == 2 then
            SetWinText(name2 .. " wins")
        end
    end
end

function CheckDisc(x, y, playerNum, direction, callback)
    if direction == "t" and y-1 >= 1 then
        if game[x][y-1] == playerNum then
            callback()
            CheckDisc(x, y-1, playerNum, direction, callback)
        end

    elseif direction == "b" and y+1 <= row then
        if game[x][y+1] == playerNum then
            callback()
            CheckDisc(x, y+1, playerNum, direction, callback)
        end

    elseif direction == "l" and x-1 >= 1 then
        if game[x-1][y] == playerNum then
            callback()
            CheckDisc(x-1, y, playerNum, direction, callback)
        end

    elseif direction == "r" and x+1 <= col then
        if game[x+1][y] == playerNum then
            callback()
            CheckDisc(x+1, y, playerNum, direction, callback)
        end

    elseif direction == "tl" and y-1 >= 1 and x-1 >= 1 then
        if game[x-1][y-1] == playerNum then
            callback()
            CheckDisc(x-1, y-1, playerNum, direction, callback)
        end

    elseif direction == "tr" and y-1 >= 1 and x+1 <= col then
        if game[x+1][y-1] == playerNum then
            callback()
            CheckDisc(x+1, y-1, playerNum, direction, callback)
        end

    elseif direction == "bl" and y+1 <= row and x-1 >= 1 then
        if game[x-1][y+1] == playerNum then
            callback()
            CheckDisc(x-1, y+1, playerNum, direction, callback)
        end

    elseif direction == "br" and y+1 <= row and x+1 <= col then
        if game[x+1][y+1] == playerNum then

            callback()
            CheckDisc(x+1, y+1, playerNum, direction, callback)
        end
    end
end

function SetGhostColor(color)
    SKIN:Bang("!SetOptionGroup", "DiscGhostGroup", "DiscColor", "Fill Color " .. color)
    SKIN:Bang("!UpdateMeterGroup", "DiscGhostGroup")
    SKIN:Bang("Redraw")
end

function SetTurnText(text)
    SKIN:Bang("!SetOption", "PlayerTurn", "Text", text)
    SKIN:Bang("!UpdateMeter", "PlayerTurn")
    SKIN:Bang("Redraw")
end

function SetWinText(text)
    SKIN:Bang("!SetOption", "PlayerTurn", "Text", text)
    SKIN:Bang("!UpdateMeter", "PlayerTurn")
    SKIN:Bang("Redraw")
end
