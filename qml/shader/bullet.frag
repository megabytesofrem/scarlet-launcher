// Touhou style bullet-hell shader
// Bursts:
// ===============================
// - Circle burst
// - Star shape, random sides from 4 to 6
//
// Control variables:
// - numColumns: More columns = more bullets
// - totalLifetime: Total lifetime of the particle system (time to drop + time to burst)
// - fallingBurstSpeed, fallingBurstRangeSpeed: Speed of falling bullets
// - burstBaseSpeed, burstRangeSpeed: Speed of burst bullets
// - bulletSize: Size of the bullets (randomized per column)
// - trailLength: Length of the bullet trails
// - trailThickness: Thickness of the bullet trails
// - trailAlphaMult: Alpha multiplier for the bullet trails

#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 1) in vec2 v_position;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
};

// Pseudo-random function for generating bullet positions
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Distance from point p to line segment ab
float segmentDistance(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Create a circular bullet shape with sharper edges
float bulletShape(vec2 position, vec2 center, float radius) {
    // Correct for aspect ratio to make truly circular bullets
    float aspectRatio = resolution.x / resolution.y;
    vec2 correctedPos = position - center;
    correctedPos.x *= aspectRatio;
    float distance = length(correctedPos);
    // Sharper transition for cleaner bullets
    return 1.0 - smoothstep(radius - 0.005, radius + 0.005, distance);
}

void main() {
    vec2 uv = qt_TexCoord0;
    vec3 color = vec3(0.0);
    float alpha = 0.0;
    
    // Number of columns = more or less bullets
    float numColumns = 32.0;
    
    // Total lifetime of the particle system (time to drop + time to burst)
    float totalLifetime = 3.5;
    
    float fallingBaseSpeed = 0.7;
    float fallingRangeSpeed = 0.5;

    float burstBaseSpeed = 0.08;
    float burstRangeSpeed = 0.05;

    float trailLength = 0.25;
    float trailThickness = 0.006;
    float trailAlphaMult = 0.025;

    // Loop through columns
    for (float i = 0.0; i < numColumns; i++) {
        float x = (i + 0.5) / numColumns;

        // Get a random seed
        vec2 seed = vec2(i * 0.3, 0.0);
        // Less random offset for cleaner columns
        float xOffset = (random(seed) - 0.5) * 0.05;
        x += xOffset;

        // NOTE: Random gives between 0.0 and 1.0 throughout this program

        // Initially start falling
        float fallingSpeed = fallingBaseSpeed + random(seed + vec2(1.0, 0.0)) * fallingRangeSpeed; // 0.15 to 0.25
        float phase = random(seed + vec2(2.0, 0.0)) * 6.28318;

        float fanOutTime = 1.5 + random(seed + vec2(3.0, 0.0)); // 1.5-2.5
        float t = mod(time * fallingSpeed + phase, totalLifetime);

        vec2 bulletPos;
        float bulletSize = 0.010 + random(seed + vec2(4.0, 0.0)) * 0.004; // 0.008 to 0.012

        float burstChance = random(seed + vec2(5.0, 0.0));
        bool shouldBurst = burstChance < 0.5;

        // ANIMATION
        if (t < fanOutTime || !shouldBurst) {
            // Falling phase
            bulletPos = vec2(x, t - 1.25);

            // Falling bullets are slightly larger
            bulletSize = 0.020 + random(seed + vec2(3.0, 0.0)) * 0.004; // 0.012 to 0.016

            // Trail
            vec2 trailStart = bulletPos - vec2(0.0, trailLength);
            vec2 trailEnd = bulletPos;

            float trailFade = clamp((fanOutTime - t) / 0.2, 0.0, 1.0); // fades out over last 0.2 seconds
            float d = segmentDistance(uv, trailStart, trailEnd);

            float alongTrail = clamp((bulletPos.y - trailStart.y) / trailLength, 0.0, 1.0);
            float trailAlpha = smoothstep(trailThickness, 0.0, d) * alongTrail * trailFade;

            // Add the trail color
            color += vec3(0.9, 0.95, 1.0) * trailAlpha * 0.5;
            alpha += trailAlpha * trailAlphaMult;

            // End trail

            float bullet = bulletShape(uv, bulletPos, bulletSize);   
            if (bullet > 0.0) {
                vec3 bulletColor = vec3(0.9, 0.95, 1.0);

                // Animate fade
                float fade = 0.8 + 0.2 * (1.0 - abs(bulletPos.x - 0.5));
                color += bulletColor * bullet * fade;
                alpha += bullet * fade * 0.3;
                
                //color *= clamp(t / fanOutTime, 0.0, 1.0);
                if (t > fanOutTime - 0.125) {
                    float scale = 1.0 - (t - (fanOutTime - 0.125)) / 0.125;
                    color *= clamp(scale, 0.0, 1.0);
                }
                
                
            }
  
        } else {
            // Fan out phase: spawn burst bullets around the position where the bullet started fanning out
            bulletSize = 0.040 + random(seed + vec2(3.0, 0.0)) * 0.008; // 0.012 to 0.016
            float rngBurstCount = random(seed + vec2(6.0, 0.0));
            
            float burstCount = mix(4.0, 32.0, rngBurstCount);

            float burstSpeed = burstBaseSpeed + random(seed + vec2(1.0, 0.0)) * burstRangeSpeed;
            float burstRadius = 0.01 + (t - fanOutTime) * burstSpeed;

            // The burst center is where the bullet was when it started fanning out
            vec2 burstCenter = vec2(x, fanOutTime - 1.25);

            for (float j = 0.0; j < burstCount; j += 1.0) {
                float burstAngle = 6.28318 * j / burstCount;
                float aspectRatio = resolution.x / resolution.y;

                vec2 burstPos;
                vec2 burstDir = vec2(cos(burstAngle), aspectRatio * sin(burstAngle));


                // Draw the glow
                // Choose burst bullet color (example: yellow)
                vec3 burstColor = vec3(1.0, 1.0, 1.0) * 0.25;

                // Outer glow for burst bullet
                vec2 correctedBurstPos = uv - burstPos;
                correctedBurstPos.x *= aspectRatio;
                float burstDistance = length(correctedBurstPos);

                float burstBulletSize = bulletSize * 1.2; // or whatever size you use
                float burstGlowRadius = burstBulletSize * 0.5;
                float burstGlowSoftness = burstBulletSize * 2.5;
                float burstGlow = 1.0 - smoothstep(burstGlowRadius, burstGlowRadius + burstGlowSoftness, burstDistance);

                color += burstColor * burstGlow * 0.3;
                alpha += burstGlow * 0.02;

                // Decide between a circle or flower pattern
                float burstShape = clamp(random(seed + vec2(7.0, 0.0)), 0.0, 1.0);

                if (burstShape < 0.5) {
                    // Circle shape
                    burstPos = burstCenter + (burstDir * burstRadius);
                } else {
                    // N-gon shape, between 4 and 6 sides
                    float sides = 4.0 + random(seed + vec2(8.0, 0.0)) * 2.0;
                    burstPos = burstCenter + (burstDir * burstRadius * mix(0.6, 1.0, sin(burstAngle * sides) * 0.5 + 0.5));
                }

                // Child bullet
                float childBullet = bulletShape(uv, burstPos, bulletSize * 1.2);
                if (childBullet > 0.0) {
                    float colorVar = random(seed + vec2(4.0, 0.0));
                
                    if (colorVar < 0.33) {
                        color += vec3(255.0/255.0, 0.0, 0.0) * childBullet * 0.7; // red
                    } else if (colorVar < 0.66) {
                        color += vec3(255.0/255.0, 68.0/255.0, 0.0) * childBullet * 0.7; // orange
                    } else {
                        color += vec3(255.0/255.0, 162.0/255.0, 0.0) * childBullet * 0.7; // yellow
                    }
                    alpha += childBullet * 0.2;
                }
            }
        }
        // END OF ANIMATION
    }
    
    alpha = clamp(alpha, 0.0, 1.0);
    fragColor = vec4(color, alpha * qt_Opacity);    
}