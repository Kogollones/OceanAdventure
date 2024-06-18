
using UnityEngine;
using System.Collections.Generic;

public class KeybindingManager : MonoBehaviour
{
    public static KeybindingManager Instance;

    private Dictionary<string, KeyCode> keybindings = new Dictionary<string, KeyCode>();

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

        // Set default keybindings
        SetDefaultKeybindings();
    }

    void SetDefaultKeybindings()
    {
        keybindings["MoveForward"] = KeyCode.W;
        keybindings["MoveBackward"] = KeyCode.S;
        keybindings["MoveLeft"] = KeyCode.A;
        keybindings["MoveRight"] = KeyCode.D;
        keybindings["UseSkill1"] = KeyCode.Alpha1;
        keybindings["UseSkill2"] = KeyCode.Alpha2;
        keybindings["OpenMap"] = KeyCode.M;
        keybindings["OpenInventory"] = KeyCode.I;
    }

    public void SetKeybinding(string action, KeyCode key)
    {
        if (keybindings.ContainsKey(action))
        {
            keybindings[action] = key;
        }
    }

    public KeyCode GetKeybinding(string action)
    {
        return keybindings.ContainsKey(action) ? keybindings[action] : KeyCode.None;
    }
}
