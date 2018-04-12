Shader "Custom/DrawSimple"
{
    SubShader
    {
        // #0: things that are visible (pass depth). 1 in alpha, 1 in red (SM2.0)
        Pass
        {
 
            //One = The value of one - use this to let either the source or the destination color come through fully.
            //Zero = The value zero - use this to remove either the source or the destination values.
            Blend One Zero
 
            //Only render pixels whose reference value is less than or equal to the value in the buffer.
            ZTest LEqual
         
            //Off = Disables culling - all faces are drawn. Used for special effects.
            Cull Off
 
            //Controls whether pixels from this object are written to the depth buffer (default is On). If you’re drawng solid objects, leave this on.
            //If you’re drawing semitransparent effects, switch to ZWrite Off. For more details read below.
            ZWrite Off
            // push towards camera a bit, so that coord mismatch due to dynamic batching is not affecting us
            Offset -0.02, 0
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
 
            float _ObjectId = 1;
            #define DRAW_COLOR float4(1,1,1, 1)
            #include "SceneViewSelected.cginc"
            ENDCG
        }
        // #2: all the things, including the ones that fail the depth test. Additive blend, 1 in green, 1 in alpha (SM2.0)
        Pass
        {
            //Additive Blending
            Blend One One
            //Use the larger of source and destination.
            BlendOp Max
            //Always passes
            ZTest Always
            //Controls whether pixels from this object are written to the depth buffer (default is On). If you’re drawng solid objects, leave this on.
            //If you’re drawing semitransparent effects, switch to ZWrite Off. For more details read below.
            ZWrite Off
            //Off = Disables culling - all faces are drawn. Used for special effects.
            Cull Off
            //Set color channel writing mask. Writing ColorMask 0 turns off rendering to all color channels.
            //Default mode is writing to all channels (RGBA), but for some special effects you might want to leave certain channels unmodified, or disable color writes completely.
            ColorMask GBA
            // push towards camera a bit, so that coord mismatch due to dynamic batching is not affecting us
            Offset -0.02, 0
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            float _ObjectId;
            #define DRAW_COLOR float4(0, 0, 1, 1)
            #include "SceneViewSelected.cginc"
            ENDCG
        }
    }
 
}