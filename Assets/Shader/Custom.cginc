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