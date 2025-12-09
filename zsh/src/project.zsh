## =================================================================
## 🏗️ Project Manager (Profile Resolver Edition)
## =================================================================

## New Project
function mkproj() {
    local c="$1"
    local n="$2"
    
    # 1. カテゴリ & 名前
    if [ -z "$c" ]; then
        c=$(ls -F "$HOME/Projects" 2>/dev/null | grep "/" | tr -d "/" | fzf --prompt="📂 Category > ")
        [ -z "$c" ] && return 1
    fi
    [ -z "$n" ] && echo -n "📛 Name: " && read n
    [ -z "$n" ] && return 1
    
    local p="$HOME/Projects/$c/$n"
    local para="$HOME/PARA/1_Projects/$n"
    [ -d "$p" ] && echo "⚠️  Exists." && return 1
    
    # 2. テンプレート選択
    local template_choice=$(gum choose --header="🏗️ Select Template" \
        "🌑 Empty" "🐍 Python (uv)" "⚛️  Next.js" "🦀 Rust" "🐹 Go")
        
    echo "🚀 Creating $n in $c..."
    mkdir -p "$p" "$para"
    cd "$p"
    
    # Git
    git init
    mkdir -p .vscode
    ln -s "$p" "$para/_Code"

    # Scaffolding
    local search_keyword=""
    local ext_list_type=""

    case "$template_choice" in
        *"Python"*)
            if command -v uv >/dev/null; then uv init; uv venv; else echo "print('Hi')" > main.py; fi
            search_keyword="Python"
            ext_list_type="python"
            ;;
        *"Next.js"*)
            npx create-next-app@latest . --typescript --tailwind --eslint --no-src-dir --import-alias "@/*" --use-npm
            search_keyword="Web" # "Next", "React", "Web" などが含まれるプロファイルを探す
            ext_list_type="web"
            ;;
        *"Rust"*)
            cargo init
            search_keyword="Rust"
            ext_list_type="rust"
            ;;
        *"Go"*)
            go mod init "$n"; echo 'package main\nfunc main(){}' > main.go
            search_keyword="Go"
            ext_list_type="go"
            ;;
        *) echo "# $n" > README.md ;;
    esac
    
    # 3. 設定生成 (Resolver経由)
    # ここで "Base" や "Core" などを柔軟に探す
    _generate_vscode_settings_dynamic "$search_keyword" "new"
    
    # 拡張機能リスト生成
    _generate_extensions_json "$ext_list_type"
    
    echo "✅ Project '$n' created."
    if gum confirm "🚀 Start working now?"; then work "$n"; fi
}

## 🔄 Sync Config
function sync-config() {
    echo "🔄 Syncing VS Code Profile..."
    
    local search_keyword=""
    local ext_type=""

    # 自動検知
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || ls *.py >/dev/null 2>&1; then
        search_keyword="Python"; ext_type="python"
    elif [ -f "package.json" ]; then
        search_keyword="Web"; ext_type="web"
    elif [ -f "Cargo.toml" ]; then
        search_keyword="Rust"; ext_type="rust"
    elif [ -f "go.mod" ]; then
        search_keyword="Go"; ext_type="go"
    fi

    # 検知できなかったら手動選択
    if [ -z "$search_keyword" ]; then
        echo "⚠️  Could not auto-detect project type."
        # ここでは直接プロファイルを選ばせる
        local chosen_profile=$(ls "$HOME/dotfiles/vscode/profiles" | tr -d "'" | gum choose --header="🤔 Choose Language Profile" --limit=1)
        [ -z "$chosen_profile" ] && return
        # 選ばれた名前そのものをキーワードとして扱う
        search_keyword="$chosen_profile"
    fi
    
    echo "🔍 Syncing with keyword: $search_keyword"
    
    mkdir -p .vscode
    # 設定生成 (マージモード)
    _generate_vscode_settings_dynamic "$search_keyword" "merge"

    # 拡張機能リスト生成
    if [ ! -f .vscode/extensions.json ] && [ -n "$ext_type" ]; then
        _generate_extensions_json "$ext_type"
        echo "✅ Generated extensions.json"
    fi
    
    echo "✅ Settings synchronized."
}

## 🧠 Resolver: 状況に応じてプロファイルを特定する賢い関数
function _resolve_profile() {
    local hint="$1"    # "Base" とか "Python" とか
    local fallback_msg="$2"
    local profile_root="$HOME/dotfiles/vscode/profiles"
    
    # 1. ヒントを含む候補を探す (大文字小文字無視)
    local candidates=$(ls "$profile_root" | tr -d "'" | grep -i "$hint")
    local count=$(echo "$candidates" | grep -v "^$" | wc -l)
    
    local selected=""

    if [ "$count" -eq 1 ]; then
        # 1つだけ見つかった -> それを採用 (自動)
        selected=$(echo "$candidates" | head -1)
        
    elif [ "$count" -gt 1 ]; then
        # 複数見つかった -> ユーザーに選ばせる (例: Python Web vs Python Data)
        selected=$(echo "$candidates" | gum choose --header="🤔 Found multiple '$hint' profiles. Which one?" --limit=1)
        
    else
        # 見つからない (0個) -> 全リストから選ばせる (例: "Base"が見つからない時)
        # もしくは、Lang設定なら「なし」を選択可能にする
        if [ "$hint" == "Base" ]; then
            selected=$(ls "$profile_root" | tr -d "'" | gum choose --header="⚠️ 'Base' profile not found. Please select your CORE profile:" --limit=1)
        else
            # 言語プロファイルが見つからない場合はスキップを許容
            # (まだGoを作っていない場合など)
            return 1 
        fi
    fi
    
    # パスを返す
    if [ -n "$selected" ]; then
        echo "$profile_root/$selected/settings.json"
        return 0
    else
        return 1
    fi
}

## 🛠️ Helper: 設定生成 (Resolver使用)
function _generate_vscode_settings_dynamic() {
    local lang_keyword="$1"
    local mode="$2"
    
    # 1. Baseプロファイルを解決 ("Base"という文字で探すが、なければ全リストから選ばせる)
    local base_path=$(_resolve_profile "Base" "Select Core Profile")
    
    # 2. Langプロファイルを解決 (キーワードで探す。複数あれば選ぶ。なければスキップ)
    local lang_path=$(_resolve_profile "$lang_keyword" "Select Language Profile")
    
    local target_path=".vscode/settings.json"
    
    # 🎨 Color Logic (キーワードに基づいて色づけ)
    local color_setting=""
    case "$lang_keyword" in
        *"Python"*) color_setting='{ "workbench.colorCustomizations": { "titleBar.activeBackground": "#1f4f8a", "titleBar.activeForeground": "#ffffff", "activityBar.background": "#1f4f8a" } }' ;;
        *"Web"*)    color_setting='{ "workbench.colorCustomizations": { "titleBar.activeBackground": "#111111", "titleBar.activeForeground": "#ffffff", "activityBar.background": "#222222" } }' ;;
        *"Rust"*)   color_setting='{ "workbench.colorCustomizations": { "titleBar.activeBackground": "#8a3a1f", "titleBar.activeForeground": "#ffffff", "activityBar.background": "#8a3a1f" } }' ;;
        *"Go"*)     color_setting='{ "workbench.colorCustomizations": { "titleBar.activeBackground": "#00add8", "titleBar.activeForeground": "#ffffff", "activityBar.background": "#00add8" } }' ;;
        *)          color_setting='{ "workbench.colorCustomizations": { "titleBar.activeBackground": "#461f8a", "titleBar.activeForeground": "#ffffff", "activityBar.background": "#461f8a" } }' ;;
    esac

    # マージ処理
    local temp_master=$(mktemp)
    
    # Base と Lang の存在確認をしてマージ
    if [ -f "$base_path" ] && [ -f "$lang_path" ]; then
        jq -s '.[0] * .[1]' "$base_path" "$lang_path" > "$temp_master"
    elif [ -f "$lang_path" ]; then
        cat "$lang_path" > "$temp_master"
    elif [ -f "$base_path" ]; then
        cat "$base_path" > "$temp_master"
    else
        echo "{}" > "$temp_master"
    fi

    # 色設定を注入
    local temp_colored=$(mktemp)
    jq -s '.[0] * .[1]' "$temp_master" <(echo "$color_setting") > "$temp_colored"
    
    if [ "$mode" == "merge" ] && [ -f "$target_path" ]; then
        # Local優先マージ
        local temp_merged=$(mktemp)
        jq -s '.[0] * .[1]' "$temp_colored" "$target_path" > "$temp_merged"
        mv "$temp_merged" "$target_path"
    else
        mv "$temp_colored" "$target_path"
    fi
}

## 🛠️ Helper: 拡張機能リスト生成 (維持)
function _generate_extensions_json() {
    local type="$1"
    local base_exts=("pkief.material-icon-theme" "eamodio.gitlens" "usernamehw.errorlens")
    local lang_exts=()
    case "$type" in
        "python") lang_exts=("ms-python.python" "charliermarsh.ruff" "njpwerner.autodocstring") ;;
        "web")    lang_exts=("dbaeumer.vscode-eslint" "esbenp.prettier-vscode" "bradlc.vscode-tailwindcss") ;;
        "rust")   lang_exts=("rust-lang.rust-analyzer" "tamasfe.even-better-toml") ;;
        "go")     lang_exts=("golang.go") ;;
    esac
    local all_exts=("${base_exts[@]}" "${lang_exts[@]}")
    local json_array=$(printf '%s\n' "${all_exts[@]}" | jq -R . | jq -s .)
    echo "{ \"recommendations\": $json_array }" > .vscode/extensions.json
}

## 🛠️ Edit Profiles (動的選択)
function code-config() {
    local profile_dir="$HOME/dotfiles/vscode/profiles"
    local target=$(ls "$profile_dir" | tr -d "'" | gum choose --header="🛠️ Edit Which Profile?" --limit=1)
    [ -z "$target" ] && return
    local file="$profile_dir/$target/settings.json"
    if [ ! -f "$file" ]; then mkdir -p "$(dirname "$file")"; echo "{}" > "$file"; fi
    echo "🚀 Editing Master Profile: $target"
    code "$file"
}

## Work Mode
function work() {
    local n="$1"
    if [ -z "$n" ]; then
        n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Work > " --layout=reverse)
        [ -z "$n" ] && return 1
    fi
    local p="$HOME/PARA/1_Projects/$n/_Code"
    [ ! -d "$p" ] && echo "❌ Not found" && return 1
    echo "🚀 Launching $n..."
    cd "$p"
    if command -v zellij >/dev/null; then
        zellij attach "$n" 2>/dev/null || eval "zellij --session \"$n\" --layout \"$HOME/dotfiles/config/zellij/layouts/cockpit.kdl\""
    else
        code .
    fi
}

alias w="work"
alias m="mkproj"
alias f="finish-work"
alias snap="snapshot"
alias conf="code-config"
alias sync="sync-config"

## =================================================================
## 🚪 Migration & Ejection (Detox Edition)
## =================================================================

## 📥 Import (断捨離モード搭載)
function import-vscode() {
    echo "📥 Importing & Detoxing VS Code settings..."
    
    local vscode_user="$HOME/Library/Application Support/Code/User"
    local profiles_dir="$vscode_user/profiles"
    local choices="Default (User/settings.json)"
    
    if [ -d "$profiles_dir" ]; then
        local existing_profiles=$(ls "$profiles_dir")
        [ -n "$existing_profiles" ] && choices="$choices"$'\n'"$existing_profiles"
    fi
    
    local selected_src=$(echo "$choices" | gum choose --header="Which VS Code profile to import?")
    local source_file=""
    if [ "$selected_src" == "Default (User/settings.json)" ]; then source_file="$vscode_user/settings.json"
    else source_file="$profiles_dir/$selected_src/settings.json"; fi
    
    if [ ! -f "$source_file" ]; then echo "❌ Settings file not found."; return 1; fi

    local cockpit_root="$HOME/dotfiles/vscode/profiles"
    mkdir -p "$cockpit_root/[Base] Common"
    mkdir -p "$cockpit_root/[Lang] Python"
    mkdir -p "$cockpit_root/[Lang] Web"
    mkdir -p "$cockpit_root/[Lang] Rust"
    mkdir -p "$cockpit_root/[Lang] Go"
    mkdir -p "$cockpit_root/[Legacy] Unsorted" # 隔離部屋

    echo "🔍 Analyzing and categorizing..."

    # 1. Base Common: 「見た目と基本挙動」だけを厳選抽出 (ホワイトリスト方式に近い)
    #    editor, window, workbench, files, terminal, security, telemetry などを抽出
    jq 'with_entries(select(.key | test("^editor\\.") or test("^workbench\\.") or test("^window\\.") or test("^files\\.") or test("^terminal\\.") or test("^security\\.") or test("^telemetry\\.") or test("^breadcrumbs\\.") or test("^explorer\\.")))' "$source_file" > "$cockpit_root/[Base] Common/settings.json"
    echo "✅ [Base] Common: Extracted Core UI & Editor settings."

    # 2. Languages
    jq 'with_entries(select(.key | test("python") or test("\\[python\\]")))' "$source_file" > "$cockpit_root/[Lang] Python/settings.json"
    jq 'with_entries(select(.key | test("javascript") or test("typescript") or test("html") or test("css") or test("react") or test("prettier") or test("eslint") or test("liveServer")))' "$source_file" > "$cockpit_root/[Lang] Web/settings.json"
    jq 'with_entries(select(.key | test("rust") or test("cargo")))' "$source_file" > "$cockpit_root/[Lang] Rust/settings.json"
    jq 'with_entries(select(.key | test("go\\.") or test("\\[go\\]")))' "$source_file" > "$cockpit_root/[Lang] Go/settings.json"
    echo "✅ [Lang] XXX : Extracted Language specific settings."

    # 3. Unsorted (ゴミ箱行き): BaseにもLangにも入らなかったもの
    #    ロジック: 全体 - (Baseの条件 + Langの条件)
    jq 'with_entries(select(.key | test("^editor\\.|^workbench\\.|^window\\.|^files\\.|^terminal\\.|^security\\.|^telemetry\\.|^breadcrumbs\\.|^explorer\\.|python|\\[python\\]|javascript|typescript|html|css|react|prettier|eslint|rust|cargo|go\\.|\\.go\\]") | not))' "$source_file" > "$cockpit_root/[Legacy] Unsorted/settings.json"
    
    echo "🧹 [Legacy] Unsorted: Moved everything else here."
    
    # 統計を表示 (どれくらい整理されたか可視化)
    echo ""
    echo "📊 Cleanup Stats:"
    echo "   - Base Rules : $(grep -c ":" "$cockpit_root/[Base] Common/settings.json") lines"
    echo "   - Python Rules: $(grep -c ":" "$cockpit_root/[Lang] Python/settings.json") lines"
    echo "   - Unsorted   : $(grep -c ":" "$cockpit_root/[Legacy] Unsorted/settings.json") lines (Review this later!)"
    echo ""
    echo "🎉 Your config is now organized and detoxed!"
}

# Ejectは変更なしのため省略 (前回のままでOK)
## 📤 Eject (VS Code純正プロファイルとして書き出し)
function eject-cockpit() {
    echo "👋 Ejecting Cockpit configuration..."
    local cockpit_root="$HOME/dotfiles/vscode/profiles"
    local vscode_profiles_dir="$HOME/Library/Application Support/Code/User/profiles"
    mkdir -p "$vscode_profiles_dir"
    
    local base_json="{}"
    local base_path=$(ls "$cockpit_root" | grep "Base" | head -1)
    if [ -n "$base_path" ]; then base_json=$(cat "$cockpit_root/$base_path/settings.json"); fi
    
    local found_langs=$(ls "$cockpit_root" | grep -v "Base" | grep -v "Legacy") # Legacyはエクスポートしない！
    
    echo "$found_langs" | while read -r lang_dir; do
        [ -z "$lang_dir" ] && continue
        local clean_name=$(echo "$lang_dir" | sed 's/\[Lang\] //g' | sed 's/\[.*\] //g')
        local profile_name="Cockpit $clean_name"
        local export_dir="$HOME/Desktop/VSCode_Eject/$profile_name"
        mkdir -p "$export_dir"
        
        echo "   Generating: $profile_name..."
        local lang_json=$(cat "$cockpit_root/$lang_dir/settings.json")
        echo "$base_json" | jq -s '.[0] * .[1]' - <(echo "$lang_json") > "$export_dir/settings.json"
    done
    
    echo "✅ Export complete to: ~/Desktop/VSCode_Eject/"
    echo "   (Note: '[Legacy] Unsorted' settings were purposefully left behind to keep your new start clean.)"
}

alias migrate="import-vscode"
alias eject="eject-cockpit"
