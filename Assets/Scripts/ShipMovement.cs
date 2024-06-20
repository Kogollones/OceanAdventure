using UnityEngine;
using UnityEngine.InputSystem;
using Mirror;

public class ShipMovement : NetworkBehaviour, InputActions.IBoatActions
{
    public float maxSpeed = 20f;
    public float acceleration = 5f;
    public float deceleration = 3f;
    public float rotationSpeed = 30f;
    public float maxRotationSpeed = 10f;
    public float windEffect = 0.5f;
    public ParticleSystem waterTrail;
    public ParticleSystem waterSplash;
    public ParticleSystem foamTrail;
    public UltimateWater waterScript;

    private Rigidbody rb;
    private InputActions inputActions;
    private float forwardInput;
    private float rotationInput;
    private bool isMoving = false;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        inputActions = new InputActions();
        inputActions.Boat.SetCallbacks(this);
        inputActions.Enable();
    }

    private void OnDestroy()
    {
        inputActions.Disable();
    }

    private void Update()
    {
        if (!isLocalPlayer) return;

        HandleMovement();
        CmdUpdateWaterEffects(isMoving);
    }

    private void HandleMovement()
    {
        if (forwardInput != 0 || rotationInput != 0)
        {
            Debug.Log($"Forward Input: {forwardInput}, Rotation Input: {rotationInput}");
        }

        // Apply forward movement
        if (forwardInput > 0)
        {
            rb.AddForce(transform.forward * acceleration, ForceMode.Acceleration);
        }
        else
        {
            rb.velocity = Vector3.Lerp(rb.velocity, Vector3.zero, deceleration * Time.deltaTime);
        }

        // Clamp speed to max speed
        rb.velocity = Vector3.ClampMagnitude(rb.velocity, maxSpeed);

        // Calculate reduced rotation speed at higher velocities
        float currentSpeed = rb.velocity.magnitude;
        float currentRotationSpeed = Mathf.Lerp(maxRotationSpeed, rotationSpeed, 1 - (currentSpeed / maxSpeed));

        // Apply rotation
        if (rotationInput != 0)
        {
            rb.AddTorque(Vector3.up * rotationInput * currentRotationSpeed, ForceMode.Acceleration);
        }

        // Apply wind effect
        rb.AddForce(Vector3.right * windEffect, ForceMode.Acceleration);

        Debug.Log($"Move Vector: {rb.velocity}, Rotation Vector: {rb.angularVelocity}");

        isMoving = forwardInput > 0 || rotationInput != 0;

        // Buoyancy
        Vector3 normal;
        float height;
        UltimateWater.Waves(transform.position, waterScript.GetComponent<Renderer>().material, out normal, out height);

        float buoyancyForce = Mathf.Clamp(1 - (transform.position.y - height), 0, 1);
        rb.AddForce(Vector3.up * buoyancyForce * 10, ForceMode.Acceleration);
    }

    [Command]
    private void CmdUpdateWaterEffects(bool isMoving)
    {
        RpcUpdateWaterEffects(isMoving);
    }

    [ClientRpc]
    private void RpcUpdateWaterEffects(bool isMoving)
    {
        if (isMoving)
        {
            if (!waterTrail.isPlaying)
                waterTrail.Play();
            if (!foamTrail.isPlaying)
                foamTrail.Play();
        }
        else
        {
            if (waterTrail.isPlaying)
                waterTrail.Stop();
            if (foamTrail.isPlaying)
                foamTrail.Stop();
        }
    }

    private void Fire()
    {
        // Implement fire logic here
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Water"))
        {
            Debug.Log("Entered water");
            if (waterSplash != null)
            {
                waterSplash.Play();
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Water"))
        {
            Debug.Log("Exited water");
            if (waterSplash != null)
            {
                waterSplash.Stop();
            }
        }
    }

    public void OnMoveForward(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            forwardInput = 1;
            Debug.Log("Move Forward: performed");
        }
        else if (context.canceled)
        {
            forwardInput = 0;
            Debug.Log("Move Forward: canceled");
        }
    }

    public void OnTurnLeft(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            rotationInput = -1;
            Debug.Log("Turn Left: performed");
        }
        else if (context.canceled)
        {
            rotationInput = 0;
            Debug.Log("Turn Left: canceled");
        }
    }

    public void OnTurnRight(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            rotationInput = 1;
            Debug.Log("Turn Right: performed");
        }
        else if (context.canceled)
        {
            rotationInput = 0;
            Debug.Log("Turn Right: canceled");
        }
    }

    public void OnFire(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            Fire();
            Debug.Log("Fire: performed");
        }
    }

    // Implement other necessary action callbacks if required
    public void OnLook(InputAction.CallbackContext context) { }
    public void OnZoom(InputAction.CallbackContext context) { }
    public void OnActionButton1(InputAction.CallbackContext context) { }
    public void OnActionButton2(InputAction.CallbackContext context) { }
    public void OnActionButton3(InputAction.CallbackContext context) { }
    public void OnActionButton4(InputAction.CallbackContext context) { }
    public void OnActionButton5(InputAction.CallbackContext context) { }
    public void OnActionButton6(InputAction.CallbackContext context) { }
    public void OnActionButton7(InputAction.CallbackContext context) { }
    public void OnRotate(InputAction.CallbackContext context) { }
}
