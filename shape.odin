package main

import rl "vendor:raylib"
import "core:math/rand"

Character :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    points: [3]rl.Vector2,
    colour: rl.Color,
}

update_character :: proc(tri: ^Character, delta_t: f32) {
    tri.velocity.y += GRAVITY_POWER * delta_t * 0.5
    if tri.position.y >= window_height && tri.velocity.y > 0 {
        tri.velocity.y = 0
    }
    tri.position += tri.velocity * delta_t
    tri.velocity.y += GRAVITY_POWER * delta_t * 0.5
    Distance += Speed * delta_t
}

extend_vec2_to_vec3 :: proc(vec: rl.Vector2) -> rl.Vector3 {
    return rl.Vector3{vec.x, vec.y, 1}
}

draw_character :: proc(tri: Character) {
    v_len := rl.Vector2Length(rl.Vector2{Speed, tri.velocity.y})
    tmat := matrix[3,3]f32 {
        Speed / v_len,          -tri.velocity.y / v_len, tri.position.x,
        tri.velocity.y / v_len, Speed / v_len,           tri.position.y,
        0,                      0,                       0,
    }
    translated_tri := [3]rl.Vector2{
        (tmat * extend_vec2_to_vec3(tri.points[0])).xy,
        (tmat * extend_vec2_to_vec3(tri.points[1])).xy,
        (tmat * extend_vec2_to_vec3(tri.points[2])).xy,
    }
    rl.DrawTriangleLines(translated_tri[0], translated_tri[1], translated_tri[2],
        tri.colour)
}

Gate :: struct {
    position: rl.Vector2,
    size: rl.Vector2,
    colour: rl.Color,
}

update_gate :: proc(gate: ^Gate, delta_t: f32, score: ^int) {
    gate.position.x -= Speed * delta_t
    if gate.position.x + gate.size.x < 0 {
        score^ += 1
        gate.position.x = window_width + 1
        gate.position.y = rand.float32_range((gate.size.y), (window_height - (gate.size.y)))
    }
}

draw_gate :: proc(gate: Gate) {
    top_rect := rl.Rectangle {
        x = gate.position.x,
        y = -5.0,
        width = gate.size.x,
        height = gate.position.y - (gate.size.y / 2),
    }
    bottom_rect := rl.Rectangle {
        x = gate.position.x,
        y = gate.position.y + (gate.size.y / 2),
        width = gate.size.x,
        height = window_height + gate.size.y - gate.position.y,
    }
    rl.DrawRectangleLinesEx(
        top_rect,
        2.,
        gate.colour) 
    rl.DrawRectangleLinesEx(
        bottom_rect,
        2.,
        gate.colour) 
}

test_collision :: proc(character: ^Character, gate: ^Gate) -> bool {
    v_len := rl.Vector2Length(rl.Vector2{Speed, character.velocity.y})
    tmat := matrix[3,3]f32 {
        Speed / v_len,          -character.velocity.y / v_len, character.position.x,
        character.velocity.y / v_len, Speed / v_len,           character.position.y,
        0,                      0,                       0,
    }
    for point in character.points {
        t_point := (tmat * extend_vec2_to_vec3(point)).xy
        if t_point.y > window_height ||
            (t_point.x > gate.position.x && t_point.x < gate.position.x + gate.size.x &&
            (t_point.y < gate.position.y - (gate.size.y / 2) || t_point.y > gate.position.y + (gate.size.y / 2))) {
            return true
        }
    }
    return false
}
