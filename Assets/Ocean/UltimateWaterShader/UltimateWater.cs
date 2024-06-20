using UnityEngine;

public class UltimateWater : MonoBehaviour
{
    private Material waterMaterial;

    void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            waterMaterial = renderer.material;
        }
        else
        {
            Debug.LogError("UltimateWater: No Renderer found on the GameObject.");
        }
    }

    public static void Waves(Vector3 position, Material waterMat, out Vector3 normal, out float height)
    {
        if (waterMat == null)
        {
            Debug.LogError("UltimateWater: waterMat is null.");
            normal = Vector3.up;
            height = 0;
            return;
        }

        float waveSpeed = waterMat.GetFloat("_WaveSpeed");
        float waveScale = waterMat.GetFloat("_WaveScale");

        float time = Time.time * waveSpeed;

        // Gerstner wave calculations
        height = GerstnerWave(position, new Vector4(1, 0, 0, 0), 0.2f, 0.1f, waveSpeed, 0, time).z;
        height += GerstnerWave(position, new Vector4(0, 1, 0, 0), 0.3f, 0.05f, waveSpeed, 0.5f, time).z;

        // Normal calculation
        Vector3 gradient = new Vector3(
            GerstnerWave(position + Vector3.right * 0.1f, new Vector4(1, 0, 0, 0), 0.2f, 0.1f, waveSpeed, 0, time).z - height,
            1,
            GerstnerWave(position + Vector3.forward * 0.1f, new Vector4(0, 1, 0, 0), 0.3f, 0.05f, waveSpeed, 0.5f, time).z - height
        );

        normal = Vector3.Normalize(gradient);
    }

    public float GetWaveHeight(Vector3 position, out Vector3 normal)
    {
        float height;
        Waves(position, waterMaterial, out normal, out height);
        return height;
    }

    private static Vector4 GerstnerWave(Vector3 pos, Vector4 waveDir, float freq, float amp, float speed, float phase, float time)
    {
        Vector2 dir = new Vector2(waveDir.x, waveDir.y).normalized;
        float wave = Vector2.Dot(dir, new Vector2(pos.x, pos.z)) * freq + time + phase;
        float height = Mathf.Sin(wave) * amp;
        return new Vector4(pos.x, pos.y, pos.z + height, 1);
    }

    void OnDrawGizmos()
    {
        if (waterMaterial != null)
        {
            Vector3 normal;
            float height;
            Waves(transform.position, waterMaterial, out normal, out height);

            Gizmos.color = Color.blue;
            Gizmos.DrawLine(transform.position, transform.position + normal * height);
        }
    }
}
