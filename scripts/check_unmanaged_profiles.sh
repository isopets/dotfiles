#!/bin/bash
VSCODE_PROFILES_DIR="$HOME/Library/Application Support/Code/User/profiles"
PROFILE_LIST="$HOME/dotfiles/vscode/profile_list.txt"
UNMANAGED_FOUND=false

if [ ! -f "$PROFILE_LIST" ]; then exit 0; fi

MANAGED_PROFILES=("Default") # Defaultは除外
while IFS=: read -r name file; do
    [[ "$name" =~ ^#.*$ ]] && continue
    [[ -z "$name" ]] && continue
    MANAGED_PROFILES+=("$name")
done < "$PROFILE_LIST"

if [ -d "$VSCODE_PROFILES_DIR" ]; then
    for profile_path in "$VSCODE_PROFILES_DIR"/*; do
        if [ -d "$profile_path" ]; then
            profile_name=$(basename "$profile_path")
            is_managed=false
            for managed in "${MANAGED_PROFILES[@]}"; do
                if [[ "$managed" == "$profile_name" ]]; then is_managed=true; break; fi
            done
            if [ "$is_managed" = false ]; then
                echo "🚨 警告: 管理外のプロファイル '$profile_name' を検知！ 'mkprofile' を使ってください。"
                UNMANAGED_FOUND=true
            fi
        fi
    done
fi