using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Clan
{
    public string name;
    public string logoPath;
    public List<Player> members = new List<Player>();
    public int level;
    public int experience;

    public Clan(string name, string logoPath)
    {
        this.name = name;
        this.logoPath = logoPath;
        this.level = 1;
        this.experience = 0;
    }

    public void AddMember(Player player)
    {
        if (!members.Contains(player))
        {
            members.Add(player);
            Debug.Log(player.playerName + " joined the clan " + name);
        }
    }

    public void RemoveMember(Player player)
    {
        if (members.Contains(player))
        {
            members.Remove(player);
            Debug.Log(player.playerName + " left the clan " + name);
        }
    }

    public void AddExperience(int amount)
    {
        experience += amount;
        if (experience >= GetExperienceForNextLevel())
        {
            level++;
            experience = 0;
            Debug.Log("Clan " + name + " leveled up to level " + level);
        }
    }

    private int GetExperienceForNextLevel()
    {
        return level * 1000; // Example: level 1 requires 1000 exp, level 2 requires 2000 exp, etc.
    }
}
