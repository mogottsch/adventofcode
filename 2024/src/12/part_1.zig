const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const Vector2D = parse.Vector2D;

pub const Region = struct {
    area: u64,
    perimeter: u64,
    type: u8,

    pub fn print(self: Region) void {
        std.debug.print("Region {c} has area {d} and perimeter {d}\n", .{ self.type, self.area, self.perimeter });
    }
};

pub const UpVector = Vector2D{ .x = 0, .y = -1 };
pub const DownVector = Vector2D{ .x = 0, .y = 1 };
pub const LeftVector = Vector2D{ .x = -1, .y = 0 };
pub const RightVector = Vector2D{ .x = 1, .y = 0 };
pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn getVector(self: Direction) Vector2D {
        switch (self) {
            Direction.Up => return UpVector,
            Direction.Down => return DownVector,
            Direction.Left => return LeftVector,
            Direction.Right => return RightVector,
        }
    }
};
pub const ALL_DIRECTIONS = [_]Direction{ Direction.Up, Direction.Down, Direction.Left, Direction.Right };

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    const regions = try getAllRegions(allocator, input);
    defer allocator.free(regions);

    return calculatePrice(regions);
}

pub fn getAllRegions(allocator: std.mem.Allocator, input: parse.Input) ![]Region {
    var visited = std.AutoHashMap(parse.Vector2D, void).init(allocator);
    defer visited.deinit();

    var regions = std.ArrayList(Region).init(allocator);

    for (0..input.grid.len) |y| {
        for (0..input.grid[0].len) |x| {
            const position = Vector2D.initFromUsize(x, y);
            if (visited.get(position) != null) continue;
            try visited.put(position, {});

            const cell = input.getCell(position);

            var region = Region{ .area = 0, .perimeter = 0, .type = cell };
            try exploreRegion(input, &visited, position, &region);
            try regions.append(region);
        }
    }

    return regions.toOwnedSlice();
}

fn exploreRegion(
    input: parse.Input,
    visited: *std.AutoHashMap(parse.Vector2D, void),
    current_cell_pos: parse.Vector2D,
    region: *Region,
) !void {
    region.area += 1;
    try visited.put(current_cell_pos, {});

    for (ALL_DIRECTIONS) |direction| {
        const neighbor_position = current_cell_pos.addSafe(direction.getVector(), input) catch {
            region.perimeter += 1;
            continue;
        };
        const neighbor_cell = input.getCell(neighbor_position);

        if (neighbor_cell != region.type) {
            region.perimeter += 1;
            continue;
        }
        if (visited.get(neighbor_position) != null) continue;

        try exploreRegion(input, visited, neighbor_position, region);
    }
}

pub fn calculatePrice(regions: []Region) u64 {
    var price: u64 = 0;
    for (regions) |region| {
        const region_price = region.area * region.perimeter;
        price += region_price;
    }
    return price;
}
