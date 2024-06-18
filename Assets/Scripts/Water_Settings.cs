using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Water_Settings : MonoBehaviour
{
    private Material waterVolume;
    private Material waterMaterial;
    private static Water_Settings instance;
    private WaterMovement waterMovement;  // Reference to WaterMovement

    void Awake()
    {
        instance = this; // Assign the current instance to the static variable
        waterMovement = GetComponent<WaterMovement>();

        if (waterMovement == null)
        {
            Debug.LogError("Water_Settings: No WaterMovement component found on the GameObject.");
        }
    }

    void Start()
    {
        Debug.Log("Water_Settings: Start method called.");
        InitializeMaterials();
    }

    void Update()
    {
        if (waterVolume == null)
        {
            waterVolume = (Material)Resources.Load("Water_Volume");
            if (waterVolume == null)
            {
                Debug.LogError("Water_Settings: Water_Volume material not found in Resources.");
                return;
            }
        }

        if (waterMaterial == null)
        {
            MeshRenderer renderer = GetComponent<MeshRenderer>();
            if (renderer != null)
            {
                waterMaterial = renderer.sharedMaterial;
                if (waterMaterial == null)
                {
                    Debug.LogError("Water_Settings: No material found on MeshRenderer.");
                }
            }
            else
            {
                Debug.LogError("Water_Settings: No MeshRenderer found on the GameObject.");
            }
        }

        if (waterVolume != null && waterMaterial != null)
        {
            waterVolume.SetVector("pos", new Vector4(0, (waterVolume.GetVector("bounds").y / -2) + transform.position.y + (waterMaterial.GetFloat("_Displacement_Speed") / 3), 0, 0));
        }
    }

    private void InitializeMaterials()
    {
        MeshRenderer renderer = GetComponent<MeshRenderer>();
        if (renderer != null)
        {
            waterMaterial = renderer.sharedMaterial;
            if (waterMaterial != null)
            {
                Debug.Log("Water_Settings: Successfully assigned waterMaterial: " + waterMaterial.name);
            }
            else
            {
                Debug.LogError("Water_Settings: No material found on MeshRenderer.");
            }
        }
        else
        {
            Debug.LogError("Water_Settings: No MeshRenderer found on the GameObject.");
        }
    }

    public static float GetWaterHeight(Vector3 position)
    {
        if (instance == null)
        {
            Debug.LogError("Water_Settings: No Water_Settings instance found in the scene.");
            return 0;
        }

        if (instance.waterMaterial == null)
        {
            Debug.LogError("Water_Settings: waterMaterial is not assigned.");
            return 0;
        }

        // Incorporate ripple effect from WaterMovement
        float ripple = instance.waterMovement != null ? instance.waterMovement.GetRippleEffect() : 0f;
        float displacementSpeed = instance.waterMaterial.GetFloat("_Displacement_Speed");  // Use exact property name here
        float waterHeight = instance.transform.position.y + displacementSpeed * Mathf.Sin(position.x + Time.time) * Mathf.Cos(position.z + Time.time) + ripple;
        return waterHeight;
    }
}
