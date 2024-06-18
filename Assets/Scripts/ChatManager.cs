using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

public class ChatManager : MonoBehaviour
{
    public InputField inputField;
    public Text chatDisplay;
    public ScrollRect scrollRect;

    private List<string> messages = new List<string>();

    void Start()
    {
        // Example: Join global chat
        JoinChannel("Global");
    }

    public void SendMessage()
    {
        if (!string.IsNullOrEmpty(inputField.text))
        {
            messages.Add(inputField.text);
            inputField.text = "";
            UpdateChatDisplay();
        }
    }

    void UpdateChatDisplay()
    {
        chatDisplay.text = "";
        foreach (string message in messages)
        {
            chatDisplay.text += message + "\n"; // Fixed newline character
        }
        Canvas.ForceUpdateCanvases();
        scrollRect.verticalNormalizedPosition = 0;
    }

    public void JoinChannel(string channelName)
    {
        // Implement logic to join a chat channel
    }

    public void LeaveChannel(string channelName)
    {
        // Implement logic to leave a chat channel
    }
}
