Shader "MyShader/TOM"
{
    Properties
    {
        // メインテクスチャー
        _MainTex("Texture", 2D) = "white" {}
        // バンプマップ
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0, 2)) = 1
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

                return o;
            }
            // フラグメントシェーダー
            float4 frag(v2f i) : SV_Target
            {
                // テクスチャのサンプリング
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // ノーマルマップから法線情報を取得
                float3 localNormal 
                    = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uvNormal), _BumpScale);
                // タンジェントスペースの法線をワールドスペースに変換
                i.normal = i.tangent * localNormal.x + i.binormal * localNormal.y + i.normal * localNormal.z;

                // フォグを適応
                col.rgb = MixFog(col.rgb, i.fogFactor);

                return col;
            }
            ENDHLSL
        }
    }
}