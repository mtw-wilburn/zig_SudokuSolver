const std = @import("std");

pub fn Engine() type {
    return struct {
        const Self = @This();

        const Tag = enum {
            key,
            solved,
            scratch,
        };

        const TaggedVal = union(Tag) {
            key: u4,
            solved: u4,
            scratch: std.AutoHashMap(u4, void),
        };

        allocator: std.mem.Allocator,
        board: [9][9]?TaggedVal,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .board = [9][9]?TaggedVal{
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                    [_]?TaggedVal{ null, null, null, null, null, null, null, null, null },
                },
            };
        }

        pub fn get_row(self: *Self, y: u4) [9]*?TaggedVal {
            var row: [9]*?TaggedVal = undefined;
            for (0..9) |i| {
                row[i] = &self.board[i][y];
            }
            return row;
        }

        pub fn get_col(self: *Self, x: u4) [9]*?TaggedVal {
            var col: [9]*?TaggedVal = undefined;
            for (0..9) |i| {
                col[i] = &self.board[x][i];
            }
            return col;
        }

        pub fn get_sub(self: *Self, x: u4, y: u4) [9]*?TaggedVal {
            var _x: [3]u4 = undefined;
            var _y: [3]u4 = undefined;

            switch (x) {
                6...9 => _x = .{ 6, 7, 8 },
                3...5 => _x = .{ 3, 5, 4 },
                else => _x = .{ 0, 1, 2 },
            }

            switch (y) {
                6...9 => _y = .{ 6, 7, 8 },
                3...5 => _y = .{ 3, 5, 4 },
                else => _y = .{ 0, 1, 2 },
            }

            var sub: [9]*?TaggedVal = undefined;
            var counter: u4 = 0;
            for (_y) |j| {
                for (_x) |i| {
                    sub[counter] = &self.board[i][j];
                    counter += 1;
                }
            }
            return sub;
        }

        fn fill_scratch(self: *Self) !void {
            for (0..9) |y| {
                for (0..9) |x| {
                    var val = std.AutoHashMap(u4, void).init(self.allocator);
                    for (1..10) |v| {
                        const i_u4: u4 = @intCast(v);
                        try val.put(i_u4, void);
                    }
                    self.board[x][y] = .{ .scratch = val };
                }
            }
        }

        pub fn set_key(self: *Self, x: u4, y: u4, val: u4) void {
            self.board[x][y] = .{ .key = val };
        }

        pub fn set_solved(self: *Self, x: u4, y: u4, val: u4) void {
            self.boar[x][y] = .{ .solved = val };
        }

        // pub fn fill_scratch(self: *Self, x: u4, y: u4) !void {
        //     var val = std.AutoHashMap(u4, void).init(self.allocator);
        //     for (1..10) |i| {
        //         const i_u4: u4 = @intCast(i);
        //         try val.put(i_u4, {});
        //     }
        //     self.board[x][y] = .{ .scratch = val };
        // }

        pub fn print(self: Self) void {
            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |val| {
                        switch (val) {
                            .key => |n| std.debug.print("| {s}{d}{s} ", .{ blue, n, reset }),
                            .solved => |n| std.debug.print("| {d} ", .{n}),
                            else => {},
                        }
                    } else {
                        std.debug.print("| {s} ", .{" "});
                    }
                    if (x == 8) {
                        std.debug.print("|\n", .{});
                    }
                }
                if (y == 8) {
                    std.debug.print("-------------------------------------\n", .{});
                }
            }
        }

        pub fn print_row(self: Self, row: [9]*?TaggedVal) void {
            _ = self;
            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (row) |x| {
                if (x.*) |val| {
                    switch (val) {
                        .key => |n| std.debug.print("| {s}{d}{s} ", .{ blue, n, reset }),
                        .solved => |n| std.debug.print("| {d} ", .{n}),
                        else => {},
                    }
                } else {
                    std.debug.print("| {s} ", .{" "});
                }
            }
            std.debug.print("|\n", .{});
            std.debug.print("-------------------------------------\n", .{});
        }

        pub fn print_col(self: Self, col: [9]*?TaggedVal) void {
            _ = self;
            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (col) |x| {
                if (x.*) |val| {
                    switch (val) {
                        .key => |n| std.debug.print("| {s}{d}{s} ", .{ blue, n, reset }),
                        .solved => |n| std.debug.print("| {d} ", .{n}),
                        else => {},
                    }
                } else {
                    std.debug.print("| {s} ", .{" "});
                }
            }
            std.debug.print("|\n", .{});
            std.debug.print("-------------------------------------\n", .{});
        }

        pub fn print_sub(self: Self, sub: [9]*?TaggedVal) void {
            _ = self;
            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (sub) |x| {
                if (x.*) |val| {
                    switch (val) {
                        .key => |n| std.debug.print("| {s}{d}{s} ", .{ blue, n, reset }),
                        .solved => |n| std.debug.print("| {d} ", .{n}),
                        else => {},
                    }
                } else {
                    std.debug.print("| {s} ", .{" "});
                }
            }
            std.debug.print("|\n", .{});
            std.debug.print("-------------------------------------\n", .{});
        }

        pub fn print_scratch(self: *Self) void {
            const red = "\x1b[31m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |val| {
                        switch (val) {
                            .scratch => |*n| {
                                var entry = n.*;
                                std.debug.print("({d},{d}) ", .{ x, y });
                                for (1..10) |i| {
                                    const i_u4: u4 = @intCast(i);
                                    if (entry.contains(i_u4) == true) {
                                        std.debug.print("{s}{d}{s} ", .{ red, i_u4, reset });
                                        _ = entry.remove(i_u4);
                                    }
                                }
                                entry.deinit();
                                self.board[x][y] = null;
                                std.debug.print("\n", .{});
                            },
                            else => {},
                        }
                    }
                }
                if (y == 8) {
                    std.debug.print("-------------------------------------\n", .{});
                }
            }
        }
    };
}
