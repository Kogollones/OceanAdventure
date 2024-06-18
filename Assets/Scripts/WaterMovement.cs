using UnityEngine;

public class WaterMovement : MonoBehaviour
{
    private Material material;
    public float speed = 1f;

    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        material = renderer.material;
    }

    private void Update()
    {
        if (material.HasProperty("_Ripple"))
        {
            float ripple = Mathf.PingPong(Time.time * speed, 1f);
            material.SetFloat("_Ripple", ripple);
        }
    }

    public float GetRippleEffect()
    {
        if (material.HasProperty("_Ripple"))
        {
            return material.GetFloat("_Ripple");
        }
        return 0f; // Return 0 if the _Ripple property does not exist
    }
}
