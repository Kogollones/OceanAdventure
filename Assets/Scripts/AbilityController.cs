
using UnityEngine;

public class AbilityController : MonoBehaviour
{
    public void UseAbility(int abilityIndex)
    {
        switch (abilityIndex)
        {
            case 0:
                BoostSpeed();
                break;
            case 1:
                IncreaseDefense();
                break;
            case 2:
                CannonDamageBoost();
                break;
            case 3:
                HealOverTime();
                break;
            case 4:
                FireSpecialCannonball();
                break;
        }
    }

    void BoostSpeed()
    {
        // Implement logic to temporarily increase ship speed
    }

    void IncreaseDefense()
    {
        // Implement logic to temporarily increase ship defense
    }

    void CannonDamageBoost()
    {
        // Implement logic to temporarily increase cannon damage
    }

    void HealOverTime()
    {
        // Implement logic to heal ship over time
    }

    void FireSpecialCannonball()
    {
        // Implement logic to fire a special cannonball
    }
}
