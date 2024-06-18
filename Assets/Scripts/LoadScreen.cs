
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections;

public class LoadScreen : MonoBehaviour
{
    public GameObject loadingScreen;
    public Slider loadingBar;
    public Text tipsText;
    public string[] tips;

    private void Start()
    {
        StartCoroutine(LoadAsynchronously("MainScene"));
    }

    IEnumerator LoadAsynchronously(string sceneName)
    {
        AsyncOperation operation = SceneManager.LoadSceneAsync(sceneName);
        loadingScreen.SetActive(true);

        while (!operation.isDone)
        {
            float progress = Mathf.Clamp01(operation.progress / 0.9f);
            loadingBar.value = progress;
            tipsText.text = tips[Random.Range(0, tips.Length)];
            yield return null;
        }

        loadingScreen.SetActive(false);
    }
}
