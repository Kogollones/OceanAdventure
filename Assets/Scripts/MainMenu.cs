using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class MainMenuManager : MonoBehaviour
{
    public AudioSource audioSource;
    public AudioClip buttonClickSound;

    private InputActions inputActions;

    private void Awake()
    {
        inputActions = new InputActions();
        inputActions.UI.Submit.performed += ctx => OnSubmit();
        inputActions.UI.Move.performed += ctx => OnMove(ctx.ReadValue<Vector2>());
    }

    private void OnEnable()
    {
        inputActions.UI.Enable();
    }

    private void OnDisable()
    {
        inputActions.UI.Disable();
    }

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    private void OnSubmit()
    {
        // Handle click/submit
    }

    private void OnMove(Vector2 direction)
    {
        // Handle navigation/move
    }

    public void PlayGame()
    {
        PlayButtonSound();
        SceneManager.LoadScene("GameScene");
    }

    public void OpenSettings()
    {
        PlayButtonSound();
        // Open settings menu
    }

    public void Tutorial()
    {
        PlayButtonSound();
        // Open tutorial scene
    }

    public void ExitGame()
    {
        PlayButtonSound();
        Application.Quit();
    }

    private void PlayButtonSound()
    {
        audioSource.PlayOneShot(buttonClickSound);
    }
}
