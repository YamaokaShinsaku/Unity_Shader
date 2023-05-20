Shader "MyShader/TOM"
{
    Properties
    {
        // ���C���e�N�X�`���[
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        {
            // �����_�����O�^�C�v�̐ݒ�
            "RenderType" = "Opaque"
            // "UniversalPipeline"�ȊO�ł͕`�悳��Ȃ��悤��
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            // Frame Debugger �\���p
            Name "ForwardLit"
            // URP��Forward�����_�����O�p�X
            Tags { "LightMode" = "UniversalForward" }

            // HLSL���g�p����
            HLSLPROGRAM
            // vertex/fragment �V�F�[�_�[�̂��w��
            #pragma vertex vert
            #pragma fragment frag
            // �t�H�O�p�̃o���A���g�𐶐�
            #pragma multi_compile_fog
            // Core.hlsl���C���N���[�h����
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            // ���_�̓���
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            // vertex/fragment �V�F�[�_�[�p�̕ϐ�
            struct v2f
            {
                /// UV���W
                float2 uv : TEXCOORD0;
                // �t�H�O�v�Z�Ŏg�p����fog factor�̕��
                float fogFactor : TEXCOORD1;
                // �I�u�W�F�N�g�x�[�X�̒��_���W
                float4 vertex : SV_POSITION;
            };
            
            // �摜���`
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            // CBuffer���`
            // SRP Batcher �ւ̑Ή�
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            CBUFFER_END
            
            // ���_�V�F�[�_�[
            v2f vert(appdata v)
            {
                v2f o;
                // �I�u�W�F�N�g��Ԃ���J�����̃N���b�v��Ԃ֓_��ϊ�
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                // UV�󂯎��
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // �t�H�O���x�̌v�Z
                o.fogFactor = ComputeFogFactor(o.vertex.z);

                return o;
            }            
            // �t���O�����g�V�F�[�_�[
            float4 frag(v2f i) : SV_Target
            {
                // �e�N�X�`���̃T���v�����O
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // �t�H�O��K��
                col.rgb = MixFog(col.rgb, i.fogFactor);

                return col;
            }
            ENDHLSL           
        }
    }
}