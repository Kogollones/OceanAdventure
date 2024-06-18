using UnityEngine;
using System.Collections.Generic;

public class ClanManager : MonoBehaviour
{
    public static ClanManager Instance;
    public List<Clan> clans = new List<Clan>();

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

    public void CreateClan(string name, string logoPath)
    {
        Clan newClan = new Clan(name, logoPath);
        clans.Add(newClan);
    }

    public void AddPlayerToClan(Clan clan, Player player)
    {
        clan.AddMember(player);
    }

    public void RemovePlayerFromClan(Clan clan, Player player)
    {
        clan.RemoveMember(player);
    }

    public List<Clan> GetClans()
    {
        return clans;
    }

    public Clan GetClanByName(string name)
    {
        return clans.Find(clan => clan.name == name);
    }
}

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
        members.Add(player);  // Corrected method name
    }

    public void RemoveMember(Player player)
    {
        members.Remove(player);
    }

    public void AddExperience(int amount)
    {
        experience += amount;
        if (experience >= GetExperienceForNextLevel())
        {
            level++;
            experience = 0;
        }
    }

    int GetExperienceForNextLevel()
    {
        return level * 1000; // Example: level 1 requires 1000 exp, level 2 requires 2000 exp, etc.
    }
}
