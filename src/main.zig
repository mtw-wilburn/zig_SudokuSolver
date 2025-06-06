const std = @import("std");
const puzzle = @import("puzzle.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var p = puzzle.Engine().init(allocator);

    const pzl = [_]u4{ 5, 3, 0, 0, 7, 0, 0, 0, 0, 6, 0, 0, 1, 9, 5, 0, 0, 0, 0, 9, 8, 0, 0, 0, 0, 6, 0, 8, 0, 0, 0, 6, 0, 0, 0, 3, 4, 0, 0, 8, 0, 3, 0, 0, 1, 7, 0, 0, 0, 2, 0, 0, 0, 6, 0, 6, 0, 0, 0, 0, 2, 8, 0, 0, 0, 0, 4, 1, 9, 0, 0, 5, 0, 0, 0, 0, 8, 0, 0, 7, 9 };
    try p.load(pzl[0..]);

    if (try p.solve() == false) {
        p.print_scratch();
    }
    try p.print();
}

test "simple test" {
    // let vals1 = vec![
    //     vec!['5', '3', '.', '.', '7', '.', '.', '.', '.'],
    //     vec!['6', '.', '.', '1', '9', '5', '.', '.', '.'],
    //     vec!['.', '9', '8', '.', '.', '.', '.', '6', '.'],
    //     vec!['8', '.', '.', '.', '6', '.', '.', '.', '3'],
    //     vec!['4', '.', '.', '8', '.', '3', '.', '.', '1'],
    //     vec!['7', '.', '.', '.', '2', '.', '.', '.', '6'],
    //     vec!['.', '6', '.', '.', '.', '.', '2', '8', '.'],
    //     vec!['.', '.', '.', '4', '1', '9', '.', '.', '5'],
    //     vec!['.', '.', '.', '.', '8', '.', '.', '7', '9'],
    // ];

    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
