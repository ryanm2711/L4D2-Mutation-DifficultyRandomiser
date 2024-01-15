/*MutationOptions <-
{
}*/

MutationState <-
{
    CurrentDifficulty = -1
    LastDifficulty = -1

    CurrentTimer = -1
    //HUDTimer = 0

    Difficulties = [
        {"name": "Easy", "weight": 3, "min": 45, "max": 60},
        {"name": "Normal", "weight": 10, "min": 15, "max": 45},
        {"name": "Hard", "weight": 10, "min": 15, "max": 45},
        {"name": "Impossible", "weight": 3, "min": 45, "max": 60},
    ]

    TotalWeight = 0
    HasFirstPlayerLeftStartArea = false
}

function ChangeDifficulty()
{
    if (SessionState.TotalWeight == 0)
    {
        foreach(Difficulty in SessionState.Difficulties)
        {
            SessionState.TotalWeight += Difficulty.weight
        }
    }

    local difficulty = GetDifficulty()
    SessionState.LastDifficulty <- difficulty

    while (difficulty == SessionState.LastDifficulty)
    {
        local randomWeight = RandomInt(1, SessionState.TotalWeight)
        local weightSum = 0

        for (local i = 0; i < SessionState.Difficulties.len(); i++)
        {
            weightSum += SessionState.Difficulties[i].weight
            if (randomWeight <= weightSum)
            {
                difficulty = i
                break
            }
        }
    }

    SessionState.CurrentDifficulty <- difficulty

    local difficultyName = SessionState.Difficulties[difficulty].name;
    Convars.SetValue("z_difficulty", difficultyName);

    StartDifficultyChangeTimer()
}

function StartDifficultyChangeTimer()
{
    local minTime = 0
    local maxTime = 0

    local difficulty = SessionState.Difficulties[GetDifficulty()]
    minTime = difficulty.min
    maxTime = difficulty.max

    local randTime = RandomInt(minTime, maxTime)
    SessionState.CurrentTimer = Time() + randTime
}

function OnGameEvent_player_left_start_area(params)
{
    if (SessionState.HasFirstPlayerLeftStartArea)
    {
        // Prevent any event being ran again for that
        return
    }

    if (SessionState.CurrentDifficulty == -1)
    {
        SessionState.CurrentDifficulty = GetDifficulty()
        SessionState.LastDifficulty = GetDifficulty()
    }

    if (SessionState.CurrentTimer == -1)
    {
        StartDifficultyChangeTimer()
    }

    SessionState.HasFirstPlayerLeftStartArea = true
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
    SessionState.HasFirstPlayerLeftStartArea = false
}