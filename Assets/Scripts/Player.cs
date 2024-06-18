
using UnityEngine;
using System.Collections.Generic;

public class Player : MonoBehaviour
{
    public string playerName;
    public Clan clan;
    public List<Quest> activeQuests;
    public List<Item> inventory;

    public void JoinClan(Clan newClan)
    {
        if (clan != null)
        {
            clan.RemoveMember(this);
        }
        clan = newClan;
        clan.AddMember(this);
    }

    public void LeaveClan()
    {
        if (clan != null)
        {
            clan.RemoveMember(this);
            clan = null;
        }
    }

    public void AddQuest(Quest quest)
    {
        activeQuests.Add(quest);
    }

    public void CompleteQuest(Quest quest)
    {
        activeQuests.Remove(quest);
    }

    public void AddItem(Item item)
    {
        inventory.Add(item);
    }

    public void RemoveItem(Item item)
    {
        inventory.Remove(item);
    }
}
