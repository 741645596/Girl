using System;
using UnityEngine;
using System.Text;
using System.Collections.Generic;

public class FPSCounter : MonoBehaviour {


	public List<Animator> listAni = new List<Animator>();


	private void Start() {
		SetAniState(1);
	}

	/*private Rect m_FpsRect = new Rect(Screen.width - 300, 0, 300, 100);
    private Rect m_VerRect = new Rect(350, 0, 200, 50);

    void OnGUI(){
		if (GUI.Button (new Rect (Screen.width/2 - 380 , Screen.height -100, 200, 80), "ani1")) {
			SetAniState(0);
		}

		if (GUI.Button (new Rect (Screen.width/2 - 100 , Screen.height -100, 200, 80), "an2")) {
			SetAniState(1);
		}


		if (GUI.Button (new Rect (Screen.width/2 + 180 , Screen.height -100, 200, 80), "an3")) {
			SetAniState(2);
		}
    }*/



	public void SetAniState(int state)
	{
		foreach (Animator ani in listAni) {
			if (ani != null) {
				ani.SetInteger("anistate", state);
			}
		}
	}
}
