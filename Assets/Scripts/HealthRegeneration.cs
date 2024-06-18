
using UnityEngine;

public class HealthRegeneration : MonoBehaviour
{
    public int maxHealth = 100;
    private int currentHealth;
    public int regenerationRate = 1;

    void Start()
    {
        currentHealth = maxHealth;
        InvokeRepeating("RegenerateHealth", 1f, 1f);
    }

    void RegenerateHealth()
    {
        if (currentHealth < maxHealth)
        {
            currentHealth += regenerationRate;
        }
    }
}
