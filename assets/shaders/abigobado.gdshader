shader_type canvas_item;

uniform bool pode;
uniform float velocidade;
varying float oscilacao;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.a > 0.0 && pode){
		oscilacao =  sin(TIME*velocidade)+0.5;
		COLOR = COLOR + vec4(vec3(oscilacao), 1);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
