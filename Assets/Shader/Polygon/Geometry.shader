Shader "MyShader/Geometry"
{
    Properties
    {
        _ScaleFactor("Scale Factor", Range(0,1.0)) = 0.5
        _PositionFactor("Position Factor", Range(0,1.0)) = 0.5
        _RotationFactor("Rotation Factor", Range(0,1.0)) = 0.5
    }
        SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        //���ʕ`��
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _PositionFactor;
            float _RotationFactor;
            float _ScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 localPos : TEXCOORD0;
            };

            //���_�V�F�[�_�[
            appdata vert(appdata v)
            {
                appdata o;
                //�W�I���g���[�V�F�[�_�[�Œ��_�𓮂����O��"�`�悵�悤�Ƃ��Ă���s�N�Z��"�̃��[�J�����W��ێ����Ă���
                o.localPos = v.vertex.xyz; 
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            //��]������
            //p�͉�]�����������W�@angle�͉�]������p�x�@axis�͂ǂ̎������ɉ�]�����邩�@
            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            //�����_���Ȓl��Ԃ�
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // �W�I���g���V�F�[�_�[
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID,inout TriangleStream<g2f> stream)
            {
                // �@�����v�Z
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                //1���̃|���S���̒��S
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                float random = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = random.xxx;

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //�ړ��ɗ��p����ʒu�x�N�g����ێ�
                    // float3 currentPos = normal * _PositionFactor * abs(r3); 
                    //���̒l�͖@���Ƌt�����Ɉړ����Ă��܂��̂Ő�Βl���p
                    // //�@���x�N�g���ɉ����Ē��_���ړ�
                    // v.vertex.xyz += currentPos;
                    // //��]������
                    // v.vertex.xyz = currentPos + center + rotate(v.vertex.xyz - center - currentPos, (pid + _Time.y) * _RotationFactor, r3);
                    // //���S���N�_�ɃX�P�[����ς���
                    // v.vertex.xyz = currentPos + center + (v.vertex.xyz - center - currentPos) * (1.0 - _ScaleFactor);

                    //�������̕�����������@���Ԃ�ς�������
                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
                    v.vertex.xyz += normal * _PositionFactor * abs(r3);

                    // NG�p�^�[��
                    // v.vertex.xyz += normal * _PositionFactor * abs(r3);
                    // v.vertex.xyz = center + rotate(v.vertex.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    // v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    //�����_���Ȓl
                    //�V�[�h�l�Ƀ��[���h���W�𗘗p����ƈړ����邽�тɐF���ς���Ă₩�܂����̂Ń��[�J�����W�𗘗p
                    float r = rand(v.localPos.xy);
                    float g = rand(v.localPos.xz);
                    float b = rand(v.localPos.yz);

                    // NG�p�^�[��
                    // float r = rand(v.vertex.xy);
                    // float g = rand(v.vertex.xz);
                    // float b = rand(v.vertex.yz);
                    o.color = fixed4(r,g,b,1);
                    stream.Append(o);
                }
            }

            //�t���O�����g�V�F�[�_�[
            fixed4 frag(g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}