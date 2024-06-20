using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class SimpleBuoyancy : MonoBehaviour
{
    public string waterObjectName = "OceanGameObjectName";  // Name of the water GameObject
    public float waterLevel = 0.0f;
    public float floatThreshold = 2.0f;
    public float waterDensity = 0.125f;
    public float downForce = 4.0f;
    public bool dynamicWaterLevel = true;  // Option to dynamically set water level

    public float buoyancyForce = 10.0f;  // New buoyancy force
    public float dampingFactor = 0.99f;  // New damping factor

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();

        if (dynamicWaterLevel)
        {
            SetWaterLevelFromGameObject();
        }

        Debug.Log("SimpleBuoyancy: Water level set to " + waterLevel);
    }

    void FixedUpdate()
    {
        ApplyBuoyancy();
    }

    private void ApplyBuoyancy()
    {
        Vector3 actionPoint = transform.position;
        float forceFactor = 1.0f - ((actionPoint.y - waterLevel) / floatThreshold);

        if (forceFactor > 0.0f)
        {
            Vector3 uplift = -Physics.gravity * (forceFactor - rb.velocity.y * waterDensity);
            uplift += new Vector3(0, downForce, 0);
            rb.AddForceAtPosition(uplift, actionPoint);
            
            // Apply additional buoyancy and damping
            if (transform.position.y < waterLevel)
            {
                float displacementMultiplier = Mathf.Clamp01((waterLevel - transform.position.y) / waterLevel);
                Vector3 upwardForce = Vector3.up * buoyancyForce * displacementMultiplier;
                rb.AddForce(upwardForce, ForceMode.Acceleration);
                
                // Apply damping to simulate water resistance
                rb.velocity *= dampingFactor;
                rb.angularVelocity *= dampingFactor;
            }
        }
    }

    private void SetWaterLevelFromGameObject()
    {
        GameObject water = GameObject.Find(waterObjectName);

        if (water != null)
        {
            waterLevel = water.transform.position.y;
        }
        else
        {
            Debug.LogError("SimpleBuoyancy: Water GameObject not found. Please check the name.");
        }
    }
}
