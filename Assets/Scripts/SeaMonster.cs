using UnityEngine;

public class SeaMonster : MonoBehaviour
{
    public int attackDamage = 20;
    public float attackRange = 10f;
    public float attackInterval = 3f;

    private float nextAttackTime;

    void Update()
    {
        if (Time.time >= nextAttackTime)
        {
            Attack();
            nextAttackTime = Time.time + attackInterval;
        }
    }

    void Attack()
    {
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, attackRange);
        foreach (var hitCollider in hitColliders)
        {
            ShipHealth shipHealth = hitCollider.GetComponent<ShipHealth>();
            if (shipHealth != null)
            {
                shipHealth.TakeDamage(attackDamage);
            }
        }
    }
}
