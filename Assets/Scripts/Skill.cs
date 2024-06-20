using UnityEngine;

[CreateAssetMenu(fileName = "NewSkill", menuName = "Skills/Skill")]
public class Skill : ScriptableObject
{
    public int id;
    public string skillName;
    public string description;
    public float cooldown;
    public float duration;

    public void Activate()
    {
        Skills.Instance.ActivateSkill(id, duration);
    }
}
