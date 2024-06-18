using System.Collections.Generic;
using UnityEngine;

namespace InventoryNamespace
{
    public class Inventory : MonoBehaviour
    {
        public List<Item> items = new List<Item>();

        public void AddItem(Item item)
        {
            items.Add(item);
            Debug.Log("Item added to inventory.");
        }

        public void RemoveItem(Item item)
        {
            items.Remove(item);
            Debug.Log("Item removed from inventory.");
        }
    }

    [System.Serializable]
    public class Item
    {
        public string itemName;
        public Sprite itemIcon;
        public string description;
        public int value;
    }
}
