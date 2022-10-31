using UnityEngine;
using System.Collections;
using System.Collections.Generic;
/// <summary>
/// 水平旋转，支持倒计时开始旋转
/// </summary>
namespace IGG {
    public class Rotate : MonoBehaviour {

        public float m_RoateSpeed = 100.0f;


        void Start() {

        }

        void Update() {

            if (Input.GetMouseButton(0)) {
                float mousX = Input.GetAxis("Mouse X");
                //transform.Rotate(new Vector3(0, -mousX * m_RoateSpeed, 0));
				transform.Rotate(new Vector3(0, -mousX * m_RoateSpeed, 0));
            }

        }
    }
}

