using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

public class SkillBar : MonoBehaviour, InputActions.IBoatActions
{
    public Button[] skillButtons;
    private InputActions inputActions;

    private void Awake()
    {
        inputActions = new InputActions();
        inputActions.Boat.SetCallbacks(this);
        inputActions.Enable();
    }

    private void OnDestroy()
    {
        inputActions.Disable();
    }

    public void OnActionButton1(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(0);
        }
    }

    public void OnActionButton2(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(1);
        }
    }

    public void OnActionButton3(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(2);
        }
    }

    public void OnActionButton4(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(3);
        }
    }

    public void OnActionButton5(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(4);
        }
    }

    public void OnActionButton6(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(5);
        }
    }

    public void OnActionButton7(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(6);
        }
    }

    public void OnActionButton8(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            ActivateSkill(7);
        }
    }

    private void ActivateSkill(int skillIndex)
    {
        if (skillIndex >= 0 && skillIndex < skillButtons.Length)
        {
            PlayerShip.Instance.ActivateSkill(skillIndex);
        }
    }

    // Unused methods from IBoatActions interface
    public void OnLook(InputAction.CallbackContext context) { }
    public void OnZoom(InputAction.CallbackContext context) { }
    public void OnMoveForward(InputAction.CallbackContext context) { }
    public void OnTurnLeft(InputAction.CallbackContext context) { }
    public void OnTurnRight(InputAction.CallbackContext context) { }
    public void OnFire(InputAction.CallbackContext context) { }
    public void OnRotate(InputAction.CallbackContext context) { }
}
