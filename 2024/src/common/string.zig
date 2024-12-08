const std = @import("std");

pub fn countOccurrences(needle: []const u8, haystack: []const u8) u64 {
    var total_occurrences: u64 = 0;
    var index: usize = 0;

    while (index < haystack.len) {
        const maybe_found_index = std.mem.indexOf(u8, haystack[index..], needle);
        if (maybe_found_index == null) {
            break;
        }
        index += maybe_found_index.? + 1;
        total_occurrences += 1;
    }
    return total_occurrences;
}
