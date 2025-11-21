// File: chapters-data/code/01__boot-basics/entry_point.zig

// Import the standard library for I/O and utility functions
const std = @import("std");
// Import builtin to access compile-time information like build mode
const builtin = @import("builtin");

// Define a custom error type for build mode violations
const ModeError = error{ReleaseOnly};

// Main entry point of the program
// Returns an error union to propagate any errors that occur during execution
pub fn main() !void {
    // Attempt to enforce debug mode requirement
    // If it fails, catch the error and rethrow the error
    const message = try requireDebugSafety();

    var stdout_buffer: [128]u8 = undefined;
    // Create a buffered writer wrapping stdout
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    // Get the generic writer interface for polymorphic I/O
    const stdout = &stdout_writer.interface;
    // Write formatted message to the buffer
    try stdout.print("{s}", .{message});
    // Flush the buffer to ensure message is written to stdout

    // Print startup message to stdout
    try announceStartup(stdout);
    try stdout.flush();
}

// Validates that the program is running in Debug mode
// Returns an error if compiled in Release mode to demonstrate error handling
fn requireDebugSafety() error{ReleaseOnly}![]const u8 {
    // Check compile-time build mode
    if (builtin.mode == .Debug) return "Debug safety checks enabled\n";
    // Return error if not in Debug mode
    return ModeError.ReleaseOnly;
}

// Writes a startup announcement message to standard output
// Demonstrates buffered I/O operations in Zig
fn announceStartup(stdout: *std.Io.Writer) !void {
    // Write formatted message to the buffer
    try stdout.print("Zig entry point reporting in.\n", .{});
    // Flush the buffer to ensure message is written to stdout
    try stdout.flush();
}
