using UnityEngine;
using System.Collections.Generic;

public class LeaderboardGUI : MonoBehaviour
{
    // Assuming LeaderboardScoreData is defined elsewhere
    private List<LeaderboardScoreData> leaderboardScores;

    private void Start()
    {
        // Example usage
        leaderboardScores = new List<LeaderboardScoreData>();
    }

    private void UpdateLeaderboard(List<LeaderboardScoreData> scores)
    {
        leaderboardScores = scores;
        // Update the GUI with new scores
    }
}

// Assuming this class needs to be defined somewhere
public class LeaderboardScoreData
{
    public string playerName;
    public int score;
}
