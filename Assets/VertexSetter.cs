using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VertexSetter : MonoBehaviour {
    public Material mat;
    public Transform[] poses;
    private void OnDrawGizmos()
    {
        SetVertex();
    }

    // Update is called once per frame
    void Update () {
        SetVertex();
	}
    void SetVertex()
    {
        //if (mat != null)
        //{
        //    for (int i )
        //    else
        //    {
        //        
        //    }

        //}
        mat.SetVector("_VectorPos", transform.position);
    }
}
