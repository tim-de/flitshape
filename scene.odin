package main

import rl "vendor:raylib"

Scene :: struct {
    char: Character,
    gate: Gate,
    baseSpeed: f32,
    speed: f32,
    score: int,
    running: bool,
    mode: Mode,
}

setup_scene :: proc(char: Character, gate: Gate) -> Scene {
    return Scene {
        char = char,
        gate = gate,
        baseSpeed = BaseSpeed,
        speed = BaseSpeed,
        score = 0,
        running = true,
        mode = .Waiting,
    }
}

draw_scene :: proc(scene: Scene) {
    rl.BeginTextureMode(TARGET)
    {
        defer rl.EndTextureMode()
        rl.ClearBackground({0x00, 0x0d, 0x0a, 0xff})
        draw_gate(scene.gate)
        draw_character(scene.char)
        rl.DrawText(
            rl.TextFormat("Score: %d", scene.score),
            20, 30, 30, rl.RAYWHITE)
        //rl.DrawFPS(window_width - 125, 40)
        if scene.mode == .GameOver { 
            rl.DrawText("Game Over. Press SPACE to restart\nor ESC to quit", 220, i32(window_height) / 2 - 10, 30, rl.RAYWHITE)
        }
        if scene.mode == .Waiting {
            rl.DrawText("Press SPACE to start", 320, i32(window_height) / 2 - 10, 30, rl.RAYWHITE)
        }
    }
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.BeginShaderMode(SHADER)
    defer rl.EndShaderMode()
    texture_rec := rl.Rectangle {
        0, 0,
        f32(TARGET.texture.width),
        f32(-TARGET.texture.height),
    }
    rl.DrawTextureRec(TARGET.texture, texture_rec, rl.Vector2 {0, 0}, rl.RAYWHITE)
}

Mode :: enum u8 {
    Waiting,
    Running,
    GameOver,
}
