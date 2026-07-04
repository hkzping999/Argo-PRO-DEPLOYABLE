#!/usr/bin/env bash
# shellcheck shell=bash

info() { printf '\033[32m\033[01m%s\033[0m\n' "$*"; }
warning() { printf '\033[31m\033[01m%s\033[0m\n' "$*" >&2; }
hint() { printf '\033[33m\033[01m%s\033[0m\n' "$*"; }
error() { warning "$*"; exit 1; }
