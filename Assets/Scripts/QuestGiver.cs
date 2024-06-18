using UnityEngine;
using System.Collections.Generic;

public class QuestGiver : MonoBehaviour
{
    public List<Quest> questsToGive = new List<Quest>();

    public void GiveQuestToPlayer(Player player)
    {
        foreach (Quest quest in questsToGive)
        {
            player.AddQuest(quest);
        }
        Debug.Log("Quests given to player.");
    }
}
