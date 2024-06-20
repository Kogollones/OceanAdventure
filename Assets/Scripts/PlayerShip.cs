using UnityEngine;

public class PlayerShip : MonoBehaviour
{
    public static PlayerShip Instance;
    public float speed;
    public int defense;
    public int cannonDamage;

    public Skill[] skills;

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

    public void UseSkill1() => ActivateSkill(0);
    public void UseSkill2() => ActivateSkill(1);
    public void UseSkill3() => ActivateSkill(2);
    public void UseSkill4() => ActivateSkill(3);
    public void UseSkill5() => ActivateSkill(4);
    public void UseSkill6() => ActivateSkill(5);
    public void UseSkill7() => ActivateSkill(6);
    public void UseSkill8() => ActivateSkill(7);

    public void ActivateSkill(int skillId)
    {
        if (skillId >= 0 && skillId < skills.Length)
        {
            skills[skillId].Activate();
            Debug.Log("Activated skill with ID: " + skillId);
        }
        else
        {
            Debug.LogWarning("Invalid skill ID: " + skillId);
        }
    }
}
