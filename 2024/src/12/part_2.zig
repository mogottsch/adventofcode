const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const Vector2D = parse.Vector2D;
const part_1 = @import("part_1.zig");

const ALL_DIRECTIONS = part_1.ALL_DIRECTIONS;
const Direction = part_1.Direction;
const UpVector = part_1.UpVector;
const LeftVector = part_1.LeftVector;
const RightVector = part_1.RightVector;
const DownVector = part_1.DownVector;
const Region = part_1.Region;

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    const regions = try getAllRegions(allocator, input);
    defer allocator.free(regions);

    return part_1.calculatePrice(regions);
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
            if (!isPartOfExistingSide(input, current_cell_pos, direction, region.type)) region.perimeter += 1;
            continue;
        };
        const neighbor_cell = input.getCell(neighbor_position);

        if (neighbor_cell != region.type) {
            if (!isPartOfExistingSide(input, current_cell_pos, direction, region.type)) region.perimeter += 1;
            continue;
        }
        if (visited.get(neighbor_position) != null) continue;

        try exploreRegion(input, visited, neighbor_position, region);
    }
}

fn isPartOfExistingSide(input: parse.Input, position: Vector2D, direction: Direction, region_type: u8) bool {
    const offset_direction = switch (direction) {
        Direction.Left => UpVector,
        Direction.Right => UpVector,
        Direction.Up => LeftVector,
        Direction.Down => LeftVector,
    };
    const potential_existing_site_same_region_pos = position.addSafe(offset_direction, input) catch return false;
    const potential_existing_site_same_region_cell = input.getCell(potential_existing_site_same_region_pos);
    if (potential_existing_site_same_region_cell != region_type) return false;

    const direction_vector = direction.getVector();

    const potential_existing_site_other_region_pos = potential_existing_site_same_region_pos.addSafe(
        direction_vector,
        input,
    ) catch return true;
    if (input.getCell(potential_existing_site_other_region_pos) == region_type) return false;

    return true;
}

test "isPartOfExistingSide" {
    const allocator = std.heap.page_allocator;
    var array = [_][4]u8{
        .{ 1, 1, 2, 2 },
        .{ 1, 1, 2, 2 },
        .{ 3, 3, 4, 4 },
        .{ 3, 3, 4, 4 },
    };
    const rows = array.len;
    var slices: [4][]u8 = undefined;
    for (0..rows) |i| {
        slices[i] = array[i][0..];
    }
    const grid: [][]u8 = &slices;

    const input = parse.Input{
        .grid = grid,
        .allocator = allocator,
    };

    // start of side out of bounds
    try testing.expect(!isPartOfExistingSide(input, Vector2D{ .x = 0, .y = 0 }, Direction.Left, 1));
    try testing.expect(!isPartOfExistingSide(input, Vector2D{ .x = 0, .y = 0 }, Direction.Up, 1));

    // part of existing side out of bounds
    try testing.expect(isPartOfExistingSide(input, Vector2D{ .x = 0, .y = 1 }, Direction.Left, 1));
    try testing.expect(isPartOfExistingSide(input, Vector2D{ .x = 1, .y = 0 }, Direction.Up, 1));

    // start of side
    try testing.expect(!isPartOfExistingSide(input, Vector2D{ .x = 2, .y = 0 }, Direction.Left, 2));
    try testing.expect(!isPartOfExistingSide(input, Vector2D{ .x = 2, .y = 0 }, Direction.Up, 2));

    // part of existing side
    try testing.expect(isPartOfExistingSide(input, Vector2D{ .x = 2, .y = 1 }, Direction.Left, 2));
    try testing.expect(isPartOfExistingSide(input, Vector2D{ .x = 3, .y = 0 }, Direction.Up, 2));
}
