using UnityEngine;

public class CombatController : MonoBehaviour
{
    public void Attack(Monster target)
    {
        target.TakeDamage(10);
    }
}
