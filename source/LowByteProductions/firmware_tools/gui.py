import subprocess
import tkinter as tk
from tkinter import scrolledtext
import os

# Path to app Makefile
APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "app"))

FLASH_SIZE_BYTES = 512 * 1024  # STM32F446 = 512 KB


def run_cmd(cmd, output_box):
    output_box.delete(1.0, tk.END)
    output_box.insert(tk.END, f"$ {cmd}\n\n")

    try:
        p = subprocess.Popen(
            cmd,
            cwd=APP_DIR,                # IMPORTANT: run inside /app
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

        for line in p.stdout:
            output_box.insert(tk.END, line)
            output_box.see(tk.END)

        p.wait()

    except Exception as e:
        output_box.insert(tk.END, f"Error: {e}\n")


def calculate_flash_usage(elf_path):
    """Run `arm-none-eabi-size` and compute % flash used."""
    try:
        result = subprocess.run(
            ["arm-none-eabi-size", elf_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        lines = result.stdout.strip().split("\n")
        parts = lines[1].split()
        text = int(parts[0])
        data = int(parts[1])

        flash_used = text + data
        percentage = flash_used / FLASH_SIZE_BYTES * 100.0

        return flash_used, percentage

    except Exception:
        return None, None


def run_make_build(output_box):
    run_cmd("make -j", output_box)

    elf_path = os.path.join(APP_DIR, "firmware.elf")
    used, pct = calculate_flash_usage(elf_path)

    if used is not None:
        output_box.insert(tk.END, f"\nFlash used: {used} bytes ({pct:.2f}%)\n")
        output_box.see(tk.END)


def main():
    root = tk.Tk()
    root.title("Firmware Build GUI")
    root.geometry("710x520")

    frame = tk.Frame(root)
    frame.pack(pady=10)

    output_box = scrolledtext.ScrolledText(root, width=90, height=22, font=("Courier", 10))
    output_box.pack(padx=10, pady=10)

    buttons = [
        ("Build (Make)", lambda: run_make_build(output_box)),
        ("Rebuild", lambda: run_cmd("make clean && make -j", output_box)),
        ("Clean", lambda: run_cmd("make clean", output_box)),
        ("Flash", lambda: run_cmd("make flash", output_box)),
        ("Size", lambda: run_cmd("make size", output_box)),
        ("Objdump", lambda: run_cmd("make objdump", output_box)),
        ("GDB Debug", lambda: run_cmd("make gdb", output_box)),
    ]

    for label, cmd in buttons:
        tk.Button(frame, text=label, width=20, command=cmd).pack(pady=4)

    root.mainloop()


if __name__ == "__main__":
    main()

