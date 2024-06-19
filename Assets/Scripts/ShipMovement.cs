using UnityEngine;
using Mirror;

public class ShipController : NetworkBehaviour
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
        if (waterSplash != null)
        {
            waterSplash.Stop();
        }
    }

    void Update()
    {
        if (!isLocalPlayer) return;

        HandleMovement();
        CmdUpdateWaterEffects(isMoving);
    }

    void HandleMovement()
    {
        float move = Input.GetAxis("Vertical") * speed * Time.deltaTime;
        float rotation = Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime;

        rb.AddRelativeForce(Vector3.forward * move, ForceMode.Acceleration);
        rb.AddTorque(Vector3.up * rotation, ForceMode.Acceleration);

        isMoving = move != 0 || rotation != 0;
    }

    [Command]
    void CmdUpdateWaterEffects(bool isMoving)
    {
        RpcUpdateWaterEffects(isMoving);
    }

    [ClientRpc]
    void RpcUpdateWaterEffects(bool isMoving)
    {
        if (isMoving)
        {
            if (!waterTrail.isPlaying)
                waterTrail.Play();
        }
        else
        {
            if (waterTrail.isPlaying)
                waterTrail.Stop();
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Water") && waterSplash != null)
        {
            waterSplash.Play();
        }
    }
}
