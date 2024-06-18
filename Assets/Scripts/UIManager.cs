using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public Text scoreText;
    public Image healthBar;

    private int score = 0;
    private float health = 1.0f; // Health is a value between 0 and 1

    void Start()
    {
        UpdateScore();
        UpdateHealthBar();
    }

    public void IncreaseScore(int amount)
    {
        score += amount;
        UpdateScore();
    }

    public void DecreaseHealth(float amount)
    {
        health -= amount;
        if (health < 0) health = 0;
        UpdateHealthBar();
    }

    void UpdateScore()
    {
        scoreText.text = "Score: " + score;
    }

    void UpdateHealthBar()
    {
        healthBar.fillAmount = health;
    }
}
