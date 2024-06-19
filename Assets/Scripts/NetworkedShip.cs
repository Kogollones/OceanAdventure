using Mirror;
using UnityEngine;

public class NetworkedShip : NetworkBehaviour
{
    public float speed = 10f;
    public float rotationSpeed = 100f;
    public ParticleSystem waterTrail;
    public ParticleSystem waterSplash;

    private Rigidbody rb;
    private bool isMoving = false;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        if (waterTrail != null)
        {
            waterTrail.Stop();
        }
    }

    void Update()
    {
        if (!isLocalPlayer) return;

        HandleMovement();
        HandleWaterEffects();
    }

    void HandleMovement()
    {
        float move = Input.GetAxis("Vertical") * speed * Time.deltaTime;
        float rotation = Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime;

        rb.AddRelativeForce(Vector3.forward * move, ForceMode.Acceleration);
        rb.AddTorque(Vector3.up * rotation, ForceMode.Acceleration);

        isMoving = move != 0 || rotation != 0;
    }

    void HandleWaterEffects()
    {
        if (isMoving && !waterTrail.isPlaying)
        {
            waterTrail.Play();
        }
        else if (!isMoving && waterTrail.isPlaying)
        {
            waterTrail.Stop();
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Water" && waterSplash != null)
        {
            waterSplash.Play();
        }
    }
}
