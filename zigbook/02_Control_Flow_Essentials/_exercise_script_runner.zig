// Modify script_runner.zig to parse characters at runtime (for example, from a byte slice) and add a new command that resets the total, ensuring the switch stays exhaustive.
//
// File: chapters-data/code/02__control-flow-essentials/script_runner.zig

// Demonstrates advanced control flow: switch expressions, labeled loops,
// and early termination based on threshold conditions
const std = @import("std");

/// Enumeration of all possible action types in the script processor
const Action = enum { add, skip, threshold, resets, unknown };

/// Represents a single processing step with an associated action and value
const Step = struct {
    tag: Action,
    value: i32,
};

/// Contains the final state after script execution completes or terminates early
const Outcome = struct {
    index: usize, // Step index where processing stopped
    total: i32, // Accumulated total at termination
};

/// Maps single-character codes to their corresponding Action enum values.
/// Returns .unknown for unrecognized codes to maintain exhaustive handling.
fn mapCode(code: u8) Action {
    return switch (code) {
        'A' => .add,
        'S' => .skip,
        'T' => .threshold,
        'R' => .resets,
        else => .unknown,
    };
}

/// Executes a sequence of steps, accumulating values and checking threshold limits.
/// Processing stops early if a threshold step finds the total meets or exceeds the limit.
/// Returns an Outcome containing the stop index and final accumulated total.
fn process(script: []const Step, limit: i32) Outcome {
    // Running accumulator for add operations
    var total: i32 = 0;

    // for-else construct: break provides early termination value, else provides completion value
    const stop = outer: for (script, 0..) |step, index| {
        // Dispatch based on the current step's action type
        switch (step.tag) {
            // Add operation: accumulate the step's value to the running total
            .add => total += step.value,
            // Skip operation: bypass this step without modifying state
            .skip => continue :outer,
            // Threshold check: terminate early if limit is reached or exceeded
            .threshold => {
                if (total >= limit) break :outer Outcome{ .index = index, .total = total };
                // Threshold not met: continue to next step
                continue :outer;
            },
            .resets => {
                total = 0;
            },
            // Safety assertion: unknown actions should never appear in validated scripts
            .unknown => unreachable,
        }
    } else Outcome{ .index = script.len, .total = total }; // Normal completion after all steps
    //

    return stop;
}

pub fn parseStep(input: []const u8) ![]Step {
    const page_alloc = std.heap.page_allocator;
    var arr_list: std.ArrayList(Step) = .empty;
    defer arr_list.deinit(page_alloc);

    var i: usize = 0;
    while (i < input.len) {
        if (i + 1 >= input.len) return error.InvalidFormat; // Need at least tag+1 digit

        // Extract tag (single character)
        const tag = input[i];
        i += 1;

        // Extract value (read until next tag or end)
        const value_start = i;
        while (i < input.len and input[i] >= '0' and input[i] <= '9') {
            i += 1;
        }

        if (value_start == i) return error.InvalidFormat; // No digits found

        const value_str = input[value_start..i];
        const value = try std.fmt.parseInt(i32, value_str, 10);

        try arr_list.append(page_alloc, Step{ .tag = mapCode(tag), .value = value });
    }

    // Convert ArrayList items to slice (needs to be copied since arr_list will be freed)
    const result = try page_alloc.alloc(Step, arr_list.items.len);
    @memcpy(result, arr_list.items);

    return result;
}

pub fn main() !void {
    // Define a script sequence demonstrating all action types
    const script = try parseStep("A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2R0A2S0A5T6A10");

    // Execute the script with a threshold limit of 6
    const outcome = process(script, 6);

    // Report where execution stopped and the final accumulated value
    std.debug.print(
        "stopped at step {d} with total {d}\n",
        .{ outcome.index, outcome.total },
    );
}
