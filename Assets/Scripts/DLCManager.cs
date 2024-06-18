
using UnityEngine;
using System.Collections.Generic;

public class DLCManager : MonoBehaviour
{
    public static DLCManager Instance;
    public List<DLC> dlcs = new List<DLC>();

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

    public void AddDLC(DLC dlc)
    {
        dlcs.Add(dlc);
    }

    public List<DLC> GetDLCs()
    {
        return dlcs;
    }
}

[System.Serializable]
public class DLC
{
    public string dlcName;
    public Sprite icon;
    public float price;

    public DLC(string dlcName, Sprite icon, float price)
    {
        this.dlcName = dlcName;
        this.icon = icon;
        this.price = price;
    }
}
