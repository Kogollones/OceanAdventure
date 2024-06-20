using UnityEngine;
using UnityEditor; // Make sure this namespace is available
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class LightingSetup : MonoBehaviour
{
    void Start()
    {
        #if UNITY_EDITOR
        // Enable real-time global illumination
        Lightmapping.realtimeGI = true;
        #endif

        // Set up light probes
        LightProbes.TetrahedralizeAsync();
    }
}
