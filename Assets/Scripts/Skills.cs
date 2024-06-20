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

    public void ActivateSkill(int skillId, float duration)
    {
        switch (skillId)
        {
            case 0:
                StartCoroutine(IncreaseSpeed(duration));
                break;
            case 1:
                StartCoroutine(IncreaseDefense(duration));
                break;
            case 2:
                StartCoroutine(IncreaseCannonDamage(duration));
                break;
            case 3:
                StartCoroutine(HealOverTime(duration));
                break;
            case 4:
                FireSpecialCannonball();
                break;
            case 5:
                Fireball();
                break;
            case 6:
                StartCoroutine(IceShield(duration));
                break;
            case 7:
                LightningStrike();
                break;
            case 8:
                StartCoroutine(HealingWave(duration));
                break;
            case 9:
                SpeedBurst();
                break;
            case 10:
                StartCoroutine(DefenseMatrix(duration));
                break;
            case 11:
                CannonBarrage();
                break;
            case 12:
                Tornado();
                break;
            default:
                Debug.LogWarning("Skill not implemented: " + skillId);
                break;
        }
    }

    private IEnumerator IncreaseSpeed(float duration)
    {
        float originalSpeed = PlayerShip.Instance.speed;
        PlayerShip.Instance.speed *= 2; // Double the speed
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.speed = originalSpeed; // Revert to original speed
    }

    private IEnumerator IncreaseDefense(float duration)
    {
        int originalDefense = PlayerShip.Instance.defense;
        PlayerShip.Instance.defense *= 2; // Double the defense
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.defense = originalDefense; // Revert to original defense
    }

    private IEnumerator IncreaseCannonDamage(float duration)
    {
        int originalDamage = PlayerShip.Instance.cannonDamage;
        PlayerShip.Instance.cannonDamage *= 2; // Double the cannon damage
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.cannonDamage = originalDamage; // Revert to original damage
    }

    private IEnumerator HealOverTime(float duration)
    {
        // Implement healing over time logic
        yield return new WaitForSeconds(duration);
    }

    private void FireSpecialCannonball()
    {
        // Implement special cannonball logic
    }

    private void Fireball()
    {
        // Implement fireball logic
        Debug.Log("Fired a Fireball");
    }

    private IEnumerator IceShield(float duration)
    {
        int originalDefense = PlayerShip.Instance.defense;
        PlayerShip.Instance.defense *= 3;
        // Implement slowing nearby enemies logic
        yield return new WaitForSeconds(duration);
        PlayerShip.Instance.defense = originalDefense;
    }

    private void LightningStrike()
    {
        // Implement lightning strike logic
        Debug.Log("Called down a Lightning Strike");
    }

    private IEnumerator HealingWave(float duration)
    {
        // Implement healing wave logic
        yield return new WaitForSeconds(duration);
    }

    private void SpeedBurst()
    {
        // Implement speed burst logic
        Debug.Log("Activated Speed Burst");
    }

    private IEnumerator DefenseMatrix(float duration)
    {
        // Implement defense matrix logic
        yield return new WaitForSeconds(duration);
    }

    private void CannonBarrage()
    {
        // Implement cannon barrage logic
        Debug.Log("Fired a Cannon Barrage");
    }

    private void Tornado()
    {
        // Implement tornado logic
        Debug.Log("Created a Tornado");
    }
}
