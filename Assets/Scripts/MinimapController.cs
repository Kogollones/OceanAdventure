using UnityEngine;
using UnityEngine.UI;

public class MinimapController : MonoBehaviour
{
    public Transform playerShip;  // Reference to the player's ship
    public RectTransform shipIcon;  // Reference to the ship icon on the minimap
    public RectTransform minimapBackground;  // Reference to the minimap background
    public float zoomLevel = 1.0f;  // Initial zoom level

    private Vector2 minimapSize;
    private Vector2 originalMinimapSize;

    void Start()
    {
        // Get the size of the minimap background
        originalMinimapSize = minimapBackground.rect.size;
        minimapSize = originalMinimapSize * zoomLevel;
    }

    void Update()
    {
        // Adjust the zoom level dynamically if needed
        AdjustZoomLevel(zoomLevel);

        if (playerShip != null && shipIcon != null)
        {
            // Convert the player's world position to minimap position
            Vector2 minimapPosition = WorldToMinimap(playerShip.position);
            shipIcon.anchoredPosition = minimapPosition;
        }
    }

    Vector2 WorldToMinimap(Vector3 worldPosition)
    {
        // Assuming your map image represents the bounds of your game world
        float mapWidth = 100f;  // Replace with your game world's width
        float mapHeight = 100f;  // Replace with your game world's height

        // Calculate the normalized position
        float x = (worldPosition.x / mapWidth) * minimapSize.x - minimapSize.x / 2;
        float y = (worldPosition.z / mapHeight) * minimapSize.y - minimapSize.y / 2;  // Assuming top-down view

        return new Vector2(x, y);
    }

    void AdjustZoomLevel(float zoom)
    {
        // Adjust the size of the minimap background based on the zoom level
        minimapBackground.sizeDelta = originalMinimapSize * zoom;
        minimapSize = minimapBackground.rect.size;
    }

    // Method to zoom in
    public void ZoomIn()
    {
        zoomLevel = Mathf.Max(zoomLevel - 0.1f, 0.5f);  // Minimum zoom level is 0.5
        AdjustZoomLevel(zoomLevel);
    }

    // Method to zoom out
    public void ZoomOut()
    {
        zoomLevel = Mathf.Min(zoomLevel + 0.1f, 2.0f);  // Maximum zoom level is 2.0
        AdjustZoomLevel(zoomLevel);
    }
}
