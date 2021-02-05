using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshCombiner : MonoBehaviour
{
    
    void Start()
    {
        MeshCombine();
    }

    void MeshCombine()
    {
        Quaternion oldRot = transform.rotation;
        Vector3 oldPos = transform.position;

        MeshFilter[] filters = GetComponentsInChildren<MeshFilter>();
        Debug.Log("Meshes " + filters.Length);

        Mesh finalMesh = new Mesh();

        CombineInstance[] combiner = new CombineInstance[filters.Length];

        for(int a = 0; a<filters.Length; a++)
        {
            if (filters[a].transform == transform)
                continue;


            combiner[a].subMeshIndex = 0;
            combiner[a].mesh = filters[a].sharedMesh;
            combiner[a].transform = filters[a].transform.localToWorldMatrix;

        }

        finalMesh.CombineMeshes(combiner);
        GetComponent<MeshFilter>().sharedMesh = finalMesh;

        transform.rotation = oldRot;
        transform.position = oldPos;

        for(int i=0; i<transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(false);
        }
    }
}
