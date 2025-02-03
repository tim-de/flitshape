package main

import "core:fmt"
import "base:runtime"

import rl "vendor:raylib"

GRAVITY_POWER :: 2000
BOUNCE_POWER :: 500.0

window_width :: 1024
window_height :: 768

character_x_offset :: window_width / 3
character_y_start :: window_height / 2

Distance : f32 = 0.0
BaseSpeed : f32 = 450
Speed: f32 = BaseSpeed

Score : int = 0

SHADER: rl.Shader
TARGET: rl.RenderTexture2D

main :: proc() {
    rl.InitWindow(window_width, window_height, "FlitShape")
    shadertext : cstring = #load("./bloom.glsl")
    //SHADER = rl.LoadShader(nil, "./bloom.glsl")
    SHADER = rl.LoadShaderFromMemory(nil, shadertext)
    TARGET = rl.LoadRenderTexture(window_width, window_height)

    defer rl.UnloadShader(SHADER)
    rl.SetTargetFPS(120)

    scene := reset_scene()
    for !rl.WindowShouldClose() {
        draw_scene(scene)
        if scene.mode == .GameOver {
            if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
                scene = reset_scene()
            }
        }
        Speed = BaseSpeed + f32(2 * scene.score)
        delta_t := rl.GetFrameTime()
        if scene.mode == .Waiting {
            if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
                scene.mode = .Running
            }
        }
        if scene.mode == .Running {
            if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
                scene.char.velocity.y = -BOUNCE_POWER
            }
            update_gate(&scene.gate, delta_t, &scene.score)
        }
        if scene.mode != .Waiting {
            update_character(&scene.char, delta_t)
        }

        if test_collision(&scene.char, &scene.gate) {
            scene.mode = .GameOver
        }
    }
}

reset_scene :: proc() -> Scene {
    return setup_scene(
        Character {
            position = {character_x_offset, character_y_start},
            velocity = {0.0, 0.0},
            points = {
                {50.0, 0.0},
                {-10.0, -10.0},
                {-10.0, 10.0}},
            colour = { 0x50, 0xbb, 0xff, 0xff },
        },
        Gate {
            position = {window_width, window_height / 2.0},
            size = {60, 150},
            colour = { 0x30, 0xff, 0x88, 0xff },
        })
}
