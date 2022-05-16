/*MutationOptions <-
{
}*/

MutationState <-
{
    CurrentDifficulty = -1
    LastDifficulty = -1

    CurrentTimer = -1
    HUDTimer = 0

    RandomTimeValues = {
        Easy = {min = 5, max = 15},
        Normal = {min = 15, max = 25},
        Hard = {min = 30, max = 60},
        Impossible = {min = 60, max = 120}
    }

    HasFirstPlayerLeftStartArea = false
}

function ChangeDifficulty()
{
    local difficulty = GetDifficulty()

    SessionState.LastDifficulty = difficulty

    while (difficulty == SessionState.LastDifficulty)
    {
        difficulty = RandomInt(0, 3)
    }
    SessionState.CurrentDifficulty = difficulty

    switch (SessionState.CurrentDifficulty)
    {
        case 0:
            Convars.SetValue("z_difficulty", "Easy")
            break
        case 1:
            Convars.SetValue("z_difficulty", "Normal")
            break
        case 2:
            Convars.SetValue("z_difficulty", "Hard")
            break
        case 3:
            Convars.SetValue("z_difficulty", "Impossible")
            break
        default:
            Convars.SetValue("z_difficulty", "Normal")
            break
    }

    StartDifficultyChangeTimer()
}

function StartDifficultyChangeTimer()
{
    local minTime = 0
    local maxTime = 0

    switch (GetDifficulty())
    {
        case 0:
            minTime = SessionState.RandomTimeValues.Easy.min
            maxTime = SessionState.RandomTimeValues.Easy.max
            break
        case 1:
            minTime = SessionState.RandomTimeValues.Normal.min
            maxTime = SessionState.RandomTimeValues.Normal.max
            break
        case 2:
            minTime = SessionState.RandomTimeValues.Hard.min
            maxTime = SessionState.RandomTimeValues.Hard.max
            break
        case 3:
            minTime = SessionState.RandomTimeValues.Impossible.min
            maxTime = SessionState.RandomTimeValues.Impossible.max
            break
    }

    local randTime = RandomInt(minTime, maxTime)
    SessionState.CurrentTimer = Time() + randTime

    //printl("New difficulty time: " + randTime)
}

function OnGameplayStart()
{
    if (SessionState.CurrentDifficulty == -1)
    {
        SessionState.CurrentDifficulty = GetDifficulty()
        SessionState.LastDifficulty = GetDifficulty()
    }

    if (SessionState.CurrentTimer == -1)
    {
        StartDifficultyChangeTimer()
    }
}

function Update()
{
    // Don't continue if timer is not active
    if (SessionState.CurrentTimer == -1)
        return

    if (Time() >= SessionState.CurrentTimer)
    {
        ChangeDifficulty()
    }
}

function OnShutdown()
{
    SessionState.CurrentTimer = -1
    SessionState.CurrentDifficulty = -1
    SessionState.LastDifficulty = -1
}