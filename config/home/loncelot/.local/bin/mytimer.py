#!/usr/bin/env python3

import tkinter as tk
from tkinter import font
from datetime import datetime
from pathlib import Path

OUTPUT_FILE = Path.home() / "Desktop" / "timer.txt"

start_time = None
running = False


def update_timer():
    if running and start_time:
        elapsed = datetime.now() - start_time
        total = int(elapsed.total_seconds())

        h = total // 3600
        m = (total % 3600) // 60
        s = total % 60

        timer_var.set(f"{h:02d}:{m:02d}:{s:02d}")

    root.after(200, update_timer)


def start_timer():
    global start_time, running
    if running:
        return
    start_time = datetime.now()
    running = True


def stop_timer():
    global start_time, running
    if not running:
        return

    stop_time = datetime.now()
    elapsed = stop_time - start_time

    total = int(elapsed.total_seconds())
    h = total // 3600
    m = (total % 3600) // 60
    s = total % 60

    elapsed_str = f"{h:02d}:{m:02d}:{s:02d}"

    with open(OUTPUT_FILE, "a") as f:
        f.write(
            f"{start_time:%Y-%m-%d %H:%M:%S} | "
            f"{stop_time:%Y-%m-%d %H:%M:%S} | "
            f"{elapsed_str}\n"
        )

    running = False
    start_time = None
    timer_var.set("00:00:00")


def exit_app():
    root.destroy()


# ---------------- UI ----------------

root = tk.Tk()
root.title("Timer")
root.geometry("150x35")
root.resizable(False, False)
root.attributes("-topmost", True)

icon = tk.PhotoImage(
    file="/usr/share/icons/hicolor/48x48/apps/xfce4-time-out-plugin.png"
)
root.iconphoto(True, icon)

BG = "black"
FG = "white"

root.configure(bg=BG)

timer_var = tk.StringVar(value="00:00:00")

# native font + bold
base_font = font.nametofont("TkDefaultFont")
bold_font = base_font.copy()
bold_font.configure(weight="bold")

# ---------------- LAYOUT ----------------

top = tk.Frame(root, bg=BG)
top.pack(fill="both", expand=True)

# IMPORTANT: fixes vertical centering issue
top.grid_rowconfigure(0, weight=1)
top.grid_columnconfigure(0, weight=1)
top.grid_columnconfigure(1, weight=0)

# timer label
tk.Label(
    top,
    textvariable=timer_var,
    font=bold_font,
    bg=BG,
    fg=FG
).grid(row=0, column=0, sticky="nsew")

# dropdown button
menu_btn = tk.Menubutton(
    top,
    text="▼",
    font=("Sans", 12, "bold"),
    bg=BG,
    fg=FG,
    activebackground=BG,
    activeforeground=FG,
    relief="flat",
)

menu_btn.grid(row=0, column=1, sticky="e")

menu = tk.Menu(
    menu_btn,
    tearoff=0,
    bg=BG,
    fg=FG,
    activebackground="#222",
    activeforeground=FG
)

menu.add_command(label="Start", command=start_timer)
menu.add_command(label="Stop", command=stop_timer)
menu.add_command(label="Exit", command=exit_app)

menu_btn["menu"] = menu

# ---------------- RUN ----------------

update_timer()
root.mainloop()