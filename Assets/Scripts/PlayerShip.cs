using UnityEngine;

public class PlayerShip : MonoBehaviour
{
    public static PlayerShip Instance;
    public float speed;
    public int defense;
    public int cannonDamage;

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
}
