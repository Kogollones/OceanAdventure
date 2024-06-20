using UnityEngine;

public class Buoyancy : MonoBehaviour
{
    public float buoyancyStrength = 1.0f;
    private Rigidbody rb;
    private UltimateWater ultimateWater;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        ultimateWater = FindObjectOfType<UltimateWater>();
    }

    private void FixedUpdate()
    {
        Vector3 position = transform.position;
        Vector3 normal;
        float waveHeight = ultimateWater.GetWaveHeight(position, out normal);

        if (position.y < waveHeight)
        {
            float buoyancyForce = Mathf.Clamp(1 - (position.y - waveHeight), 0, 1);
            rb.AddForce(Vector3.up * buoyancyForce * buoyancyStrength, ForceMode.Acceleration);

            // Apply torque to simulate the object's orientation according to the wave normal
            Vector3 waveNormal = normal;
            Quaternion targetRotation = Quaternion.FromToRotation(transform.up, waveNormal) * transform.rotation;
            rb.MoveRotation(Quaternion.Slerp(transform.rotation, targetRotation, Time.fixedDeltaTime * buoyancyStrength));
        }
    }
}
