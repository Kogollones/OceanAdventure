using UnityEngine;

public class ShipHealth : MonoBehaviour
{
    public int maxHealth = 100;
    private int currentHealth;

    void Start()
    {
        currentHealth = maxHealth;
    }

    public void TakeDamage(int amount)
    {
        currentHealth -= amount;
        if (currentHealth <= 0)
        {
            SinkShip();
        }
    }

    void SinkShip()
    {
        // Implement sinking logic
        Debug.Log("Ship Sunk!");
        Destroy(gameObject);
    }
}
