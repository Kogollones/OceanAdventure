using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Water_Volume : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        public new RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        private Material material;

        RTHandle temporaryColorTexture;
        RTHandle temporaryDepthTexture;

        public CustomRenderPass(Material material)
        {
            this.material = material;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var descriptor = cameraTextureDescriptor;
            descriptor.depthBufferBits = 0;
            temporaryColorTexture = RTHandles.Alloc(descriptor);
            temporaryDepthTexture = RTHandles.Alloc(descriptor);

            ConfigureTarget(temporaryColorTexture, temporaryDepthTexture);
            ConfigureClear(ClearFlag.All, Color.black);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("Water_Volume");

            using (new ProfilingScope(cmd, new ProfilingSampler("Water_Volume")))
            {
                Blit(cmd, renderingData.cameraData.renderer.cameraColorTargetHandle, temporaryColorTexture, material, 0);
                Blit(cmd, temporaryColorTexture, renderingData.cameraData.renderer.cameraColorTargetHandle);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (temporaryColorTexture != null)
            {
                RTHandles.Release(temporaryColorTexture);
            }
            if (temporaryDepthTexture != null)
            {
                RTHandles.Release(temporaryDepthTexture);
            }
        }
    }

    [SerializeField] private Material material;
    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(material)
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}
