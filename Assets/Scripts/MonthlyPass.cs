using UnityEngine;
using System.Collections.Generic;

public class MonthlyPass : MonoBehaviour
{
    public static MonthlyPass Instance;
    public int passDuration = 30; // Duration in days
    public int price = 10; // Price in Euros
    public List<Reward> rewards = new List<Reward>();

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void PurchasePass()
    {
        // Implement logic for purchasing the pass using Google Play, Steam, Epic Games, etc.
        GameManager.Instance.hasMonthlyPass = true; // Ensure GameManager has this property
    }

    public List<Reward> GetRewards()
    {
        return rewards;
    }
}

[System.Serializable]
public class Reward
{
    public string rewardName;
    public Sprite icon;
    public int levelRequired;

    public Reward(string rewardName, Sprite icon, int levelRequired)
    {
        this.rewardName = rewardName;
        this.icon = icon;
        this.levelRequired = levelRequired;
    }
}
