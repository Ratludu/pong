const std = @import("std");
const pong = @import("pong");
const rl = @import("raylib");

const player = struct {
    rect: *pong.Rectangle,

    fn init(rect: *pong.Rectangle) player {
        return player{
            .rect = rect,
        };
    }

    fn update(self: player, screenHeight: f32, speed: f32) void {
        if (self.rect.y < 0) {
            self.rect.y = 0;
        }

        if (self.rect.y > screenHeight - self.rect.height) {
            self.rect.y = screenHeight - self.rect.height;
        }

        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            self.rect.y += speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            self.rect.y -= speed;
        }
    }
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    const speed = 4.0;

    // player rect
    var rect = pong.Rectangle.init(20, screenHeight / 2 - 40, 40, 80);
    var myPlayer = player.init(&rect);

    // player ai rect
    var aiRect = pong.Rectangle.init(screenWidth - 20 * 3, screenHeight / 2 - 40, 40, 80);
    var ai = player.init(&aiRect);

    rl.initWindow(screenWidth, screenHeight, "PONG");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        myPlayer.update(screenHeight, speed);
        ai.update(screenHeight, speed);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawRectangle(@intFromFloat(myPlayer.rect.x), @intFromFloat(myPlayer.rect.y), @intFromFloat(myPlayer.rect.width), @intFromFloat(myPlayer.rect.height), .white);
        rl.drawRectangle(@intFromFloat(ai.rect.x), @intFromFloat(ai.rect.y), @intFromFloat(ai.rect.width), @intFromFloat(ai.rect.height), .white);
        rl.drawText(rl.textFormat("y: %f", .{myPlayer.rect.y}), 10, 0, 20, .white);

        rl.clearBackground(.black);
    }
}
