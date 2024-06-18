
using UnityEngine;

public class Monster : MonoBehaviour
{
    public int health = 100;

    public void TakeDamage(int amount)
    {
        health -= amount;
        if (health <= 0)
        {
            Die();
        }
    }

    void Die()
    {
        // Implement logic for monster death
        DropLoot();
        Destroy(gameObject);
    }

    void DropLoot()
    {
        // Implement logic for dropping loot
    }
}
