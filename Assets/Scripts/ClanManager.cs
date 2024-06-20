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
