using UnityEngine;

public class Ship : MonoBehaviour
{
    public int maxDurability = 100;
    public int currentDurability;
    public int maxHealth = 100;
    public int currentHealth;

    private void Start()
    {
        currentDurability = maxDurability;
        currentHealth = maxHealth;
    }

    public void TakeDamage(int damage)
    {
        currentDurability -= damage;
        if (currentDurability <= 0)
        {
            DestroyShip();
        }
    }

    public void RepairShip(int repairAmount)
    {
        currentDurability += repairAmount;
        if (currentDurability > maxDurability)
        {
            currentDurability = maxDurability;
        }
    }

    public void Heal(int healAmount)
    {
        currentHealth += healAmount;
        if (currentHealth > maxHealth)
        {
            currentHealth = maxHealth;
        }
    }

    void DestroyShip()
    {
        // Implement logic to destroy ship
        Debug.Log("Ship destroyed");
    }

    public void UnlockNewShip()
    {
        // Implement logic to unlock a new ship
        Debug.Log("New ship unlocked");
    }
}
