using UnityEngine;
using UnityEngine.InputSystem;

namespace CameraController
{
    public class CameraController : MonoBehaviour, InputActions.IBoatActions
    {
        public static CameraController Instance = null;

        public Camera Camera_ToUse;
        public Camera UI_Camera;

        public Transform FollowTarget = null;
        public Vector3 TargetOffset = new Vector3(0, 10, -10);
        public float maxZoomOutFOV = 120f;
        public float minZoomInFOV = 30f;
        public float smoothSpeed = 0.125f;  // Smoothing speed for camera movement

        private InputActions inputActions;
        private Vector2 zoomInput;

        private void Awake()
        {
            if (Instance == null)
                Instance = this;
            else
                Destroy(gameObject);

            inputActions = new InputActions();
            inputActions.Boat.SetCallbacks(this);
            inputActions.Enable();
        }

        private void OnDestroy()
        {
            inputActions.Disable();
        }

        private void Start()
        {
            Setup_CameraToUse();
        }

        public void Setup_CameraToUse()
        {
            if (Camera_ToUse == null)
            {
                if (Camera.main != null)
                    Camera_ToUse = Camera.main;
                else Debug.LogError("Camera Controller:  -AutoSetup CANNOT find a Camera, please make sure you have a Camera in the Scene tagged with 'MainCamera'!");
            }
        }

        private void LateUpdate()
        {
            if (FollowTarget != null)
            {
                Vector3 desiredPosition = FollowTarget.position + TargetOffset;
                Vector3 smoothedPosition = Vector3.Lerp(Camera_ToUse.transform.position, desiredPosition, smoothSpeed);
                Camera_ToUse.transform.position = smoothedPosition;

                Camera_ToUse.transform.LookAt(FollowTarget);
            }
        }

        public void OnZoom(InputAction.CallbackContext context)
        {
            float scrollValue = context.ReadValue<Vector2>().y;

            if (scrollValue > 0f)
            {
                Camera_ToUse.fieldOfView = Mathf.Clamp(Camera_ToUse.fieldOfView - Zoom_SpeedValue() * Time.deltaTime, minZoomInFOV, maxZoomOutFOV);
            }
            else if (scrollValue < 0f)
            {
                Camera_ToUse.fieldOfView = Mathf.Clamp(Camera_ToUse.fieldOfView + Zoom_SpeedValue() * Time.deltaTime, minZoomInFOV, maxZoomOutFOV);
            }
        }

        // Implementing the required methods from the IBoatActions interface
        public void OnMoveForward(InputAction.CallbackContext context) { }
        public void OnTurnLeft(InputAction.CallbackContext context) { }
        public void OnTurnRight(InputAction.CallbackContext context) { }
        public void OnMove(InputAction.CallbackContext context) { }
        public void OnLook(InputAction.CallbackContext context) { }
        public void OnActionButton1(InputAction.CallbackContext context) { }
        public void OnActionButton2(InputAction.CallbackContext context) { }
        public void OnActionButton3(InputAction.CallbackContext context) { }
        public void OnActionButton4(InputAction.CallbackContext context) { }
        public void OnActionButton5(InputAction.CallbackContext context) { }
        public void OnActionButton6(InputAction.CallbackContext context) { }
        public void OnActionButton7(InputAction.CallbackContext context) { }
        public void OnRotate(InputAction.CallbackContext context) { }
        public void OnFire(InputAction.CallbackContext context) { }

        protected float Move_SpeedValue()
        {
            return 10f; // Placeholder value, replace with actual logic if needed
        }

        protected float Zoom_SpeedValue()
        {
            return 10f; // Placeholder value, replace with actual logic if needed
        }

        protected float Rotate_SpeedValue()
        {
            return 10f; // Placeholder value, replace with actual logic if needed
        }
    }
}
