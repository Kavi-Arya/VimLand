use std::env;
use std::fs;
use std::process::Command;

fn gonext(i: i32) {
    // If i is 1, dispatch with "e+1", otherwise with "+<i>"
    let workspace = if i == 1 {
        "e+1".to_string()
    } else {
        format!("+{}", i)
    };
    let status = Command::new("hyprctl")
        .args(&["dispatch", "workspace", &workspace])
        .status()
        .expect("failed to execute hyprctl for gonext");
    if !status.success() {
        eprintln!("hyprctl command failed with status: {:?}", status);
    }
}

fn goback(i: i32) {
    // If i is 1, dispatch with "e-1", otherwise with "-<i>"
    let workspace = if i == 1 {
        "e-1".to_string()
    } else {
        format!("-{}", i)
    };
    let status = Command::new("hyprctl")
        .args(&["dispatch", "workspace", &workspace])
        .status()
        .expect("failed to execute hyprctl for goback");
    if !status.success() {
        eprintln!("hyprctl command failed with status: {:?}", status);
    }
}

fn main() {
    // Get the first command-line argument; if missing, use an empty string.
    let args: Vec<String> = env::args().collect();
    let arg1 = if args.len() > 1 { &args[1] } else { "" };

    // Read the file "/tmp/hypr_num", defaulting to "1" if it doesn't exist or can't be read.
    let count_str = fs::read_to_string("/tmp/hypr_num").unwrap_or_else(|_| "1".to_string());
    let count: i32 = count_str.trim().parse().unwrap_or(1);

    // Clear the file by writing an empty string.
    fs::write("/tmp/hypr_num", "").expect("Unable to clear /tmp/hypr_num");

    // Loop from 0 to count - 1 and print the first argument each time.
    for _ in 0..count {
        println!("{}", arg1);
    }

    // After the loop, i equals count.
    let i = count;

    // Dispatch the command based on the argument.
    match arg1.as_str() {
        "gonext" => gonext(i),
        "goback" => goback(i),
        _ => {} // No matching action
    }
}

