# git-by-numbers demo tape for VHS

Output demo.gif

Require gbn
Require git

Set Theme "Dracula"
Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 700
Set TypingSpeed 35ms
Set WindowBar Colorful
Set Framerate 30

# Hidden setup: clone repo and create uncommitted changes
Hide
Type "rm -rf /tmp/gbn-demo && mkdir -p /tmp/gbn-demo && cd /tmp/gbn-demo"
Enter
Type "git clone --quiet https://github.com/miccou/relegendify.git demo-repo 2>/dev/null"
Enter
Type "cd demo-repo"
Enter
Type "git checkout --quiet 7cd3c3d6cd564dafb467597241b7d574ad0deb4c"
Enter
# Reset to previous commit to show changes
Type "git reset --quiet HEAD~3"
Enter
Type "clear"
Enter
Show

# Demo starts here
Sleep 500ms
Type "# git-by-numbers: operate on files by index"
Enter
Sleep 1s

Type "gbn status"
Enter
Sleep 3s

Type "# Diff specific files using indices"
Enter
Sleep 350ms
Type "gbn diff 2,4 | head -n 10"
Enter
Sleep 3s

Type "# Add files by index range"
Enter
Sleep 350ms
Type "gbn add 3-6"
Enter
Sleep 3s

Type "# Check status again"
Enter
Sleep 350ms
Type "gbn status"
Enter
Sleep 2s

Type "# View staged diff"
Enter
Sleep 350ms
Type "gbn diff --staged 4 | head -n 10"
Enter
Sleep 3s

Type "# Restore staged files"
Enter
Sleep 350ms
Type "gbn restore --staged --yes 3-5"
Enter
Sleep 2s

Type "gbn status"
Enter
Sleep 5s
