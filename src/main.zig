const std = @import("std");
const puzzle = @import("puzzle.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var p = puzzle.Engine().init(allocator);
    try p.print();

    try p.fill_scratch();

    p.set_key(3, 3, 3);
    try p.print();

    const row = p.get_row(3);
    p.print_rcs(row);

    const col = p.get_col(3);
    p.print_rcs(col);

    const sub = p.get_sub(4,4);
    p.print_rcs(sub);

    //try p.fill_scratch(1, 2);
    p.print_scratch();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
