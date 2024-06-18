using Mirror;
using UnityEngine;

public class NetworkedShip : NetworkBehaviour
{
    public float speed = 10f; // Speed of the ship
    public float rotationSpeed = 100f; // Rotation speed of the ship
    public ParticleSystem waterTrail; // Particle system for water trail
    public ParticleSystem waterSplash; // Particle system for water splash

    private Rigidbody rb; // Rigidbody component
    private bool isMoving = false; // Flag to check if the ship is moving

    void Start()
    {
        rb = GetComponent<Rigidbody>(); // Get the Rigidbody component
        if (waterTrail != null)
        {
            waterTrail.Stop(); // Stop the water trail particle system initially
        }
    }

    void Update()
    {
        if (!isLocalPlayer) return; // Only execute movement for the local player

        HandleMovement(); // Handle ship movement
        HandleWaterEffects(); // Handle water effects
    }

    void HandleMovement()
    {
        float move = Input.GetAxis("Vertical") * speed * Time.deltaTime; // Get vertical input for movement
        float rotation = Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime; // Get horizontal input for rotation

        rb.AddRelativeForce(Vector3.forward * move, ForceMode.Acceleration); // Add force for movement
        rb.AddTorque(Vector3.up * rotation, ForceMode.Acceleration); // Add torque for rotation

        isMoving = move != 0 || rotation != 0; // Check if the ship is moving
    }

    void HandleWaterEffects()
    {
        if (isMoving && !waterTrail.isPlaying)
        {
            waterTrail.Play(); // Play water trail particle system if the ship is moving
        }
        else if (!isMoving && waterTrail.isPlaying)
        {
            waterTrail.Stop(); // Stop water trail particle system if the ship is not moving
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Water" && waterSplash != null)
        {
            waterSplash.Play(); // Play water splash particle system on collision with water
        }
    }
}
