const std = @import("std");
const puzzle = @import("puzzle.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var p = puzzle.Engine().init(allocator);
    p.print();

    p.set_key(3, 3, 3);
    p.print();

    const row = p.get_row(3);
    p.print_row(row);

    //try p.fill_scratch(1, 2);
    //p.print_scratch();

    // const row = [_]?u4{5} ** 9;
    // const arr = [_][9]?u4{row} ** 9;
    //
    // //std.debug.print("arr -> {any}\n", .{arr}out);
    // std.debug.print("-------------------------------------\n", .{});
    // for (0..9) |y| {
    //     for (0..9) |x| {
    //         std.debug.print("| {d} ", .{arr[x][y].?});
    //         if (x == 8) {
    //             std.debug.print("|\n", .{});
    //         }
    //     }
    //     if (y == 8) {
    //         std.debug.print("-------------------------------------\n", .{});
    //     }
    // }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
