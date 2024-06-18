
using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

public class SettingsMenu : MonoBehaviour
{
    public Slider volumeSlider;
    public Dropdown resolutionDropdown;
    public Dropdown qualityDropdown;
    public Toggle fullscreenToggle;
    public Toggle showFPSToggle;
    public Toggle showPingToggle;
    public Text fpsText;
    public Text pingText;

    private Resolution[] resolutions;

    private void Start()
    {
        resolutions = Screen.resolutions;
        resolutionDropdown.ClearOptions();

        int currentResolutionIndex = 0;
        List<string> options = new List<string>();

        for (int i = 0; i < resolutions.Length; i++)
        {
            string option = resolutions[i].width + " x " + resolutions[i].height;
            options.Add(option);

            if (resolutions[i].width == Screen.currentResolution.width &&
                resolutions[i].height == Screen.currentResolution.height)
            {
                currentResolutionIndex = i;
            }
        }

        resolutionDropdown.AddOptions(options);
        resolutionDropdown.value = currentResolutionIndex;
        resolutionDropdown.RefreshShownValue();

        LoadSettings();
    }

    public void SetVolume(float volume)
    {
        AudioListener.volume = volume;
    }

    public void SetQuality(int qualityIndex)
    {
        QualitySettings.SetQualityLevel(qualityIndex);
    }

    public void SetResolution(int resolutionIndex)
    {
        Resolution resolution = resolutions[resolutionIndex];
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);
    }

    public void SetFullscreen(bool isFullscreen)
    {
        Screen.fullScreen = isFullscreen;
    }

    public void SetShowFPS(bool showFPS)
    {
        fpsText.gameObject.SetActive(showFPS);
    }

    public void SetShowPing(bool showPing)
    {
        pingText.gameObject.SetActive(showPing);
    }

    public void SaveSettings()
    {
        PlayerPrefs.SetFloat("Volume", volumeSlider.value);
        PlayerPrefs.SetInt("Quality", qualityDropdown.value);
        PlayerPrefs.SetInt("Resolution", resolutionDropdown.value);
        PlayerPrefs.SetInt("Fullscreen", fullscreenToggle.isOn ? 1 : 0);
        PlayerPrefs.SetInt("ShowFPS", showFPSToggle.isOn ? 1 : 0);
        PlayerPrefs.SetInt("ShowPing", showPingToggle.isOn ? 1 : 0);
    }

    public void LoadSettings()
    {
        volumeSlider.value = PlayerPrefs.GetFloat("Volume", 1f);
        qualityDropdown.value = PlayerPrefs.GetInt("Quality", 2);
        resolutionDropdown.value = PlayerPrefs.GetInt("Resolution", resolutions.Length - 1);
        fullscreenToggle.isOn = PlayerPrefs.GetInt("Fullscreen", 1) == 1;
        showFPSToggle.isOn = PlayerPrefs.GetInt("ShowFPS", 0) == 1;
        showPingToggle.isOn = PlayerPrefs.GetInt("ShowPing", 0) == 1;

        fpsText.gameObject.SetActive(showFPSToggle.isOn);
        pingText.gameObject.SetActive(showPingToggle.isOn);
    }
}
