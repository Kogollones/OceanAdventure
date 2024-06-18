using UnityEngine;

public class SeaSage : MonoBehaviour
{
    public void RepairShip(int repairCost)
    {
        if (GameManager.Instance.CanAfford(repairCost))
        {
            GameManager.Instance.SpendCoins(repairCost);
            // Implement logic to repair ship
            Debug.Log("Ship repaired.");
        }
        else
        {
            Debug.Log("Not enough coins to repair the ship.");
        }
    }

    public void UnlockShip(int shipCost)
    {
        if (GameManager.Instance.CanAfford(shipCost))
        {
            GameManager.Instance.SpendCoins(shipCost);
            // Implement logic to unlock new ships
            Debug.Log("New ship unlocked.");
        }
        else
        {
            Debug.Log("Not enough coins to unlock the ship.");
        }
    }
}
