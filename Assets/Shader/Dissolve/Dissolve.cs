using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class Dissolve : MonoBehaviour
{
    private Material material;
    YieldInstruction Instruction = new WaitForEndOfFrame();

    // Start is called before the first frame update
    void Start()
    {
        material = GetComponent<Renderer>().material;
        StartCoroutine("Animate");
    }

    IEnumerator Animate()
    {
        float time = 0;
        float duration = 5.0f;
        int dir = 1;

        while(true)
        {
            yield return Instruction;

            time += Time.deltaTime * dir;
            var t = time / duration;

            if( t > 1f)
            {
                dir = -1;
            }
            else if(t < 0)
            {
                dir = 1;
            }

            material.SetFloat("_CutOff", t);
        }
    }
}
