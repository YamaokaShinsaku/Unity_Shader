/// <summary>
/// a-bの範囲内で補間する値valueを生成する線形パラメータを計算
/// </summary>
/// a : 開始値
/// b : 終了値
/// value : 開始と終了の間の値
float inverseLerp(float a, float b, float value)
{
    return saturate((value - a) / (b - a));
}

/// <summary>
/// Half-Lambert 拡散反射光を計算する
/// </summary>
/// lightDirection : ライト方向
/// lightColor : ライトの色
/// normal : 法線
float3 CalcHalfLambertDiffuse(float3 lightDirection, float3 lightColor, float3 normal)
{
    // ピクセルの法線とライトの方向の内積席を計算する
    float t = dot(normal, lightDirection);
    // 内積の値を０以上の値にする
    t = max(0.0f, t);
    t = pow(t * 0.5 + 0.5, 2);

    // 拡散反射光を計算する
    return lightColor * t;
}