Shader "MyShader/TOM"
{
    Properties
    {
        // メインテクスチャ
        _MainTex("Texture", 2D) = "white" {}

        // ノーマルマップ
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0, 2)) = 1

        // リム陰(リムライトの陰影版) ベース
        // 色（ベース）
        _LimShadeColor1("RimShade  BaseColor", Color) = (0, 0, 0, 1)
        // 影響度
        _LimShadeColorWeight1("RimShade Influence", Range(0, 1)) = 0.5
        // グラデーション範囲
        _LimShadeMinPower1("RimShade  GradationRange", Range(0, 1)) = 0.3
        // 最濃リム陰の太さ
        _LimShadePowerWeight1("RimShade  Intensity", Range(1, 10)) = 10      

        // 「外側」 のリム陰
        // 色
        _LimShadeColor2("RimShade OutsideColor", Color) = (0, 0, 0, 1)
        // 影響度
        _LimShadeColorWeight2("RimShade OutsideInfluence", Range(0, 1)) = 0.8
        // グラデーション範囲
        _LimShadeMinPower2("RimShade  OutsideGradationRange", Range(0, 1)) = 0.3
        // 最濃リム陰の太さ
        _LimShadePowerWeight2("RimShade  OutSideIntensity", Range(1, 10)) = 2

        // リム陰のマスク
        // グラデーション範囲
        _LimShadeMaskMinPower("RimShadeMask  GradationRange", Range(0, 1)) = 0.3
        // 最濃リム陰マスクの太さ
        _LimShadeMaskPowerWeight("RimShadeMask  Intensity", Range(0, 10)) = 2

        // リムライト
        // 影響範囲
        _LimLightWeight("RimLight  Influence", Range(0, 1)) = 0.5
        // グラデーション範囲
        _LimLightPower("RimLight  GradationRange", Range(1, 5)) = 3

        // アンビエントカラー
        _AmbientColor("Ambient  Color", Color) = (0.5, 0.5, 0.5, 1)

    }
    SubShader
    {
        Tags 
        {
            // レンダリングタイプの設定
            "RenderType" = "Opaque"
            // "UniversalPipeline"以外では描画されないように
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            // Frame Debugger 表示用
            Name "ForwardLit"
            // URPのForwardレンダリングパス
            Tags { "LightMode" = "UniversalForward" }

            // HLSLを使用する
            HLSLPROGRAM
            // vertex/fragment シェーダーのを指定
            #pragma vertex vert
            #pragma fragment frag
            // フォグ用のバリアントを生成
            #pragma multi_compile_fog
            // Core.hlslをインクルードする
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // Lighting.hlslをインクルードする
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            // 自作関数ファイルをインクルードする
            #include "Custom.cginc"

            
            // 頂点の入力
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            // vertex/fragment シェーダー用の変数
            struct v2f
            {
                /// UV座標
                float2 uv : TEXCOORD0;
                // フォグ計算で使用するfog factorの補間
                float fogFactor : TEXCOORD1;
                // オブジェクトベースの頂点座標
                float4 vertex : SV_POSITION;

                // ノーマルマップで使用する変数を定義
                float3 normal   : NORMAL;
                float2 uvNormal : TEXCOORD2;
                float4 tangent  : TANGENT;
                float3 binormal : TEXCOORD3;

                // 視線方向を定義
                float3 viewDir : TEXCOORD4;
            };
            
            // 画像を定義
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);
            
            // CBufferを定義
            // SRP Batcher への対応
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
            
            // 頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                // オブジェクト空間からカメラのクリップ空間へ点を変換
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                // UV受け取り
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // フォグ強度の計算
                o.fogFactor = ComputeFogFactor(o.vertex.z);

                // 法線をワールド空間へ変換
                o.normal = TransformObjectToWorldNormal(v.normal);
                // テクスチャ(_BumpMap)とuv座標を関連づける
                o.uvNormal = TRANSFORM_TEX(v.uv, _BumpMap);
                // 接線をワールド空間へ変換
                o.tangent = v.tangent;
                o.tangent.xyz = TransformObjectToWorldDir(v.tangent.xyz);
                // 従法線を計算（法線と接線の外積）
                o.binormal 
                    = normalize(cross(v.normal, v.tangent.xyz) * v.tangent.w * unity_WorldTransformParams.w);

                // 視線方向を計算
                o.viewDir = normalize(-GetViewForwardDir());

                return o;
            }
            // フラグメントシェーダー
            float4 frag(v2f i) : SV_Target
            {
                // テクスチャのサンプリング
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // テクスチャから取得したオリジナルの色を保持
                float4 albedo = col;

                // ノーマルマップから法線情報を取得
                float3 localNormal 
                    = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uvNormal), _BumpScale);
                // タンジェントスペースの法線をワールドスペースに変換
                i.normal = i.tangent * localNormal.x + i.binormal * localNormal.y + i.normal * localNormal.z;

                // 陰１(視線方向に依存して体のフチに色を乗算)の計算を行う
                float limPower = 1 - max(0, dot(i.normal, i.viewDir));
                // 陰の影響が始まる範囲を調整するパラメータ
                float limShadePower = inverseLerp(_LimShadeMinPower1, 1.0, limPower);
                // 陰色の反映範囲を調整するパラメータ
                limShadePower = min(limShadePower * _LimShadePowerWeight1, 1);
                // リム陰を調整
                col.rgb = lerp(col.rgb, albedo.rgb * _LimShadeColor1, limShadePower * _LimShadeColorWeight1);

                // 陰２(陰１の上からさらに色を乗せる)の計算を行う
                limShadePower = inverseLerp(_LimShadeMinPower2, 1.0, limPower);
                // 陰色の反映範囲を調整するパラメータ
                limShadePower = min(limShadePower * _LimShadePowerWeight2, 1);
                // リム陰を調整
                col.rgb = lerp(col.rgb, albedo.rgb * _LimShadeColor2, limShadePower * _LimShadeColorWeight2);

                // 陰のマスクの計算
                 // マスクの影響が始まる範囲を調整するパラメータ
                float limShadeMaskPower = inverseLerp(_LimShadeMaskMinPower, 1, limPower);
                // マスクの反映範囲を調整するパラメータ
                limShadeMaskPower = min(limShadeMaskPower * _LimShadeMaskPowerWeight, 1);
                // 陰のマスクを調整
                col.rgb = lerp(col.rgb, albedo.rgb, limShadeMaskPower);

                // リムライト
                // メインライトの情報を取得
                Light light = GetMainLight();
                // 補間値を計算
                float limLightPower = 1 - max(0, dot(i.normal, -light.direction));
                // 最終的な反射光（リムライト）
                float3 limLight = pow(saturate(limPower * limLightPower), _LimLightPower) * light.color;
                // リムライトの色を加算
                col.rgb += limLight * _LimLightWeight;

                // Half-Lambert拡散反射光
                float3 diffuseLight = CalcHalfLambertDiffuse(light.direction, light.color, i.normal);
                col.rgb *= diffuseLight + _AmbientColor;

                // フォグを適応
                col.rgb = MixFog(col.rgb, i.fogFactor);

                return col;
            }
            ENDHLSL
        }
    }
}