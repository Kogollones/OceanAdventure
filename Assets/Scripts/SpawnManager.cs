
using UnityEngine;

public class SpawnManager : MonoBehaviour
{
    public GameObject monsterPrefab;
    public GameObject treasurePrefab;
    public GameObject fishPrefab;
    public int monsterCount = 10;
    public int treasureCount = 10;
    public int fishCount = 20;

    void Start()
    {
        SpawnMonsters();
        SpawnTreasures();
        SpawnFish();
    }

    void SpawnMonsters()
    {
        for (int i = 0; i < monsterCount; i++)
        {
            Vector3 position = new Vector3(Random.Range(-50, 50), 0, Random.Range(-50, 50));
            Instantiate(monsterPrefab, position, Quaternion.identity);
        }
    }

    void SpawnTreasures()
    {
        for (int i = 0; i < treasureCount; i++)
        {
            Vector3 position = new Vector3(Random.Range(-50, 50), 0, Random.Range(-50, 50));
            Instantiate(treasurePrefab, position, Quaternion.identity);
        }
    }

    void SpawnFish()
    {
        for (int i = 0; i < fishCount; i++)
        {
            Vector3 position = new Vector3(Random.Range(-50, 50), 0, Random.Range(-50, 50));
            Instantiate(fishPrefab, position, Quaternion.identity);
        }
    }
}
