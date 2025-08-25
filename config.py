#!/usr/bin/env python

def can_build(env, platform):
    return platform in ["linuxbsd", "windows", "macos"]

def configure(env):
    pass

def get_doc_classes():
    return [
        "Webview",
    ]

def get_doc_path():
    return "doc_classes"
