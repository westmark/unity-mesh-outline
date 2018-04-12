using UnityEngine;
using System.Collections;

public class OutlinePostEffect : MonoBehaviour
{
    Camera _mainCamera;
    Camera _maskCamera;
    RenderTexture _maskRT;
    RenderTexture _blurRT;

    public Shader Post_Outline;
    public Shader DrawSimple;
    public Color outlineColor = Color.green;
    Material _postMaterial;

    void Awake()
    {
        _blurRT = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.Default);
        _maskRT = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.Default);

        _mainCamera = GetComponent<Camera>();

        _maskCamera = new GameObject("MaskCamera").AddComponent<Camera>();
        _maskCamera.enabled = false;

        _postMaterial = new Material(Post_Outline);
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _maskCamera.CopyFrom(_mainCamera);
        _maskCamera.backgroundColor = Color.black;
        _maskCamera.clearFlags = CameraClearFlags.Nothing;

        _maskCamera.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        RenderTexture activeRT = RenderTexture.active;
        RenderTexture.active = _maskRT;

        GL.Clear(true, true, Color.clear);

        RenderTexture.active = activeRT;

        // 1. render selected objects into a mask buffer, with different colors for visible vs occluded ones (using existing Z buffer for testing)

        _maskCamera.targetTexture = _maskRT;
        //_maskCamera.SetTargetBuffers(_maskRT.colorBuffer, source.depthBuffer);
        _maskCamera.RenderWithShader(DrawSimple, "");
        // 1. End

        // 2. blur the mask information in two separable passes, keeping the mask channels
        _postMaterial.SetVector("_BlurDirection", new Vector2(0, 1));//Vertical
        Graphics.Blit(_maskRT, _blurRT, _postMaterial, 0);
        _postMaterial.SetVector("_BlurDirection", new Vector2(1, 0));//Horizontal
        Graphics.Blit(_blurRT, _maskRT, _postMaterial, 0);
        // 2. End

        // 3.blend outline over existing scene image.blurred information &mask channels allow computing distance to selected
        // This is the #1: final postprocessing pass in PostOutline.shader. Right now i just substract mask channel(col.r) from blurred channel(col.b) to get the outline
        Shader.SetGlobalColor("_OutlineColor", outlineColor);
        Graphics.Blit(source, destination);
        Graphics.Blit(_maskRT, destination, _postMaterial, 1);

        _maskRT.DiscardContents();
        _blurRT.DiscardContents();
    }
}