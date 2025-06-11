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
                .board = .{.{null} ** 9} ** 9,
            };
        }

        pub fn load(self: *Self, data: []const u4) !void {
            try self.fill_scratch();
            var x: u4 = 0;
            var y: u4 = 0;
            for (data, 0..) |d, idx| {
                switch (d) {
                    0 => {},
                    else => {
                        const i: u8 = @intCast(idx);
                        x = @intCast(i % 9);
                        y = @intCast(i / 9);
                        self.set(x, y, d, Tag.key);
                    },
                }
            }
        }

        pub fn solve(self: *Self) !void {
            while (true) {
                self.algorithm_a();
                if (self.is_solved() == true) {
                    break;
                }

                if (self.algorithm_b() == true) {
                    continue;
                }

                if (self.algorithm_c() == true) {
                    continue;
                }

                if (self.algorithm_d() == true) {
                    continue;
                }

                if (try self.algorithm_e() == true) {
                    continue;
                }
                break;
            }
        }

        pub fn print(self: Self) !void {
            const out = std.io.getStdOut();
            const writer = out.writer();

            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

            std.debug.print("-------------------------------------\n", .{});
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |val| {
                        switch (val) {
                            .key => |n| try writer.print("| {s}{d}{s} ", .{ blue, n, reset }),
                            .solved => |n| try writer.print("| {d} ", .{n}),
                            else => try writer.print("| {s} ", .{" "}),
                        }
                    } else {
                        try writer.print("| {s} ", .{" "});
                    }
                    if (x == 8) {
                        try writer.print("|\n", .{});
                    }
                }
                if (y == 8) {
                    try writer.print("-------------------------------------\n", .{});
                }
            }
        }

        // pub fn print_rcs(self: Self, arr: [9]*?TaggedVal) void {
        //     _ = self;
        //     const blue = "\x1b[34m";
        //     const reset = "\x1b[0m";
        //
        //     std.debug.print("-------------------------------------\n", .{});
        //     for (arr) |x| {
        //         if (x.*) |val| {
        //             switch (val) {
        //                 .key => |n| std.debug.print("| {s}{d}{s} ", .{ blue, n, reset }),
        //                 .solved => |n| std.debug.print("| {d} ", .{n}),
        //                 else => std.debug.print("| {s} ", .{" "}),
        //             }
        //         } else {
        //             std.debug.print("| {s} ", .{" "});
        //         }
        //     }
        //     std.debug.print("|\n", .{});
        //     std.debug.print("-------------------------------------\n", .{});
        // }

        pub fn print_scratch(self: *Self) void {
            const red = "\x1b[31m";
            const reset = "\x1b[0m";

            // std.debug.print("-------------------------------------\n", .{});
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |val| {
                        switch (val) {
                            .scratch => |*n| {
                                var entry = n.*;
                                std.debug.print("({d},{d} count={d} ) ", .{ x, y, entry.count() });
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
                    // std.debug.print("-------------------------------------\n", .{});
                }
            }
        }

        fn get_row(self: *Self, y: u4) [9]*?TaggedVal {
            var row: [9]*?TaggedVal = undefined;
            for (0..9) |i| {
                row[i] = &self.board[i][y];
            }
            return row;
        }

        fn get_col(self: *Self, x: u4) [9]*?TaggedVal {
            var col: [9]*?TaggedVal = undefined;
            for (0..9) |i| {
                col[i] = &self.board[x][i];
            }
            return col;
        }

        fn get_sub(self: *Self, x: u4, y: u4) [9]*?TaggedVal {
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
                        try val.put(@as(u4, @intCast(v)), {});
                    }
                    self.board[x][y] = .{ .scratch = val };
                }
            }
        }

        fn scratch_remove_key(self: *Self, arr: [9]*?TaggedVal, val: u4) void {
            _ = self;
            for (arr) |idx| {
                if (idx.*) |*elm| {
                    switch (elm.*) {
                        .scratch => |*tag| {
                            if (tag.contains(val) == true) {
                                _ = tag.remove(val);
                            }
                        },
                        else => {},
                    }
                }
            }
        }

        fn get_solution_count_2(self: *Self) !std.ArrayList(struct { u4, u4, *?TaggedVal }) {
            var list = std.ArrayList(struct { u4, u4, *?TaggedVal }).init(self.allocator);

            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |*cell| {
                        switch (cell.*) {
                            .scratch => |*s| {
                                if (s.count() == 2) {
                                    try list.append(.{ @as(u4, @intCast(x)), @as(u4, @intCast(y)), &self.board[x][y] });
                                }
                            },
                            else => {},
                        }
                    }
                }
            }
            return list;
        }

        fn set(self: *Self, x: u4, y: u4, val: u4, tag: Tag) void {
            if (self.board[x][y]) |*cell| {
                switch (cell.*) {
                    .scratch => |*t| {
                        t.*.deinit();
                    },
                    else => {},
                }
            }
            switch (tag) {
                .key => self.board[x][y] = .{ .key = val },
                .solved => self.board[x][y] = .{ .solved = val },
                else => {},
            }
            self.scratch_remove_key(self.get_row(y), val);
            self.scratch_remove_key(self.get_col(x), val);
            self.scratch_remove_key(self.get_sub(x, y), val);
        }

        fn algorithm_a(self: *Self) void {
            var keep_going = true;

            while (keep_going) {
                keep_going = false;
                for (0..9) |y| {
                    for (0..9) |x| {
                        if (self.board[x][y]) |*tag| {
                            switch (tag.*) {
                                .scratch => |*s| {
                                    if (s.count() == 1) {
                                        var iter = s.keyIterator();
                                        const k = iter.next().?.*;
                                        self.set(@as(u4, @intCast(x)), @as(u4, @intCast(y)), k, Tag.solved);
                                        //Note: the set will be removed/deinited in the above set call
                                        keep_going = true;
                                    }
                                },
                                else => {},
                            }
                        }
                    }
                }
            }
        }

        // examine each possible solution for a cell, if the empty cells for that row
        // cannot have that value because their respective cols already contain that value
        // we've found the only possible value for the cell
        fn algorithm_b(self: *Self) bool {
            for (0..9) |y| {
                const row = self.get_row(@as(u4, @intCast(y)));
                for (row, 0..) |r, x| {
                    if (r.*) |*elm| {
                        switch (elm.*) {
                            .scratch => |*s| {
                                var iter = s.keyIterator();
                                while (iter.next()) |k| {
                                    var found = true;
                                    for (row, 0..) |r1, i| {
                                        if (x == i) {
                                            continue;
                                        }
                                        if (r1.*) |*e| {
                                            switch (e.*) {
                                                .scratch => |*s1| {
                                                    if (s1.contains(k.*) == true) {
                                                        found = false;
                                                        break;
                                                    }
                                                },
                                                else => {},
                                            }
                                        }
                                    }
                                    if (found == true) {
                                        self.set(@as(u4, @intCast(x)), @as(u4, @intCast(y)), k.*, Tag.solved);
                                        return true;
                                    }
                                }
                            },
                            else => {},
                        }
                    }
                }
            }
            return false;
        }

        // examine each possible solution for a cell, if the empty cells for that col
        // cannot have that value because their respective rows already contain that value
        // we've found the only possible value for the cell
        fn algorithm_c(self: *Self) bool {
            for (0..9) |x| {
                const col = self.get_col(@as(u4, @intCast(x)));
                for (col, 0..) |c, y| {
                    if (c.*) |*elm| {
                        switch (elm.*) {
                            .scratch => |*s| {
                                var iter = s.keyIterator();
                                while (iter.next()) |k| {
                                    var found = true;
                                    for (col, 0..) |c1, i| {
                                        if (y == i) {
                                            continue;
                                        }
                                        if (c1.*) |*e| {
                                            switch (e.*) {
                                                .scratch => |*s1| {
                                                    if (s1.contains(k.*) == true) {
                                                        found = false;
                                                        break;
                                                    }
                                                },
                                                else => {},
                                            }
                                        }
                                    }
                                    if (found == true) {
                                        self.set(@as(u4, @intCast(x)), @as(u4, @intCast(y)), k.*, Tag.solved);
                                        return true;
                                    }
                                }
                            },
                            else => {},
                        }
                    }
                }
            }
            return false;
        }

        //Determine if any of the unsolved cells in a sub-box can be solved
        //by examining all the cells in that sub-box.  By checking if out of
        //all possibilities is there a cell with one unique possible solution
        fn algorithm_d(self: *Self) bool {
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |*tag| {
                        switch (tag.*) {
                            .scratch => |*s| {
                                var iter = s.keyIterator();
                                while (iter.next()) |k| {
                                    var found = true;
                                    const sub = self.get_sub(@as(u4, @intCast(x)), @as(u4, @intCast(y)));
                                    for (sub) |c| {
                                        if (c.*) |*e| {
                                            switch (e.*) {
                                                .scratch => |*s1| {
                                                    if (s1.contains(k.*) == true) {
                                                        found = false;
                                                        break;
                                                    }
                                                },
                                                else => {},
                                            }
                                        }
                                    }
                                    if (found == true) {
                                        self.set(@as(u4, @intCast(x)), @as(u4, @intCast(y)), k.*, Tag.solved);
                                        return true;
                                    }
                                }
                            },
                            else => {},
                        }
                    }
                }
            }
            return false;
        }

        fn algorithm_e(self: *Self) !bool {
            var retval = false;
            const list = try self.get_solution_count_2();
            defer list.deinit();

            for (list.items, 0..) |*a, i| {
                for (list.items, 0..) |*b, j| {
                    if (i == j) {
                        continue;
                    }
                    if (a.*[2].*) |*x| {
                        switch (x.*) {
                            .scratch => |*map| {
                                var iter = map.keyIterator();
                                var keys: [2]u4 = undefined;
                                var count: u4 = 0;
                                var eql = true;
                                while (iter.next()) |k| {
                                    if (b.*[2].*.?.scratch.contains(k.*)) {
                                        keys[count] = k.*;
                                        count += 1;
                                    } else {
                                        eql = false;
                                    }
                                }

                                if (eql == true) {
                                    if (a[1] == b[1]) {
                                        const row = self.get_row(a[1]);
                                        for (row) |item| {
                                            if (item.*) |*t| {
                                                switch (t.*) {
                                                    .scratch => |*s| {
                                                        if (s.count() > 2) {
                                                            _ = s.remove(keys[0]);
                                                            _ = s.remove(keys[1]);
                                                            retval = true;
                                                        }
                                                    },
                                                    else => {},
                                                }
                                            }
                                        }
                                    }

                                    if (a[0] == b[0]) {
                                        const col = self.get_col(a[1]);
                                        for (col) |item| {
                                            if (item.*) |*t| {
                                                switch (t.*) {
                                                    .scratch => |*s| {
                                                        if (s.count() > 2) {
                                                            _ = s.remove(keys[0]);
                                                            _ = s.remove(keys[1]);
                                                            retval = true;
                                                        }
                                                    },
                                                    else => {},
                                                }
                                            }
                                        }
                                    }

                                    if (a[0] == b[0] and a[1] == b[1]) {
                                        const box = self.get_sub(a[0], a[1]);
                                        for (box) |item| {
                                            if (item.*) |*t| {
                                                switch (t.*) {
                                                    .scratch => |*s| {
                                                        if (s.count() > 2) {
                                                            _ = s.remove(keys[0]);
                                                            _ = s.remove(keys[1]);
                                                            retval = true;
                                                        }
                                                    },
                                                    else => {},
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            else => {},
                        }
                    }
                }
            }
            return retval;
        }

        fn is_solved(self: Self) bool {
            for (0..9) |y| {
                for (0..9) |x| {
                    if (self.board[x][y]) |val| {
                        switch (val) {
                            .scratch => {
                                return false;
                            },
                            else => {},
                        }
                    }
                }
            }
            return true;
        }
    };
}
