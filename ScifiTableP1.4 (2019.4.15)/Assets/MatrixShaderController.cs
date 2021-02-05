using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixShaderController : MonoBehaviour
{
    //Array for get matrix shader meshes
    public GameObject[] matrixShaderMeshes;
    public bool shaderEnable = true;

    //TriplanerManager reference variable
    public TriplanarManager tripMang;
    public bool colorControl = false;

    //Opacity control material get
    public Material matOpacity;
    public Material otherMat;  //when 0 opacity replcae with this

    
    
    [Range(0,1)]
    [HideInInspector]
    public float opacity = 1;
    float opac=0;
    float take = 1;



    void Update()
    {
      //  if(opacity > 0 && shaderEnable == false)
      //  {
      //      shaderEnable = true;
      //  }


        if(shaderEnable == true)
        {
          otherMat.renderQueue = 3000;
        }
        else if (shaderEnable == false)
        {
            otherMat.renderQueue = 0;
        }



        if (shaderEnable == false)
        {
            for(int i=0;i< matrixShaderMeshes.Length; i++)
            {
                matrixShaderMeshes[i].SetActive(false);
            }
           
        }

        if (shaderEnable == true)
        {
            for (int i = 0; i < matrixShaderMeshes.Length; i++)
            {
                matrixShaderMeshes[i].SetActive(true);
            }
            
        }


        //control color of shader
        tripMang.colored = colorControl;



        //Opacity Control


        if (opacity == 1)
        {
            
            opac = 0;
        }
        else if(opacity == 0)
        {
            if (shaderEnable == true)
            {
                shaderEnable = false;
            }
            opac = 1;

        }
        else
        {
            float mins = take - opacity;
            opac = opac + mins;
        }

        take = opacity;

        //Opacity Control
        Color colr = matOpacity.color;
        colr.a = opac;
        matOpacity.color = colr;

    }
}
