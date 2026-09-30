shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec3 deep_color : source_color = vec3(0.025, 0.105, 0.12);
uniform vec3 shallow_color : source_color = vec3(0.13, 0.24, 0.20);
varying vec3 world_pos;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
float swell(vec2 p) {
 return noise(p*0.8+vec2(TIME*0.11,TIME*0.05))*0.55 + noise(p*2.1+vec2(-TIME*0.07,TIME*0.09))*0.3 + noise(p*5.3+vec2(TIME*0.04,-TIME*0.13))*0.15;
}
void vertex() {
 world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 VERTEX.y += (swell(world_pos.xz)-0.5)*0.09;
}
void fragment() {
 vec2 p=world_pos.xz;
 float height=swell(p);
 float dx=(swell(p+vec2(0.08,0))-height)*1.8;
 float dz=(swell(p+vec2(0,0.08))-height)*1.8;
 NORMAL_MAP=normalize(vec3(-dx,-dz,1.0))*0.5+0.5;
 float depth=textureLod(depth_texture,SCREEN_UV,0.0).r;
 vec4 behind=INV_PROJECTION_MATRIX*vec4(SCREEN_UV*2.0-1.0,depth,1.0);
 behind.xyz/=behind.w;
 float water_depth=max(0.0,VERTEX.z-behind.z);
 float absorption=1.0-exp(-water_depth*0.28);
 float edge=1.0-smoothstep(0.04,0.55,water_depth);
 float foam=edge*smoothstep(0.48,0.8,noise(p*3.0+TIME*0.15));
 ALBEDO=mix(shallow_color,deep_color,absorption)*(0.95+height*0.1);
 ALBEDO=mix(ALBEDO,vec3(0.55,0.60,0.53),foam*0.5);
 ROUGHNESS=0.16+height*0.13;
 METALLIC=0.0;
 SPECULAR=0.5;
}
