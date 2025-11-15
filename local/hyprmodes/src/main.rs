use notify::{DebouncedEvent, RecommendedWatcher, RecursiveMode, Watcher};
use std::env;
use std::fs;
use std::path::PathBuf;
use std::sync::mpsc::channel;
use std::time::Duration;

fn update_mode(mode_path: &PathBuf) {
    let mode = fs::read_to_string(mode_path)
        .unwrap_or_else(|err| {
            eprintln!("Error reading mode file: {}", err);
            String::new()
        })
        .trim()
        .to_string();
    let home = env::var("HOME").unwrap();
    let dest = format!("{}/.config/waybar/colors.css", home);
    match mode.as_str() {
        "Normal Mode" => {
            println!("Normal Mode");
            let src = format!("{}/.config/waybar/MODES/colors-Normal-Mode.css", home);
            if let Err(e) = fs::copy(&src, &dest) {
                eprintln!("Failed to copy {} to {}: {}", src, dest, e);
            }
            // send_signal_to_waybar();
        }
        "Insert Mode" => {
            println!("Insert Mode");
            let src = format!("{}/.config/waybar/MODES/colors-Insert-Mode.css", home);
            if let Err(e) = fs::copy(&src, &dest) {
                eprintln!("Failed to copy {} to {}: {}", src, dest, e);
            }
        }
        "Site Mode" => {
            println!("Insert Mode (Site Mode)");
            let src = format!("{}/.config/waybar/MODES/colors-Site-Mode.css", home);
            if let Err(e) = fs::copy(&src, &dest) {
                eprintln!("Failed to copy {} to {}: {}", src, dest, e);
            }
        }
        "Run Mode" => {
            println!("Insert Mode (Run Mode)");
            let src = format!("{}/.config/waybar/MODES/colors-Run-Mode.css", home);
            if let Err(e) = fs::copy(&src, &dest) {
                eprintln!("Failed to copy {} to {}: {}", src, dest, e);
            }
            // send_signal_to_waybar();
        }
        _ => {
            println!("Unknown mode: {}", mode);
        }
    }
}

fn main() {
    // Build the path to the mode file
    let home = env::var("HOME").expect("Could not determine HOME directory");
    let mode_file = format!("{}/.config/hypr/mode.txt", home);
    let mode_path = PathBuf::from(&mode_file);
    if !mode_path.exists() {
        eprintln!("Error: mode.txt not found!");
        std::process::exit(1);
    }
    update_mode(&mode_path);
    let mut last_mode = fs::read_to_string(&mode_path)
        .unwrap_or_default()
        .trim()
        .to_string();
    let (tx, rx) = channel();
    let mut watcher: RecommendedWatcher =
        Watcher::new(tx, Duration::from_secs(0)).expect("Failed to initialize watcher");
    watcher
        .watch(&mode_path, RecursiveMode::NonRecursive)
        .expect("Failed to watch mode file");
    loop {
        match rx.recv() {
            Ok(event) => {
                match event {
                    DebouncedEvent::Write(_) | DebouncedEvent::Chmod(_) => {
                        let new_mode = fs::read_to_string(&mode_path)
                            .unwrap_or_default()
                            .trim()
                            .to_string();
                        if new_mode != last_mode {
                            last_mode = new_mode;
                            update_mode(&mode_path);
                        }
                    }
                    _ => {
                        // println!("Other event: {:?}", event);
                    }
                }
            }
            Err(e) => eprintln!("watch error: {:?}", e),
        }
    }
}
