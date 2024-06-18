using UnityEngine;

public class TreasureSpawner : MonoBehaviour
{
    public GameObject treasurePrefab;
    public Transform[] spawnPoints;
    public float spawnInterval = 10f;

    private void Start()
    {
        InvokeRepeating("SpawnTreasure", spawnInterval, spawnInterval);
    }

    void SpawnTreasure()
    {
        int spawnIndex = Random.Range(0, spawnPoints.Length);
        Instantiate(treasurePrefab, spawnPoints[spawnIndex].position, Quaternion.identity);
    }
}
