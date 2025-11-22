import subprocess
import tkinter as tk
from tkinter import scrolledtext

BUILD_SCRIPT = "./build.sh"
FLASH_SIZE_BYTES = 512 * 1024  # STM32F446 = 512 KB


def run_cmd(cmd, output_box):
    output_box.delete(1.0, tk.END)
    output_box.insert(tk.END, f"$ {cmd}\n\n")
    try:
        p = subprocess.Popen(
            cmd, shell=True,
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
        # Example:
        # text   data    bss ...
        # 87220   120     500 ...

        parts = lines[1].split()
        text = int(parts[0])
        data = int(parts[1])
        flash_used = text + data

        percentage = flash_used / FLASH_SIZE_BYTES * 100.0
        return flash_used, percentage

    except Exception:
        return None, None


def run_build_and_show_flash(output_box, use_ninja=False):
    """Build firmware and print flash usage."""
    cmd = f"{BUILD_SCRIPT} build"
    if use_ninja:
        cmd += " --ninja"

    run_cmd(cmd, output_box)

    elf_path = "build/firmware.elf"
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
        ("Build (Ninja)", lambda: run_build_and_show_flash(output_box, use_ninja=True)),
        ("Build (Make)", lambda: run_build_and_show_flash(output_box, use_ninja=False)),
        ("Rebuild (Ninja)", lambda: run_cmd(f"{BUILD_SCRIPT} rebuild --ninja", output_box)),
        ("Rebuild (Make)", lambda: run_cmd(f"{BUILD_SCRIPT} rebuild", output_box)),
        ("Clean", lambda: run_cmd(f"{BUILD_SCRIPT} clean", output_box)),
        ("Flash", lambda: run_cmd(f"{BUILD_SCRIPT} flash", output_box)),
        ("Size", lambda: run_cmd(f"{BUILD_SCRIPT} size", output_box)),
        ("Objdump", lambda: run_cmd(f"{BUILD_SCRIPT} objdump", output_box)),
        ("GDB Debug", lambda: run_cmd(f"{BUILD_SCRIPT} gdb", output_box)),
    ]

    for label, cmd in buttons:
        tk.Button(
            frame, text=label, width=20,
            command=cmd
        ).pack(pady=4)

    root.mainloop()
