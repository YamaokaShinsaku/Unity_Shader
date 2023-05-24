Shader "MyShader/TOM"
{
    Properties
    {
        // ���C���e�N�X�`��
        _MainTex("Texture", 2D) = "white" {}

        // �m�[�}���}�b�v
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0, 2)) = 1

        // �����A(�������C�g�̉A�e��) �x�[�X
        // �F�i�x�[�X�j
        _LimShadeColor1("RimShade  BaseColor", Color) = (0, 0, 0, 1)
        // �e���x
        _LimShadeColorWeight1("RimShade Influence", Range(0, 1)) = 0.5
        // �O���f�[�V�����͈�
        _LimShadeMinPower1("RimShade  GradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�̑���
        _LimShadePowerWeight1("RimShade  Intensity", Range(1, 10)) = 10      

        // �u�O���v �̃����A
        // �F
        _LimShadeColor2("RimShade OutsideColor", Color) = (0, 0, 0, 1)
        // �e���x
        _LimShadeColorWeight2("RimShade OutsideInfluence", Range(0, 1)) = 0.8
        // �O���f�[�V�����͈�
        _LimShadeMinPower2("RimShade  OutsideGradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�̑���
        _LimShadePowerWeight2("RimShade  OutSideIntensity", Range(1, 10)) = 2

        // �����A�̃}�X�N
        // �O���f�[�V�����͈�
        _LimShadeMaskMinPower("RimShadeMask  GradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�}�X�N�̑���
        _LimShadeMaskPowerWeight("RimShadeMask  Intensity", Range(0, 10)) = 2

        // �������C�g
        // �e���͈�
        _LimLightWeight("RimLight  Influence", Range(0, 1)) = 0.5
        // �O���f�[�V�����͈�
        _LimLightPower("RimLight  GradationRange", Range(1, 5)) = 3

        // �A���r�G���g�J���[
        _AmbientColor("Ambient  Color", Color) = (0.5, 0.5, 0.5, 1)

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
            // Lighting.hlsl���C���N���[�h����
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            // ����֐��t�@�C�����C���N���[�h����
            #include "Custom.cginc"

            
            // ���_�̓���
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal : NORMAL;
                float4 tangent : TANGENT;
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

                // �m�[�}���}�b�v�Ŏg�p����ϐ����`
                float3 normal   : NORMAL;
                float2 uvNormal : TEXCOORD2;
                float4 tangent  : TANGENT;
                float3 binormal : TEXCOORD3;

                // �����������`
                float3 viewDir : TEXCOORD4;
            };
            
            // �摜���`
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);
            
            // CBuffer���`
            // SRP Batcher �ւ̑Ή�
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;

            float4 _BumpMap_ST;
            float _BumpScale;

            float3 _LimShadeColor1;
            float _LimShadeColorWeight1;
            float _LimShadeMinPower1;
            float _LimShadePowerWeight1;

            float3 _LimShadeColor2;
            float _LimShadeColorWeight2;
            float _LimShadeMinPower2;
            float _LimShadePowerWeight2;

            float _LimShadeMaskMinPower;
            float _LimShadeMaskPowerWeight;

            float _LimLightPower;
            float _LimLightWeight;

            float3 _AmbientColor;

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

                // �@�������[���h��Ԃ֕ϊ�
                o.normal = TransformObjectToWorldNormal(v.normal);
                // �e�N�X�`��(_BumpMap)��uv���W���֘A�Â���
                o.uvNormal = TRANSFORM_TEX(v.uv, _BumpMap);
                // �ڐ������[���h��Ԃ֕ϊ�
                o.tangent = v.tangent;
                o.tangent.xyz = TransformObjectToWorldDir(v.tangent.xyz);
                // �]�@�����v�Z�i�@���Ɛڐ��̊O�ρj
                o.binormal 
                    = normalize(cross(v.normal, v.tangent.xyz) * v.tangent.w * unity_WorldTransformParams.w);

                // �����������v�Z
                o.viewDir = normalize(-GetViewForwardDir());

                return o;
            }
            // �t���O�����g�V�F�[�_�[
            float4 frag(v2f i) : SV_Target
            {
                // �e�N�X�`���̃T���v�����O
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // �e�N�X�`������擾�����I���W�i���̐F��ێ�
                float4 albedo = col;

                // �m�[�}���}�b�v����@�������擾
                float3 localNormal 
                    = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uvNormal), _BumpScale);
                // �^���W�F���g�X�y�[�X�̖@�������[���h�X�y�[�X�ɕϊ�
                i.normal = i.tangent * localNormal.x + i.binormal * localNormal.y + i.normal * localNormal.z;

                // �A�P(���������Ɉˑ����đ̂̃t�`�ɐF����Z)�̌v�Z���s��
                float limPower = 1 - max(0, dot(i.normal, i.viewDir));
                // �A�̉e�����n�܂�͈͂𒲐�����p�����[�^
                float limShadePower = inverseLerp(_LimShadeMinPower1, 1.0, limPower);
                // �A�F�̔��f�͈͂𒲐�����p�����[�^
                limShadePower = min(limShadePower * _LimShadePowerWeight1, 1);
                // �����A�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb * _LimShadeColor1, limShadePower * _LimShadeColorWeight1);

                // �A�Q(�A�P�̏ォ�炳��ɐF���悹��)�̌v�Z���s��
                limShadePower = inverseLerp(_LimShadeMinPower2, 1.0, limPower);
                // �A�F�̔��f�͈͂𒲐�����p�����[�^
                limShadePower = min(limShadePower * _LimShadePowerWeight2, 1);
                // �����A�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb * _LimShadeColor2, limShadePower * _LimShadeColorWeight2);

                // �A�̃}�X�N�̌v�Z
                 // �}�X�N�̉e�����n�܂�͈͂𒲐�����p�����[�^
                float limShadeMaskPower = inverseLerp(_LimShadeMaskMinPower, 1, limPower);
                // �}�X�N�̔��f�͈͂𒲐�����p�����[�^
                limShadeMaskPower = min(limShadeMaskPower * _LimShadeMaskPowerWeight, 1);
                // �A�̃}�X�N�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb, limShadeMaskPower);

                // �������C�g
                // ���C�����C�g�̏����擾
                Light light = GetMainLight();
                // ��Ԓl���v�Z
                float limLightPower = 1 - max(0, dot(i.normal, -light.direction));
                // �ŏI�I�Ȕ��ˌ��i�������C�g�j
                float3 limLight = pow(saturate(limPower * limLightPower), _LimLightPower) * light.color;
                // �������C�g�̐F�����Z
                col.rgb += limLight * _LimLightWeight;

                // Half-Lambert�g�U���ˌ�
                float3 diffuseLight = CalcHalfLambertDiffuse(light.direction, light.color, i.normal);
                col.rgb *= diffuseLight + _AmbientColor;

                // �t�H�O��K��
                col.rgb = MixFog(col.rgb, i.fogFactor);

                return col;
            }
            ENDHLSL
        }
    }
}