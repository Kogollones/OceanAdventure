using UnityEngine;
using System.Collections.Generic;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    public bool hasMonthlyPass = false;
    public int playerPoints;
    public int playerCoins;
    public int currentLevel;
    public int experience;
    public int health;

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

    public void AddPoints(int points)
    {
        playerPoints += points;
    }

    public void AddCoins(int coins)
    {
        playerCoins += coins;
    }

    public bool CanAfford(int amount)
    {
        return playerCoins >= amount;
    }

    public void SpendCoins(int coins)
    {
        if (CanAfford(coins))
        {
            playerCoins -= coins;
        }
    }

    public void AddExperience(int exp)
    {
        experience += exp;
        if (experience >= GetExperienceForNextLevel())
        {
            LevelUp();
        }
    }

    private int GetExperienceForNextLevel()
    {
        return currentLevel * 100;
    }

    private void LevelUp()
    {
        currentLevel++;
        experience = 0;
        // Add logic to handle level-up rewards, skill points, etc.
    }

    public void TakeDamage(int damage)
    {
        health -= damage;
        if (health <= 0)
        {
            Die();
        }
    }

    private void Die()
    {
        Debug.Log("Player has died.");
    }
}
