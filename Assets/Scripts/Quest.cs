using UnityEngine;

[System.Serializable]
public class Quest
{
    public int id;
    public string name;
    public string description;
    public bool isComplete;
    public int rewardPoints;
    public int rewardCoins;

    public void StartQuest()
    {
        isComplete = false;
    }

    public void CompleteQuest()
    {
        isComplete = true;
    }
}
