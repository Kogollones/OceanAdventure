using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CameraController
{
    public class CameraController : MonoBehaviour
    {
        public static CameraController Instance = null;

        public Camera Camera_ToUse;
        public Camera UI_Camera;

        public Transform FollowTarget = null;
        public Vector3 TargetOffset = new Vector3(0, 10, -10);
        public float maxZoomOutFOV = 120f;
        public float minZoomInFOV = 30f;
        public float smoothSpeed = 0.125f;  // Smoothing speed for camera movement

        // USED WITH EDITOR!
        public bool ShowHelp = false;

        private void Awake()
        {
            if (Instance == null)
                Instance = this;
            else
                Destroy(gameObject);
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

                Camera_ToUse.transform.rotation = Quaternion.Euler(45f, 0f, 0f);
            }

            HandleZoom();
        }

        private void HandleZoom()
        {
            var mouse = Mouse.current;
            if (mouse != null)
            {
                if (mouse.scroll.y.ReadValue() > 0f)
                {
                    Camera_ToUse.fieldOfView = Mathf.Clamp(Camera_ToUse.fieldOfView - Zoom_SpeedValue() * Time.deltaTime, minZoomInFOV, maxZoomOutFOV);
                }
                else if (mouse.scroll.y.ReadValue() < 0f)
                {
                    Camera_ToUse.fieldOfView = Mathf.Clamp(Camera_ToUse.fieldOfView + Zoom_SpeedValue() * Time.deltaTime, minZoomInFOV, maxZoomOutFOV);
                }
            }
        }

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
