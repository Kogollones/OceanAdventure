using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostProcessingSetup : MonoBehaviour
{
    public Volume postProcessingVolume;

    void Start()
    {
        if (postProcessingVolume == null)
        {
            Debug.LogError("Post Processing Volume is not assigned.");
            return;
        }

        var volumeProfile = postProcessingVolume.profile;
        if (volumeProfile == null)
        {
            Debug.LogError("Volume Profile is not assigned.");
            return;
        }

        // Bloom setup
        if (!volumeProfile.TryGet(out Bloom bloom))
        {
            bloom = volumeProfile.Add<Bloom>(true);
        }
        bloom.intensity.value = 0.5f;
        bloom.threshold.value = 1.0f;

        // Color Adjustments setup
        if (!volumeProfile.TryGet(out ColorAdjustments colorAdjustments))
        {
            colorAdjustments = volumeProfile.Add<ColorAdjustments>(true);
        }
        colorAdjustments.saturation.value = 10f;
        colorAdjustments.contrast.value = 15f;

       // Ambient Occlusion setup
       // if (!volumeProfile.TryGet(out UnityEngine.Rendering.Universal.AmbientOcclusion ambientOcclusion))
       // {
       //    ambientOcclusion = volumeProfile.Add<UnityEngine.Rendering.Universal.AmbientOcclusion>(true);
       // }
       // ambientOcclusion.intensity.value = 1f;

        Debug.Log("Post Processing setup completed successfully.");
    }
}
