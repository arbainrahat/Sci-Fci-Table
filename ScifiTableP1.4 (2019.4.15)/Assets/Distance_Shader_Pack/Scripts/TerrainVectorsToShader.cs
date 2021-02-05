using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
[ExecuteInEditMode]
public class TerrainVectorsToShader : MonoBehaviour {

    public Vector3 directionScalar;

    public bool useOffset = false;

    // public enum SetCenterPointMode { Origin, UseGameObject, InputPosition };

    // public SetCenterPointMode centrePointMode;

    // public Transform gameObjectPosition;

    public Vector3 offset;
    public float yaxisvalue = 0;

    MeshRenderer mr;
    Material mat;

    Vector4 pos;
    Vector4 prevPos;

    bool prevUseOffsetSetting;

    Vector3 prevDirectionScalar;
    Vector4 directionScalarToShader;

    // SetCenterPointMode prevCP;

    private void OnEnable()
    {
        mr = GetComponent<MeshRenderer>();
        mat = mr.sharedMaterial;

        SetCentrePoint();
        if (mat != null)
        {
            mat.SetVector("_CentrePoint", pos);

            prevPos = pos;
            prevUseOffsetSetting = useOffset;
            directionScalarToShader = new Vector4(directionScalar.x, directionScalar.y, directionScalar.z, 0);
            mat.SetVector("_DirectionScalars", directionScalarToShader);
            prevDirectionScalar = directionScalar;
        }
    }

    private void Update()
    {
        if (mat == null)
        {
            mr = GetComponent<MeshRenderer>();
            mat = mr.sharedMaterial;
        }
        SetCentrePoint();
        if (pos != prevPos || useOffset != prevUseOffsetSetting)
        {
            mat.SetVector("_CentrePoint", pos);
            prevPos = pos;
            prevUseOffsetSetting = useOffset;
        }
        if (directionScalar != prevDirectionScalar && mat != null)
        {
            directionScalarToShader = new Vector4(directionScalar.x, directionScalar.y, directionScalar.z, 0);
            mat.SetVector("_DirectionScalars", directionScalarToShader);
            prevDirectionScalar = directionScalar;
        }
    }

    private void SetCentrePoint()
    {
        if (useOffset)
        {
            if (mat != null)
            {
                pos = new Vector4(offset.x, offset.y, offset.z, 0);

                mat.SetVector("_CentrePoint", pos);

                prevPos = pos;

                directionScalarToShader = new Vector4(directionScalar.x, directionScalar.y, directionScalar.z, 0);
                mat.SetVector("_DirectionScalars", directionScalarToShader);
                prevDirectionScalar = directionScalar;
            }
        }
        else
        {
            if (mat != null)
            {
                pos = new Vector4(0, 0, 0, 0);

                mat.SetVector("_CentrePoint", pos);

                prevPos = pos;

                directionScalarToShader = new Vector4(directionScalar.x, transform.localPosition.y, directionScalar.z, 0);
                mat.SetVector("_DirectionScalars", directionScalarToShader);
                prevDirectionScalar = directionScalar;
            }
        }
    }
}