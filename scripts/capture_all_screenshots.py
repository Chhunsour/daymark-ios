import subprocess
import time
import os
import shutil

SIMULATOR_ID = "A1FD0CEB-7F46-4A73-8D8E-F92B39CB64FC"
BUNDLE_ID = "com.chhunsour.Daymark"
DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer"
DOCS_DIR = "/Users/mac/.gemini/antigravity/scratch/daymark-ios/docs/screenshots"
BRAIN_DIR = "/Users/mac/.gemini/antigravity/brain/12481345-8166-4751-a1e6-e46f5f367e51/screenshots"

os.makedirs(DOCS_DIR, exist_ok=True)
os.makedirs(BRAIN_DIR, exist_ok=True)

def run_cmd(cmd):
    env = os.environ.copy()
    env["DEVELOPER_DIR"] = DEVELOPER_DIR
    res = subprocess.run(cmd, env=env, shell=True, capture_output=True, text=True)
    if res.returncode != 0 and "terminate" not in cmd:
        print(f"Command failed: {cmd}\nError: {res.stderr}")
    return res

def set_appearance(mode):
    run_cmd(f"xcrun simctl ui {SIMULATOR_ID} appearance {mode}")
    time.sleep(1)

def capture_screen(filename, args="", appearance="light", wait_sec=4):
    print(f"Capturing {filename} with args '{args}' (appearance: {appearance})...")
    set_appearance(appearance)
    run_cmd(f"xcrun simctl terminate {SIMULATOR_ID} {BUNDLE_ID}")
    time.sleep(1)
    
    launch_cmd = f"xcrun simctl launch {SIMULATOR_ID} {BUNDLE_ID} {args}".strip()
    run_cmd(launch_cmd)
    time.sleep(wait_sec)
    
    doc_path = os.path.join(DOCS_DIR, filename)
    run_cmd(f"xcrun simctl io {SIMULATOR_ID} screenshot {doc_path}")
    
    brain_path = os.path.join(BRAIN_DIR, filename)
    if os.path.exists(doc_path):
        shutil.copyfile(doc_path, brain_path)
        print(f"Saved: {doc_path} and {brain_path}")
    else:
        print(f"Error: {doc_path} was not created!")
        
    run_cmd(f"xcrun simctl terminate {SIMULATOR_ID} {BUNDLE_ID}")
    time.sleep(1)

def main():
    # Pre-seed starter data
    print("Pre-seeding starter data...")
    run_cmd(f"xcrun simctl launch {SIMULATOR_ID} {BUNDLE_ID} -ResetData")
    time.sleep(3)
    run_cmd(f"xcrun simctl terminate {SIMULATOR_ID} {BUNDLE_ID}")
    time.sleep(1)

    capture_screen("01_today_screen_light.png", appearance="light", wait_sec=5)
    capture_screen("02_today_screen_dark.png", appearance="dark", wait_sec=5)
    capture_screen("03_inbox_screen.png", args="-TabInbox", appearance="light", wait_sec=5)
    capture_screen("04_workspaces_screen.png", args="-TabProjects", appearance="light", wait_sec=5)
    capture_screen("05_workspace_detail.png", args="-ShowProjectDetail", appearance="light", wait_sec=5)
    capture_screen("06_settings_screen.png", args="-ShowSettings", appearance="light", wait_sec=5)
    capture_screen("07_routines_screen.png", args="-ShowRoutines", appearance="light", wait_sec=5)
    capture_screen("08_today_timeline_light.png", args="-ScrollToTimeline", appearance="light", wait_sec=5)
    
    # reset appearance to light
    set_appearance("light")
    print("All screenshots captured successfully!")

if __name__ == "__main__":
    main()
