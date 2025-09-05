#!/usr/bin/env python

def can_build(env, platform):
    if platform == "windows" and env.get("use_mingw", False):
        print("godot_wry: Disabled for Windows MinGW builds")
        return False
    return platform in ["linuxbsd", "windows", "macos"]

def configure(env):
    pass

def get_doc_classes():
    return [
        "WebView",
    ]

def get_doc_path():
    return "doc_classes"
