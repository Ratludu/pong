const std = @import("std");
const pong = @import("pong");
const rl = @import("raylib");

const State = enum { PAUSED, PLAYING };

const player = struct {
    rect: *pong.Rectangle,
    score: u8,

    fn init(rect: *pong.Rectangle) player {
        return player{
            .rect = rect,
            .score = 0,
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

    fn aiUpdate(self: *player, myball: ball) void {
        const centerY = self.rect.y + self.rect.height / 2.0;
        const moveSpeed = 5;

        if (myball.rect.y > centerY) {
            self.rect.y += moveSpeed;
        }

        if (myball.rect.y < centerY) {
            self.rect.y -= moveSpeed;
        }
    }
};

const ball = struct {
    rect: *pong.Rectangle,
    vx: f32,
    vy: f32,

    fn init(rect: *pong.Rectangle, speed: f32, angle: f32) ball {
        return ball{
            .rect = rect,
            .vx = speed * @cos(angle),
            .vy = speed * @sin(angle),
        };
    }

    fn update(self: *ball) void {
        self.rect.x += self.vx;
        self.rect.y += self.vy;
    }

    fn hitCanvas(self: *ball, screenWidth: f32, screenHeight: f32) void {
        if (self.rect.y < 0 or self.rect.y > screenHeight) {
            self.vx *= 1;
            self.vy *= -1;
        }

        if (self.rect.x < 0 or self.rect.x > screenWidth) {
            self.vx *= -1;
            self.vy *= 1;
        }
    }

    fn hitPaddle(self: *ball, rect: pong.Rectangle) void {
        if (collision(self.rect.*, rect)) {
            self.vx *= -1;
            self.vy *= 1;
        }
    }

    fn reset(self: ball, screenWidth: f32, screenHeight: f32) void {
        self.rect.x = screenWidth / 2;
        self.rect.y = screenHeight / 2;
    }
};

fn collision(r1: pong.Rectangle, r2: pong.Rectangle) bool {
    if ((r1.x <= r2.x + r2.width / 2.0 and r1.x + r1.width / 2.0 >= r2.x) and (r1.y <= r2.y + r2.height and r1.y + r1.height >= r2.y)) {
        return true;
    }

    return false;
}
fn drawRectangle(rect: pong.Rectangle, colour: rl.Color) void {
    rl.drawRectangle(@intFromFloat(rect.x), @intFromFloat(rect.y), @intFromFloat(rect.width), @intFromFloat(rect.height), colour);
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    const speed = 6.0;
    const pi = std.math.pi;

    // player rect
    var rect = pong.Rectangle.init(20, screenHeight / 2 - 40, 40, 80);
    var myPlayer = player.init(&rect);

    // player ai rect
    var aiRect = pong.Rectangle.init(screenWidth - 20 * 3, screenHeight / 2 - 40, 40, 80);
    var ai = player.init(&aiRect);

    // ball
    var ballRect = pong.Rectangle.init(screenWidth / 2 - 5, screenHeight / 2 - 5, 10, 10);
    var myBall = ball.init(&ballRect, speed, (pi / 4.0) * 3);

    rl.initWindow(screenWidth, screenHeight, "PONG");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        myPlayer.update(screenHeight, speed);
        if (myBall.rect.x > (screenWidth * 0.6) and myBall.vx > 0) {
            ai.aiUpdate(myBall);
        }

        myBall.update();
        myBall.hitCanvas(screenWidth, screenHeight);
        myBall.hitPaddle(myPlayer.rect.*);
        myBall.hitPaddle(ai.rect.*);

        if (myBall.rect.x < 0) {
            ai.score += 1;
            myBall.reset(screenWidth, screenHeight);
        }

        if (myBall.rect.x > screenWidth) {
            myPlayer.score += 1;
            myBall.reset(screenWidth, screenHeight);
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawText(rl.textFormat("y: %f", .{myPlayer.rect.y}), 10, 0, 20, .white);
        rl.drawText(rl.textFormat("%d", .{myPlayer.score}), screenWidth / 2 - 80, 20, 40, .white);
        rl.drawText(rl.textFormat("%d", .{ai.score}), screenWidth / 2 + 65, 20, 40, .white);

        rl.drawLine(screenWidth / 2, 0, screenWidth / 2, screenHeight, .white);

        drawRectangle(myPlayer.rect.*, .white);
        drawRectangle(ai.rect.*, .white);
        drawRectangle(myBall.rect.*, .white);

        rl.clearBackground(.black);
    }
}
