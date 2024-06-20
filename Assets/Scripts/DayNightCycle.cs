using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    public Light directionalLight;
    public float dayDuration = 300f;
    private float time;

    void Update()
    {
        time += Time.deltaTime;
        float t = Mathf.PingPong(time / dayDuration, 1f);
        directionalLight.transform.localRotation = Quaternion.Euler(new Vector3(t * 360f - 90f, 170f, 0));
        RenderSettings.ambientIntensity = Mathf.Lerp(0.5f, 1.0f, t);
    }
}
