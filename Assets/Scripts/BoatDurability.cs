
using UnityEngine;

public class BoatDurability : MonoBehaviour
{
    public int maxDurability = 100;
    private int currentDurability;

    void Start()
    {
        currentDurability = maxDurability;
    }

    public void TakeDamage(int amount)
    {
        currentDurability -= amount;
        if (currentDurability <= 0)
        {
            DestroyBoat();
        }
    }

    void DestroyBoat()
    {
        // Implement logic for destroying the boat
        Destroy(gameObject);
    }
}
