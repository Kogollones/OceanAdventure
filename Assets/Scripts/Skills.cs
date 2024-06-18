using UnityEngine;
using System.Collections;

public class Skills : MonoBehaviour
{
    public static Skills Instance;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void IncreaseSpeed(float duration)
    {
        StartCoroutine(IncreaseSpeedCoroutine(duration));
    }

    IEnumerator IncreaseSpeedCoroutine(float duration)
    {
        // Implement logic to temporarily increase ship speed
        float originalSpeed = PlayerShip.Instance.speed;
        PlayerShip.Instance.speed *= 2;
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.speed = originalSpeed;
    }

    public void IncreaseDefense(float duration)
    {
        StartCoroutine(IncreaseDefenseCoroutine(duration));
    }

    IEnumerator IncreaseDefenseCoroutine(float duration)
    {
        // Implement logic to temporarily increase ship defense
        int originalDefense = PlayerShip.Instance.defense;
        PlayerShip.Instance.defense *= 2;
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.defense = originalDefense;
    }

    public void IncreaseCannonDamage(float duration)
    {
        StartCoroutine(IncreaseCannonDamageCoroutine(duration));
    }

    IEnumerator IncreaseCannonDamageCoroutine(float duration)
    {
        // Implement logic to temporarily increase cannon damage
        int originalDamage = PlayerShip.Instance.cannonDamage;
        PlayerShip.Instance.cannonDamage *= 2;
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.cannonDamage = originalDamage;
    }
}
