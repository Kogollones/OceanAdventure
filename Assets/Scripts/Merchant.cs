using UnityEngine;

public class Merchant : MonoBehaviour
{
    public void BuyItems(int itemCost)
    {
        if (GameManager.Instance.CanAfford(itemCost))
        {
            GameManager.Instance.SpendCoins(itemCost);
            // Implement logic to add item to inventory
            Debug.Log("Item purchased and added to inventory.");
        }
        else
        {
            Debug.Log("Not enough coins to purchase the item.");
        }
    }

    public void SellItems(int itemValue)
    {
        GameManager.Instance.AddCoins(itemValue);
        // Implement logic to remove item from inventory
        Debug.Log("Item sold and removed from inventory.");
    }
}
