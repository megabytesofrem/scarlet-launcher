// Touhou style bullet-hell shader
// See bullet.frag for explanations

#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(location = 0) out vec2 qt_TexCoord0;
layout(location = 1) out vec2 v_position;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
};

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    v_position = (qt_Vertex.xy / resolution) * 2.0 - 1.0;
    gl_Position = qt_Matrix * qt_Vertex;
}