using UnityEngine;

public class MonsterSpawner : MonoBehaviour
{
    public GameObject[] monsterPrefabs;
    public Transform[] spawnPoints;
    public float spawnInterval = 5f;

    private void Start()
    {
        InvokeRepeating("SpawnMonster", spawnInterval, spawnInterval);
    }

    void SpawnMonster()
    {
        int spawnIndex = Random.Range(0, spawnPoints.Length);
        int monsterIndex = Random.Range(0, monsterPrefabs.Length);

        Instantiate(monsterPrefabs[monsterIndex], spawnPoints[spawnIndex].position, Quaternion.identity);
    }
}
