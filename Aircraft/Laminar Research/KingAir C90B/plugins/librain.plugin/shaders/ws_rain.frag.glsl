#version 120
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif
#extension GL_EXT_gpu_shader4 : require

uniform sampler2D screenshot_tex;
uniform vec4 vp;
uniform vec2 wiper_pivot[2];
uniform float wiper_radius_outer[2];
uniform float wiper_radius_inner[2];
uniform float wiper_pos[2];
uniform sampler2D depth_tex;
uniform sampler2D norm_tex;
uniform int num_wipers;

varying vec2 tex_coord;
varying vec3 tex_norm;

float _67;

vec4 get_pixel(inout vec2 pos)
{
    vec2 sz = vec2(textureSize2D(screenshot_tex, 0));
    pos /= sz;
    pos = clamp(pos, vec2(0.0), vec2(vp.zw / sz) - vec2(0.001000000047497451305389404296875));
    return texture2D(screenshot_tex, pos);
}

float dir2hdg(vec2 v)
{
    if (v.y >= 0.0)
    {
        return asin(v.x / length(v));
    }
    else
    {
        if (v.x >= 0.0)
        {
            return 3.1415927410125732421875 - asin(v.x / length(v));
        }
        else
        {
            return (-3.1415927410125732421875) - asin(v.x / length(v));
        }
    }
}

bool check_wiper(int i)
{
    vec2 wiper2pos = tex_coord - wiper_pivot[i];
    float dist = length(wiper2pos);
    float _118 = dist;
    bool _129 = abs(_118 - wiper_radius_outer[i]) < 0.00200000009499490261077880859375;
    bool _141;
    if (!_129)
    {
        _141 = abs(dist - wiper_radius_inner[i]) < 0.00200000009499490261077880859375;
    }
    else
    {
        _141 = _129;
    }
    if (_141)
    {
        return true;
    }
    vec2 param = wiper2pos;
    float hdg = dir2hdg(param);
    float _150 = dist;
    bool _154 = _150 <= wiper_radius_outer[i];
    bool _162;
    if (_154)
    {
        _162 = dist >= wiper_radius_inner[i];
    }
    else
    {
        _162 = _154;
    }
    bool _174;
    if (_162)
    {
        _174 = abs(hdg - wiper_pos[i]) <= 0.01745329238474369049072265625;
    }
    else
    {
        _174 = _162;
    }
    if (_174)
    {
        return true;
    }
    return false;
}

void main()
{
    float depth = texture2D(depth_tex, tex_coord).x;
    vec2 displace = ((texture2D(norm_tex, tex_coord).xy - vec2(0.5)) * 200.0) * (3.0 - depth);
    vec2 param = gl_FragCoord.xy + displace;
    vec4 _211 = get_pixel(param);
    vec4 bg_pixel = _211;
    bg_pixel *= (1.0 - pow(length(displace) / 800.0, 1.7999999523162841796875));
    gl_FragData[0] = vec4(bg_pixel.xyz, 1.0);
    if (num_wipers > 0)
    {
        for (int i = 0; i < num_wipers; i++)
        {
            int param_1 = i;
            if (check_wiper(param_1))
            {
                gl_FragData[0] += vec4(0.60000002384185791015625, 0.0, 0.0, 0.0);
                break;
            }
        }
    }
}

