using UnityEngine;

public class MinimapFollow : MonoBehaviour
{
    public Transform player;
    private float updateInterval = 0.1f;
    private float nextUpdateTime = 0f;

    void LateUpdate()
    {
        if (Time.time >= nextUpdateTime)
        {
            if (player != null)
            {
                Vector3 newPosition = player.position;
                newPosition.y = transform.position.y;
                transform.position = newPosition;
            }
            nextUpdateTime = Time.time + updateInterval;
        }
    }
}
