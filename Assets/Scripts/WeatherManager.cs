using UnityEngine;

public class WeatherManager : MonoBehaviour
{
    public Light directionalLight;
    public ParticleSystem rainEffect;
    public ParticleSystem snowEffect;
    public ParticleSystem stormEffect;
    public float weatherChangeInterval = 300f;
    public AudioClip rainSound;
    public AudioClip stormSound;
    public AudioClip snowSound;
    private AudioSource audioSource;

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
        InvokeRepeating("ChangeWeather", weatherChangeInterval, weatherChangeInterval);
    }

    void ChangeWeather()
    {
        int weatherType = Random.Range(0, 4);

        switch (weatherType)
        {
            case 0:
                ClearWeather();
                break;
            case 1:
                StartRain();
                break;
            case 2:
                StartSnow();
                break;
            case 3:
                StartStorm();
                break;
        }
    }

    void ClearWeather()
    {
        directionalLight.color = Color.white;
        rainEffect.Stop();
        snowEffect.Stop();
        stormEffect.Stop();
        audioSource.Stop();
    }

    void StartRain()
    {
        directionalLight.color = Color.gray;
        rainEffect.Play();
        snowEffect.Stop();
        stormEffect.Stop();
        audioSource.clip = rainSound;
        audioSource.Play();
    }

    void StartSnow()
    {
        directionalLight.color = Color.blue;
        rainEffect.Stop();
        snowEffect.Play();
        stormEffect.Stop();
        audioSource.clip = snowSound;
        audioSource.Play();
    }

    void StartStorm()
    {
        directionalLight.color = Color.black;
        rainEffect.Stop();
        snowEffect.Stop();
        stormEffect.Play();
        audioSource.clip = stormSound;
        audioSource.Play();
    }
}
