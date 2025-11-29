//! By convention, root.zig is the root source file when making a library.

pub const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Rectangle {
        return Rectangle{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
        };
    }
};
