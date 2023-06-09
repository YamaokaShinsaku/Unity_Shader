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
        _RimShadeColor1("RimShade  BaseColor", Color) = (0, 0, 0, 1)
        // �e���x
        _RimShadeColorWeight1("RimShade Influence", Range(0, 1)) = 0.5
        // �O���f�[�V�����͈�
        _RimShadeMinPower1("RimShade  GradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�̑���
        _RimShadePowerWeight1("RimShade  Intensity", Range(1, 10)) = 10      

        // �u�O���v �̃����A
        // �F
        _RimShadeColor2("RimShade OutsideColor", Color) = (0, 0, 0, 1)
        // �e���x
        _RimShadeColorWeight2("RimShade OutsideInfluence", Range(0, 1)) = 0.8
        // �O���f�[�V�����͈�
        _RimShadeMinPower2("RimShade  OutsideGradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�̑���
        _RimShadePowerWeight2("RimShade  OutSideIntensity", Range(1, 10)) = 2

        // �����A�̃}�X�N
        // �O���f�[�V�����͈�
        _RimShadeMaskMinPower("RimShadeMask  GradationRange", Range(0, 1)) = 0.3
        // �ŔZ�����A�}�X�N�̑���
        _RimShadeMaskPowerWeight("RimShadeMask  Intensity", Range(0, 10)) = 2

        // �������C�g
        // �e���͈�
        _RimLightWeight("RimLight  Influence", Range(0, 1)) = 0.5
        // �O���f�[�V�����͈�
        _RimLightPower("RimLight  GradationRange", Range(1, 5)) = 3

        // �A���r�G���g�J���[
        _AmbientColor("Ambient  Color", Color) = (0.5, 0.5, 0.5, 1)

        // �X�y�L����
        // ���炩��
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        // �e���x
        _SpecularRate("Specular  Influence", Range(0, 1)) = 0.3

        // �A�E�g���C��
        // ��
        _OutlineWidth("Outline  Width", Range(0, 1)) = 0.1
        // �F
        _OutlineColor("Outline  Color", Color) = (0, 0, 0, 1)

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
            // �O�ʂ��J�����O
            Cull Front

            // HLSL���g�p����
            HLSLPROGRAM
            // vertex/fragment �V�F�[�_�[���w��
            #pragma vertex vert
            #pragma fragment frag
            // Core.hlsl���C���N���[�h
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // ���_�̓���
            struct appdata
            {
                half4 vertex : POSITION;
                half3 normal :  NORMAL;
                float2 uv : TEXCOORD0;
            };
            // vertex/fragment �V�F�[�_�[�p�̕ϐ�
            struct v2f
            {
                half4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // �摜���`
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityMPerMaterial)
            float4 _MainTex_ST;

            half _OutlineWidth;
            half4 _OutlineColor;
            CBUFFER_END

            // ���_�V�F�[�_�[
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                // �A�E�g���C���̕������@�������Ɋg�傷��
                o.vertex = TransformObjectToHClip(v.vertex + v.normal * (_OutlineWidth / 100));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }
            // �t���O�����g�V�F�[�_�[
            float4 frag(v2f i) : SV_Target
            {
                // �e�N�X�`���̃T���v�����O
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // �\�ʂ̐F�ɃA�E�g���C���̐F���u�����h���Ďg�p����
                return col * _OutlineColor;
            }
            ENDHLSL
        }


        Pass
        {
            // Frame Debugger �\���p
            Name "ForwardLit"
            // URP��Forward�����_�����O�p�X
            Tags { "LightMode" = "UniversalForward" }

            // HLSL���g�p����
            HLSLPROGRAM
            // vertex/fragment �V�F�[�_�[���w��
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
                // ���_���王���ʒu�ւ̃x�N�g��
                float3 toEye : TEXCOORD5;
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

            float3 _RimShadeColor1;
            float _RimShadeColorWeight1;
            float _RimShadeMinPower1;
            float _RimShadePowerWeight1;

            float3 _RimShadeColor2;
            float _RimShadeColorWeight2;
            float _RimShadeMinPower2;
            float _RimShadePowerWeight2;

            float _RimShadeMaskMinPower;
            float _RimShadeMaskPowerWeight;

            float _RimLightPower;
            float _RimLightWeight;

            float3 _AmbientColor;

            float _Smoothness;
            float _SpecularRate;

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
                // ���_�ʒu���王�������ւ̃x�N�g�����v�Z
                o.toEye = normalize(GetWorldSpaceViewDir(TransformObjectToWorld(v.vertex.xyz)));
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
                float RimPower = 1 - max(0, dot(i.normal, i.viewDir));
                // �A�̉e�����n�܂�͈͂𒲐�����p�����[�^
                float RimShadePower = inverseLerp(_RimShadeMinPower1, 1.0, RimPower);
                // �A�F�̔��f�͈͂𒲐�����p�����[�^
                RimShadePower = min(RimShadePower * _RimShadePowerWeight1, 1);
                // �����A�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb * _RimShadeColor1, RimShadePower * _RimShadeColorWeight1);

                // �A�Q(�A�P�̏ォ�炳��ɐF���悹��)�̌v�Z���s��
                RimShadePower = inverseLerp(_RimShadeMinPower2, 1.0, RimPower);
                // �A�F�̔��f�͈͂𒲐�����p�����[�^
                RimShadePower = min(RimShadePower * _RimShadePowerWeight2, 1);
                // �����A�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb * _RimShadeColor2, RimShadePower * _RimShadeColorWeight2);

                // �A�̃}�X�N�̌v�Z
                 // �}�X�N�̉e�����n�܂�͈͂𒲐�����p�����[�^
                float RimShadeMaskPower = inverseLerp(_RimShadeMaskMinPower, 1, RimPower);
                // �}�X�N�̔��f�͈͂𒲐�����p�����[�^
                RimShadeMaskPower = min(RimShadeMaskPower * _RimShadeMaskPowerWeight, 1);
                // �A�̃}�X�N�𒲐�
                col.rgb = lerp(col.rgb, albedo.rgb, RimShadeMaskPower);

                // �������C�g
                // ���C�����C�g�̏����擾
                Light light = GetMainLight();
                // ��Ԓl���v�Z
                float RimLightPower = 1 - max(0, dot(i.normal, -light.direction));
                // �ŏI�I�Ȕ��ˌ��i�������C�g�j
                float3 RimLight = pow(saturate(RimPower * RimLightPower), _RimLightPower) * light.color;
                // �������C�g�̐F�����Z
                col.rgb += RimLight * _RimLightWeight;

                // Half-Lambert�g�U���ˌ�
                float3 diffuseLight = CalcHalfLambertDiffuse(light.direction, light.color, i.normal);
                // ���ˌ��͈̔�
                float shinePower = lerp(0.5, 10, _Smoothness);
                // �X�y�L�����[���C�g���쐬
                float3 specularLight = CalcPhongSpecular(-light.direction, light.color, i.toEye, i.normal, shinePower);
                specularLight = lerp(0, specularLight, _SpecularRate);

                col.rgb *= diffuseLight + specularLight + _AmbientColor;

                // �t�H�O��K��
                col.rgb = MixFog(col.rgb, i.fogFactor);

                return col;
            }
            ENDHLSL
        }
    }
}