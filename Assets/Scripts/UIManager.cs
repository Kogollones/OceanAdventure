using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UIManager : MonoBehaviour
{
	public TextMeshProUGUI scoreText;
    public Image healthBar;

    private int score = 0;
    private float health = 1.0f; // Health is a value between 0 and 1

    void Start()
    {
        UpdateScore();
        UpdateHealthBar();
    }

    public void UpdateScore()
{
    if (scoreText != null)
    {
        scoreText.SetText("Score: {0}", score);
    }
    else
    {
        Debug.LogError("UIManager: ScoreText is not assigned.");
    }
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

    void UpdateHealthBar()
    {
        if (healthBar != null)
        {
            healthBar.fillAmount = health;
        }
        else
        {
            Debug.LogError("UIManager: HealthBar is not assigned.");
        }
    }
}
