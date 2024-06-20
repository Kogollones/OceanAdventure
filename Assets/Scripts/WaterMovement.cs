using UnityEngine;

public class WaterMovement : MonoBehaviour
{
    private Material material;
    public float waveSpeed = 1f;
    public float waveScale = 1f;
    public float foamSpeed = 0.5f;
    public float foamScale = 1f;
    public float rippleSpeed = 1f;
    public float rippleScale = 1f;
    public float rippleStrength = 1f;

    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        material = renderer.material;
    }

    private void Update()
    {
        UpdateWaveEffect();
        UpdateFoamEffect();
        UpdateRippleEffect();
    }

    private void UpdateWaveEffect()
    {
        if (material.HasProperty("_WaveSpeed") && material.HasProperty("_WaveScale"))
        {
            material.SetFloat("_WaveSpeed", waveSpeed);
            material.SetFloat("_WaveScale", waveScale);
        }
    }

    private void UpdateFoamEffect()
    {
        if (material.HasProperty("_FoamSpeed") && material.HasProperty("_FoamScale"))
        {
            material.SetFloat("_FoamSpeed", foamSpeed);
            material.SetFloat("_FoamScale", foamScale);
        }
    }

    private void UpdateRippleEffect()
    {
        if (material.HasProperty("_RippleSpeed") && material.HasProperty("_RippleScale") && material.HasProperty("_RippleStrength"))
        {
            material.SetFloat("_RippleSpeed", rippleSpeed);
            material.SetFloat("_RippleScale", rippleScale);
            material.SetFloat("_RippleStrength", rippleStrength);
        }
    }

    public float GetWaveEffect()
    {
        if (material.HasProperty("_WaveScale"))
        {
            return material.GetFloat("_WaveScale");
        }
        return 0f; // Return 0 if the _WaveScale property does not exist
    }

    public float GetFoamEffect()
    {
        if (material.HasProperty("_FoamScale"))
        {
            return material.GetFloat("_FoamScale");
        }
        return 0f; // Return 0 if the _FoamScale property does not exist
    }

    public float GetRippleEffect()
    {
        if (material.HasProperty("_RippleScale"))
        {
            return material.GetFloat("_RippleScale");
        }
        return 0f; // Return 0 if the _RippleScale property does not exist
    }
}
