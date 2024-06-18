using UnityEngine;

public class FishingArea : MonoBehaviour
{
    public GameObject fishPrefab;
    public Transform[] spawnPoints;
    public float fishSpawnInterval = 3f;

    private void Start()
    {
        InvokeRepeating("SpawnFish", fishSpawnInterval, fishSpawnInterval);
    }

    void SpawnFish()
    {
        int spawnIndex = Random.Range(0, spawnPoints.Length);
        Instantiate(fishPrefab, spawnPoints[spawnIndex].position, Quaternion.identity);
        Debug.Log("Fish spawned.");
    }
}
