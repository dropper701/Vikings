shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.3, 0.2, 0.12, 1.0);
uniform float grain = 0.0;
uniform float surface_scale = 2.0;
varying vec3 local_pos;
float hash(vec3 p) { return fract(sin(dot(p, vec3(127.1,311.7,74.7))) * 43758.5453); }
float noise(vec3 p) {
 vec3 i = floor(p); vec3 f = fract(p); f = f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() { local_pos = VERTEX; }
void fragment() {
 vec3 p = local_pos * surface_scale;
 vec3 g = mix(p, p * vec3(1.5, 18.0, 18.0), grain);
 float n = noise(g)*0.55 + noise(g*4.0)*0.3 + noise(g*14.0)*0.15;
 ALBEDO = base_color.rgb * (0.7 + n*0.55);
 ROUGHNESS = 0.88;
}
