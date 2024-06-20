using UnityEngine;
using Photon.Pun;

public class PlayerManager : MonoBehaviourPun
{
    void Start()
    {
        if (photonView == null)
        {
            Debug.LogError("PlayerManager: PhotonView is null.");
            return;
        }

        if (photonView.IsMine)
        {
            // Initialize player ship
            Debug.Log("PlayerManager: Initialized player ship for local player.");

            // Set the camera to follow the player ship
            CameraController.CameraController.Instance.FollowTarget = transform;
        }
        else
        {
            Camera playerCamera = GetComponentInChildren<Camera>();
            if (playerCamera != null)
            {
                Destroy(playerCamera.gameObject);
                Debug.Log("PlayerManager: Destroyed camera for remote player.");
            }
            else
            {
                Debug.LogError("PlayerManager: No Camera found in children.");
            }
        }
    }
}
