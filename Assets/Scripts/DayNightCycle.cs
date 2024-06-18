
using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    public Light directionalLight;
    public float dayDuration = 120f; // duration of a full day in seconds
    private float time;

    void Update()
    {
        time += Time.deltaTime / dayDuration;
        directionalLight.transform.rotation = Quaternion.Euler(new Vector3((time * 360f) - 90f, 170f, 0));
        if (time >= 1) time = 0;
    }
}
