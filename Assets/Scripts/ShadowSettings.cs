using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ShadowSettings : MonoBehaviour
{
    void Start()
    {
        var urpAsset = GraphicsSettings.currentRenderPipeline as UniversalRenderPipelineAsset;
        if (urpAsset != null)
        {
            urpAsset.shadowDistance = 100f;

            // To set shadow resolution, you typically need to set it on a per-light basis
            // Here is an example with a specific light (requires a Light component)
            var light = FindObjectOfType<Light>();
            if (light != null && light.type == LightType.Directional)
            {
                light.shadowResolution = UnityEngine.Rendering.LightShadowResolution.High;
            }

            // Contact shadows are typically managed through additional shadow settings
            // Assuming the URP asset has contact shadow properties, otherwise handle differently
            // urpAsset.someContactShadowProperty = true; // Example, not real property
        }
    }
}
